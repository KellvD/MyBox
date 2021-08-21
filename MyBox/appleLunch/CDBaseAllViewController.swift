//
//  CDBaseAllViewController.swift
//  MyRule
//
//  Created by changdong on 2018/11/12.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import AVFoundation

extension CDBaseAllViewController {
    public typealias CDDocumentPickerCompleteHandler = (_ success:Bool) -> Void
    public typealias CDComposeHandle = (_ success:Bool) -> (Void) //合成视频，GIf,拼接视频
}
class CDBaseAllViewController:
UIViewController,UIGestureRecognizerDelegate,UIDocumentPickerDelegate {

    var popBtn = UIButton()
    var subFolderId:Int = 0
    var subFolderType:NSFolderType!
    open var processHandle:CDBaseAllViewController.CDDocumentPickerCompleteHandler?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .baseBgColor
        self.popBtn = UIButton(type: .custom)
        self.popBtn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        self.popBtn.setImage(LoadImage("back_normal"), for: .normal)
        self.popBtn.setImage(LoadImage("back_pressed"), for: .selected)
        self.popBtn.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.popBtn)
        
    }
    
    override func viewWillLayoutSubviews() {
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark{
                print("暗黑模式")
            }else{
                //
                print("正常模式")
            }
        } else {
            // Fallback on earlier versions
        }
    }
        
    @objc func backButtonClick() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    func hiddBackbutton()->Void{
        self.popBtn.isHidden = true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func presentDocumentPicker(documentTypes:[String]) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        if #available(iOS 11, *) {
            documentPicker.allowsMultipleSelection = true
        }
        CDSignalTon.shared.customPickerView = documentPicker
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    //MARK:UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        CDSignalTon.shared.customPickerView = nil
        var index = 0
        var errorArr:[String] = []
        func handleAllDocumentPickerFiles(urlArr:[URL]){
            DispatchQueue.global().async {
                var tmpUrlArr = urlArr
                if urlArr.count > 0 {
                    index += 1
                    let subUrl = urlArr.first!
                    let fileUrlAuthozied = subUrl.startAccessingSecurityScopedResource()
                    if fileUrlAuthozied {
                        let fileCoordinator = NSFileCoordinator()
                        
                        fileCoordinator.coordinate(readingItemAt: subUrl, options: [], error: nil) {[unowned self] (newUrl) in
                            do {
                                let fileSize = try Data(contentsOf: newUrl).count
                                if fileSize > CDDeviceTools.getDiskSpace().free {
                                    DispatchQueue.main.async {
                                        self.alertSpaceWarn(alertType: .AlertDocumentType)
                                        CDHUDManager.shared.hideProgress()
                                        
                                        return
                                    }
                                }else{
                                    CDSignalTon.shared.saveSafeFileInfo(fileUrl: newUrl, folderId: self.subFolderId, subFolderType: self.subFolderType,isFromDocment: true)
                                    tmpUrlArr.removeFirst()
                                    handleAllDocumentPickerFiles(urlArr: tmpUrlArr)
                                }
                            } catch {
                                errorArr.append(subUrl.absoluteString)
                                CDPrintManager.log("文件导入失败:\(error.localizedDescription)", type: .ErrorLog)
                                tmpUrlArr.removeFirst()
                                handleAllDocumentPickerFiles(urlArr: tmpUrlArr)
                                return
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        CDHUDManager.shared.updateProgress(num: Float(index)/Float(urls.count), text: "\(index)/\(urls.count)")
                    }
                }else{
                    DispatchQueue.main.async {
                        CDHUDManager.shared.hideProgress()
                        if errorArr.count == 0{
                            CDHUDManager.shared.showComplete(LocalizedString("import complete"))
                        }else{
                            CDHUDManager.shared.showComplete(LocalizedString("some files failed to import"))
                        }
                        
                        self.processHandle?(true)
                    }
                }
            }
            
            
        }
        handleAllDocumentPickerFiles(urlArr: urls)
        CDHUDManager.shared.showProgress(LocalizedString("start import"))
    }

    
    //分享
    func presentShareActivityWith(dataArr:[NSObject],Complete:@escaping(_ error:Error?) -> Void) {
        
        let activityVC = UIActivityViewController(activityItems: dataArr, applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(activityType, complete, items, error) -> Void in
            if complete {
                Complete(error)
            }
        }
    
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func alertSpaceWarn(alertType:DiskSpaceAlertType) {
        let message:String = alertType.rawValue

        let alert = UIAlertController(title: LocalizedString("warning"), message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: LocalizedString("NO"), style: .cancel, handler: { (action) in
        }))
        alert.addAction(UIAlertAction(title: LocalizedString("yes"), style: .default, handler: { (action) in

        }))
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

