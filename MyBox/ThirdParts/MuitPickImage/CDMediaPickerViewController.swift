//
//  CDMediaPickerViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/6.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
@objc protocol CDMediaPickerDelegate {
    @objc optional func onMediaPickerDidFinished(picker:CDMediaPickerViewController,data:Dictionary<String, Any>,index:Int,totalCount:Int)
    @objc optional func onMediaPickerDidCancle(picker:CDMediaPickerViewController)
}

class CDMediaPickerViewController: UINavigationController,CDAssetSelectedDelagete{
    weak var pickerDelegate:CDMediaPickerDelegate!
    public var folderId:Int = 0
    public var isForVideo = false
    private var tmpAssetArr:[CDPHAsset] = []
    private var totalCount = 0
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
        self.pickerDelegate.onMediaPickerDidCancle!(picker: self)
    }

    func selectedAssetsComplete(assets: [CDPHAsset]) {
        
        
        if isForVideo{
            totalCount = assets.count
            tmpAssetArr = assets
            handleVideo(assetArr: assets)
        }else{
            for i in 0..<assets.count {
                autoreleasepool {
                    let cdAsset:CDPHAsset = assets[i]
                    if cdAsset.format == .Live {
                        CDAssetTon.shareInstance().getLivePhotoFromAsset(asset: cdAsset.asset, targetSize: CGSize.zero) { (livePhoto, info) in
                            if livePhoto != nil{
                                let dic:[String:Any] = ["fileName":cdAsset.fileName!,"file":livePhoto!]
                                self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: i + 1, totalCount: assets.count)
                            }
                        }
                    }else{
                        CDAssetTon.shareInstance().getOriginalPhotoFromAsset(asset: cdAsset.asset) { (image) in
                            if image != nil{
                                let dic:[String:Any] = ["fileName":cdAsset.fileName!,"file":image!]
                                self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: i + 1, totalCount: assets.count)
                                
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }

    
    func handleVideo(assetArr: [CDPHAsset]){
        
        let cdAsset = assetArr.first
        CDAssetTon.shareInstance().getVideoFromAsset(withAsset: cdAsset!.asset) { (tmpPath) in
            if tmpPath != nil {
                self.performSelector(onMainThread: #selector(self.videoAssetWorkDone(tmpPath:)), with: tmpPath!, waitUntilDone: true)
            }
        }
    }
    @objc func videoAssetWorkDone(tmpPath:String){
        let index = totalCount - tmpAssetArr.count
        let dic:[String:Any] = ["fileURL":URL(fileURLWithPath: tmpPath)]
        self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: index + 1, totalCount: self.totalCount)
        tmpAssetArr.removeFirst()
        if tmpAssetArr.count > 0 {
            handleVideo(assetArr: tmpAssetArr)
        }
    }
}

//{
//    var alertHasShow = false;
//    for i in 0..<assets.count {
//        autoreleasepool {
//            let phAsset:CDPHAsset = assets[i]
//            let asset = phAsset.asset
//            let fileName = asset.value(forKeyPath: "filename")
//            tmpDict.removeAllObjects()
//            CDAssetTon.shareInstance().getPhotoWithAsset(phAsset: asset, photoWidth: 1280, networkAccessAllowed: true
//                , completion: { (image, info) in
//                    if info!["PHImageResultIsInCloudKey"] as? Int  == 1{
//                        DispatchQueue.main.async {
//                            var message = "\(NSLocalizedString("该", comment: ""))\(NSLocalizedString("照片在icloud,先去下载", comment: ""))"
//                            if assets.count > 1 {
//                                message = "\(NSLocalizedString("部分", comment: ""))\(NSLocalizedString("照片在icloud,先去下载", comment: ""))"
//                            }
//                            if !alertHasShow {
//                                alertHasShow = true
//                                var alert = UIAlertView(title: "", message: message, delegate: nil, cancelButtonTitle: NSLocalizedString("alert_know", comment: ""), otherButtonTitles: "")
//                                alert.show()
//                            }
//                        }
//                    }
//                    else if(image == nil){
//                        DispatchQueue.main.async {
//                            CDHUD.hide()
//                            CDHUDManager.shareInstance().showText(text: "数据异常")
//                        }
//                    }
//                    else{
//                        var suffix = ".jpg"
//                        var isGif = false
//                        let time = getCurrentTimestamp()
//                        let gifImageUrl = info!["PHImageFileURLKey"] as? URL
//
//
//                            if (gifImageUrl != nil) && checkFileTypeWithExternString(externStr: gifImageUrl!.pathExtension) == .GifType{
//                                suffix = ".gif";
//                                isGif = true;
//                            }
//                            let savePath = String.ImagePath().appendingPathComponent(str: "\(time)\(suffix)")
//                            let smallImage = imageCompressForSize(image: image!, maxWidth: 1280)
//                            if isGif{
//                                do{
//                                    let gifData = try Data(contentsOf: gifImageUrl!);
//                                    try gifData.write(to: URL(fileURLWithPath: savePath))
//                                }catch{
//
//                                }
//
//                            }else{
//                                do{
//                                    let imageData = smallImage.jpegData(compressionQuality: 0.5)
//                                    try imageData?.write(to: URL(fileURLWithPath: savePath))
//                                }catch{
//
//                                }
//
//                            }
//
//
//                        self.tmpDict.setObject(savePath, forKey: "savePath" as NSCopying)
//                        self.tmpDict.setObject(smallImage.size.height, forKey: "imageHeight" as NSCopying)
//                        self.tmpDict.setObject(smallImage.size.width, forKey: "imageWidth" as NSCopying)
//                        self.tmpDict.setObject(time, forKey: "time" as NSCopying)
//                        let isLast = i == assets.count - 1 ? true : false
//                        self.tmpDict.setObject(isLast, forKey: "isLast" as NSCopying)
//                        self.tmpDict.setObject(isGif, forKey: "isGif" as NSCopying)
//                        self.tmpDict.setObject(fileName, forKey: "fileName" as NSCopying)
//                        self.pickerDelegate.onSelectedMediaPickerDidFinished(picker: self, info: self.tmpDict)
//
//                    }
//            })
//        }
//
//
//    }
//}

