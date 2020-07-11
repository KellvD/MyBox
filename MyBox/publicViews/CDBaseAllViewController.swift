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
    open var processHandle:CDBaseAllViewController.CDDocumentPickerCompleteHandler?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.popBtn = UIButton(type: .custom)
        self.popBtn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        self.popBtn.setImage(LoadImageByName(imageName: "back_normal", type: "png"), for: .normal)
        self.popBtn.setImage(LoadImageByName(imageName: "back_pressed", type: "png"), for: .selected)
        self.popBtn.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.popBtn)
    }

    @objc func backButtonClick() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    func hiddBackbutton()->Void{
        self.popBtn.isHidden = true
    }

    func presentDocumentPicker(documentTypes:[String]) {
        if #available(iOS 8, *) {
            let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .fullScreen
            if #available(iOS 11, *) {
                documentPicker.allowsMultipleSelection = true
            }
            CDSignalTon.shared.customPickerView = documentPicker
            self.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    //MARK:UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        CDSignalTon.shared.customPickerView = nil
        var index = 0
        func handleAllDocumentPickerFiles(urlArr:[URL]){
            DispatchQueue.global().async {
                var tmpUrlArr = urlArr
                if urlArr.count > 0 {
                    index += 1
                    let subUrl = urlArr.first!
                    let fileUrlAuthozied = subUrl.startAccessingSecurityScopedResource()
                    if fileUrlAuthozied {
                        let fileCoordinator = NSFileCoordinator()
                        fileCoordinator.coordinate(readingItemAt: subUrl, options: [], error: nil) { (newUrl) in
                            
                            CDSignalTon.shared.saveSafeFileInfo(tmpFileUrl: newUrl, folderId: self.subFolderId, subFolderType: self.subFolderType)
                            tmpUrlArr.removeFirst()
                            handleAllDocumentPickerFiles(urlArr: tmpUrlArr)
                        }
                    }
                    DispatchQueue.main.async {
                        CDHUDManager.shared.updateProgress(num: Float(index)/Float(urls.count), text: "\(index)/\(urls.count)")
                    }
                }else{
                    DispatchQueue.main.async {
                        CDHUDManager.shared.hideProgress()
                        CDHUDManager.shared.showComplete(text: "导入完成")
                        self.processHandle?(true)
                    }
                }
            }
            
            
        }
        handleAllDocumentPickerFiles(urlArr: urls)
        CDHUDManager.shared.showProgress(text: "开始导入！")
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
    
    func alertSpaceWarn(alertType:AlertType) {
        var message:String!

        if alertType == .AlertShootVideoType  {
            message = "可用存储空间不足，无法拍摄视频。您可以在设置里管理存储空间。"
        }else if alertType == .AlertVideosType  {
            message = "可用存储空间不足，无法导入此视频。您可以在设置里管理存储空间。"
        }else if alertType == .AlertPlayVideoType  {
            message = "可用存储空间不足，无法播放视频。您可以在设置里管理存储空间。"
        }else if alertType == .AlertTakePhotoType  {
            message = "可用存储空间不足，无法拍摄照片。您可以在设置里管理存储空间。"
        }else if alertType == .AlertPhotosType  {
            message = "可用存储空间不足，无法导入这些图片。您可以在设置里管理存储空间"
        }else if alertType == .AlertBrowsePhotosType  {
            message = "可用存储空间不足，无法浏览照片。您可以在设置里管理存储空间。"
        }else if alertType == .AlertMakeRecordType  {
            message = "可用存储空间不足，无法录制音频。您可以在设置里管理存储空间。"
        }else if alertType == .AlertRecordsType {
            message = "可用存储空间不足，无法播放音频。您可以在设置里管理存储空间。"
        }
        let alert = UIAlertController(title: "警告", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "否", style: .cancel, handler: { (action) in
        }))
        alert.addAction(UIAlertAction(title: "是", style: .default, handler: { (action) in

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

