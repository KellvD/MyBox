//
//  CDBaseAllViewController.swift
//  MyRule
//
//  Created by changdong on 2018/11/12.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import AVFoundation
class CDBaseAllViewController: UIViewController,UIGestureRecognizerDelegate,UIDocumentPickerDelegate {

    var popBtn = UIButton()
    var subFolderId:Int = 0
    var subFolderType:NSFolderType!

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
            CDSignalTon.shareInstance().customPickerView = documentPicker
            self.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    //TODO:UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        CDSignalTon.shareInstance().customPickerView = nil
//        DispatchQueue.main.async {
            
//        }
        CDHUDManager.shareInstance().showProgress(text: "文件存储中...")
        for index in 0..<urls.count {
            let subUrl = urls[index]
            let fileUrlAuthozied = subUrl.startAccessingSecurityScopedResource()
            if fileUrlAuthozied {
//                let fileCoordinator = NSFileCoordinator()
//                fileCoordinator.coordinate(readingItemAt: url, options: [], error: nil) { (newUrl) in
                    let urlPath = subUrl.absoluteString
                CDSignalTon.shareInstance().saveSafeFileInfo(filePath: urlPath, folderId: subFolderId, subFolderType: subFolderType)
//                CDHUDManager.shareInstance().updateProgress(num: Float(index/urls.count), text: fileName)
//                }
                
            }else{
                CDHUDManager.shareInstance().updateProgress(num: Float(index/urls.count), text: "fileName")
            }
            
            
        }
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: DocumentInputFile, object: nil)
//            CDHUDManager.shareInstance().hideProgress()
//        CDHUDManager.shareInstance().showComplete(text: "导入完成！")
//        }
        
    }

    //分享
    func presentShareActivityWith2(dataArr:[NSObject]) {
        let activityVC = UIActivityViewController(activityItems: dataArr, applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(activityType, complete, items, error) -> Void in
            if complete {
                CDHUDManager.shareInstance().showComplete(text: "分享成功！")
            }
        }
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func presentShareActivityWith(dataArr:[URL],completion: @escaping((_ complete:Bool,_ error:Error?) -> Void)) {
        let activityVC = UIActivityViewController(activityItems: dataArr, applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(activityType, complete, items, error) -> Void in
            completion(complete,error)
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



class CDActivity: UIActivity {
    var title:String!
    var imageName:String!
    var url:URL?
    var shareContext:[Any]?
    
    
    
    init(title:String,imageName:String,url:URL?,shareContext:[Any]?) {
        super.init()
        self.title = title
        self.imageName = imageName
        self.url = url
        self.shareContext = shareContext
    }
    override class var activityCategory: UIActivity.Category {
        return .share
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: imageName)
    }
    
    override var activityTitle: String? {
        return title
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType("CDActivity")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        if activityItems.count > 0 {
            return true
        }
        return false
    }
    
    override func perform() {
        self.activityDidFinish(true)
    }
    
}
