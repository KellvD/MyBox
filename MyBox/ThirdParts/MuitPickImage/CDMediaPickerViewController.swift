//
//  CDMediaPickerViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/6.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

@objc protocol CDMediaPickerDelegate {
    func onSelectedMediaPickerDidFinished(picker:CDMediaPickerViewController,info:NSMutableDictionary)
    func onSelectedMediaPickerDidCancle(picker:CDMediaPickerViewController)
}

class CDMediaPickerViewController: UINavigationController,CDAessetSelectionDelagete{
    weak var pickerDelegate:CDMediaPickerDelegate!
    var folderId:Int = 0
    var isForVideo = false
    var tmpDict = NSMutableDictionary()

    init(isVideo:Bool) {
        let albumVC = CDAlbumPickViewController()
        super.init(rootViewController: albumVC)
        albumVC.assetDelegate = self
        albumVC.isSelectedVideo = isVideo
        isForVideo = isVideo

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @objc public func cancleMediaPicker() {
        self.pickerDelegate.onSelectedMediaPickerDidCancle(picker: self)
    }

    func selectedAssets(assets: [CDPHAsset]) {


        if isForVideo{
            CDSignalTon.instance.handleSaveVideoWith(assets: assets, folderId: folderId)
            return
        }else{
            var alertHasShow = false;
            for i in 0..<assets.count {
                autoreleasepool {
                    let phAsset:CDPHAsset = assets[i]
                    let asset = phAsset.asset
                    let filePath:NSString = phAsset.filePath as NSString
                    var fileName = phAsset.fileName
                    if filePath.length > 0{
                        fileName = filePath.lastPathComponent
                    }

                    tmpDict.removeAllObjects()
                    
                    CDAssetTon.shareInstance().getPhotoWithAsset(phAsset: asset, photoWidth: 1280, networkAccessAllowed: true
                        , completion: { (image, info) in
                            if info!["PHImageResultIsInCloudKey"] as? Int  == 1{
                                DispatchQueue.main.async {
                                    var message = "\(NSLocalizedString("该", comment: ""))\(NSLocalizedString("照片在icloud,先去下载", comment: ""))"
                                    if assets.count > 1 {
                                        message = "\(NSLocalizedString("部分", comment: ""))\(NSLocalizedString("照片在icloud,先去下载", comment: ""))"
                                    }
                                    if !alertHasShow {
                                        alertHasShow = true
                                        var alert = UIAlertView(title: "", message: message, delegate: nil, cancelButtonTitle: NSLocalizedString("alert_know", comment: ""), otherButtonTitles: "")
                                        alert.show()
                                    }
                                }
                            }
                            else if(image == nil){
                                DispatchQueue.main.async {
                                    CDHUD.hide()
                                    CDHUD.showText(text: "数据异常")
                                }
                            }
                            else{
                                var suffix = ".jpg"
                                var isGif = false
                                let time = getCurrentTimestamp()
                                let gifImageUrl = info!["PHImageFileURLKey"] as? URL


                                    if (gifImageUrl != nil) && checkFileTypeWithExternString(externStr: gifImageUrl!.pathExtension) == .GifType{
                                        suffix = ".gif";
                                        isGif = true;
                                    }
                                    let savePath = String.ImagePath().appendingPathComponent(str: "\(time)\(suffix)")
                                    let smallImage = imageCompressForSize(image: image!, maxWidth: 1280)
                                    if isGif{
                                        do{
                                            let gifData = try Data(contentsOf: gifImageUrl!);
                                            try gifData.write(to: URL(fileURLWithPath: savePath))
                                        }catch{

                                        }

                                    }else{
                                        do{
                                            let imageData = smallImage.jpegData(compressionQuality: 0.5)
                                            try imageData?.write(to: URL(fileURLWithPath: savePath))
                                        }catch{

                                        }

                                    }


                                self.tmpDict.setObject(savePath, forKey: "savePath" as NSCopying)
                                self.tmpDict.setObject(smallImage.size.height, forKey: "imageHeight" as NSCopying)
                                self.tmpDict.setObject(smallImage.size.width, forKey: "imageWidth" as NSCopying)
                                self.tmpDict.setObject(time, forKey: "time" as NSCopying)
                                let isLast = i == assets.count - 1 ? true : false
                                self.tmpDict.setObject(isLast, forKey: "isLast" as NSCopying)
                                self.tmpDict.setObject(isGif, forKey: "isGif" as NSCopying)
                                self.tmpDict.setObject(fileName, forKey: "fileName" as NSCopying)
                                self.pickerDelegate.onSelectedMediaPickerDidFinished(picker: self, info: self.tmpDict)

                            }
                    })
                }


            }
        }
    }
}


