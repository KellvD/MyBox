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
}
class CDBaseAllViewController:
UIViewController,UIGestureRecognizerDelegate,UIDocumentPickerDelegate {

    var popBtn = UIButton()
    var subFolderId:Int = 0
    var subFolderType:NSFolderType!
    open var docuemntPickerComplete:CDDocumentPickerCompleteHandler?
    
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
    lazy var noMoreDataView: UIView = {
        let bgView = UIView(frame: CGRect(x: CDSCREEN_WIDTH/2.0 - 85.0/2.0, y: CDViewHeight/2.0 - 85/2.0 - 60, width: 85.0, height: 85.0 + 60))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 85.0, height: 85.0))
        imageView.image = "wushuju-2-universal".image
        bgView.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: 0, y: imageView.maxY, width: 85, height: 30))
        label.text = "无数据".localize
        label.textAlignment = .center
        label.font = .midSmall
        label.textColor = .lightGray
        bgView.addSubview(label)
        
        bgView.isHidden = true
        self.view.addSubview(bgView)
        return bgView
    }()
    
    override func viewWillLayoutSubviews() {
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark{
            }else{
                //
            }
        } else {
            // Fallback on earlier versions
        }
    }
        
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "fileArr" {
            DispatchQueue.main.async {
                let new = change?[NSKeyValueChangeKey.newKey] as? [CDSafeFileInfo]
                self.noMoreDataView.isHidden = new!.count > 0
            }
            
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
                                    CDSignalTon.shared.saveFileWithUrl(fileUrl: newUrl, folderId: self.subFolderId, subFolderType: self.subFolderType,isFromDocment: true)
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
                            CDHUDManager.shared.showComplete("导入完成".localize)
                        }else{
                            CDHUDManager.shared.showComplete("部分文件导入失败".localize)
                        }
                        
                        self.docuemntPickerComplete?(true)
                    }
                }
            }
            
            
        }
        handleAllDocumentPickerFiles(urlArr: urls)
        CDHUDManager.shared.showProgress("开始导入".localize)
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

        let alert = UIAlertController(title: "警告".localize, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "否".localize, style: .cancel, handler: { (action) in
        }))
        alert.addAction(UIAlertAction(title: "是".localize, style: .default, handler: { (action) in

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

