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
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let fileUrlAuthozied = url.startAccessingSecurityScopedResource()
        if fileUrlAuthozied {
            let fileCoordinator = NSFileCoordinator()
            fileCoordinator.coordinate(readingItemAt: url, options: [], error: nil) { (newUrl) in
                let urlStr = url.absoluteString
                var fileName = urlStr.getFileNameFromPath()
                fileName = fileName.removingPercentEncoding()
                let suffix = urlStr.pathExtension()
                let contentData = NSData(contentsOf: newUrl)
                let fileType = checkFileTypeWithExternString(externStr: suffix)
                let currentTime = getCurrentTimestamp()
                let fileInfo = CDSafeFileInfo()
                fileInfo.folderId = subFolderId
                fileInfo.userId = CDUserId()
                fileInfo.fileName = fileName
                fileInfo.createTime = currentTime
                fileInfo.fileType = fileType
                let filePath:String!
                if subFolderType == .ImageFolder{
                    filePath = String.ImagePath().appendingPathComponent(str: "\(currentTime).\(suffix)")
                    contentData?.write(toFile: filePath, atomically: true)
                    let thumbPath = String.thumpImagePath().appendingPathComponent(str: "\(currentTime).jpg")
                    let image = UIImage(data: contentData! as Data)!
                    let thumbImage = scaleImageAndCropToMaxSize(image: image, newSize: CGSize(width: 200, height: 200))
                    let tmpData:NSData = thumbImage.jpegData(compressionQuality: 1.0)! as! NSData
                    tmpData.write(toFile: thumbPath, atomically: true)

                    fileInfo.fileWidth = Double(image.size.width)
                    fileInfo.fileHeight = Double(image.size.height)
                    fileInfo.thumbImagePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: thumbPath)

                }else if subFolderType == .AudioFolder ||
                    subFolderType == .VideoFolder{
                    let opts = [AVURLAssetPreferPreciseDurationAndTimingKey : NSNumber(value: false)]
                    let urlAsset: AVURLAsset = AVURLAsset(url: url, options: opts)
                    let voiceTime = Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale)
                    fileInfo.timeLength = voiceTime
                    if subFolderType == .VideoFolder{
                        filePath = String.VideoPath().appendingPathComponent(str: "\(currentTime).\(suffix)")
                        contentData?.write(toFile: filePath, atomically: true)

                        let thumbPath = String.thumpVideoPath().appendingPathComponent(str: "\(currentTime).jpg")
                        let image = CDSignalTon.shareInstance().firstFrmaeWithTheVideo(videoPath: filePath)
                        let data = image.jpegData(compressionQuality: 1.0)
                        do {
                            try data?.write(to: URL(fileURLWithPath: thumbPath))
                        } catch  {

                        }
                        fileInfo.thumbImagePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: thumbPath)
                    }else{
                        filePath = String.AudioPath().appendingPathComponent(str: "\(currentTime).\(suffix)")
                        contentData?.write(toFile: filePath, atomically: true)

                    }

                }else{
                    filePath = String.OtherPath().appendingPathComponent(str: "\(fileName).\(suffix)")
                    contentData?.write(toFile: filePath, atomically: true)
                }
                let fileSize = getFileSizeAtPath(filePath: filePath)
                fileInfo.fileSize = fileSize
                fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: filePath)
                CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)
                NotificationCenter.default.post(name: DocumentInputFile, object: nil)
                url.stopAccessingSecurityScopedResource()
            }
        }else{
            let alert = UIAlertController(title: nil, message: "申请访问受限", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }

    func presentShareActivityWith(dataArr:[NSObject]) {
        let activity = UIActivityViewController(activityItems: dataArr, applicationActivities: nil)
        activity.excludedActivityTypes =
            [UIActivity.ActivityType.postToFacebook,
        UIActivity.ActivityType.postToTencentWeibo,
        UIActivity.ActivityType.airDrop,
        UIActivity.ActivityType.saveToCameraRoll,
        UIActivity.ActivityType.print,
        UIActivity.ActivityType.mail]
        self.present(activity, animated: true, completion: nil)
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
