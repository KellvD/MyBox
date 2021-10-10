//
//  CDMediaPickerViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/6.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import CoreLocation

@objc public protocol CDMediaPickerDelegate :NSObjectProtocol{
    @objc optional func onMediaPickerDidFinished(picker:CDMediaPickerViewController,data:Dictionary<String, Any>,index:Int,totalCount:Int)
    @objc optional func onMediaPickerDidCancle(picker:CDMediaPickerViewController)
}

public class CDMediaPickerViewController: UINavigationController,CDAssetSelectedDelagete{
    public weak var pickerDelegate:CDMediaPickerDelegate!
    public var isForVideo = false
    var gphAssets:[CDPHAsset] = []
    var totalCount = 0
    public init(isVideo:Bool) {
        CDAssetTon.shared.mediaType = isVideo ? .CDMediaVideo : .CDMediaImage
        let albumVC = CDAlbumPickViewController()
        super.init(rootViewController: albumVC)
        self.navigationBar.tintColor = UIColor.black
        self.navigationBar.isTranslucent = false
        albumVC.assetDelegate = self
        albumVC.isSelectedVideo = isVideo
        isForVideo = isVideo
        

    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc public func cancleMediaPicker() {
        self.pickerDelegate.onMediaPickerDidCancle!(picker: self)
    }

    func selectedAssetsComplete(phAssets: [CDPHAsset]) {
       
        if isForVideo{
            totalCount = phAssets.count
            self.gphAssets = phAssets
            handleVideo()
        }else{
            for i in 0..<phAssets.count {
                autoreleasepool {
                    let tmpAsset:CDPHAsset = phAssets[i]
                    //Live图片本地暂无法保存
                    let createTime = Int(tmpAsset.asset.creationDate!.timeIntervalSince1970 * 1000)
                    let location = tmpAsset.asset.location ?? CLLocation(latitude: -1, longitude: -1)
                    if tmpAsset.format == .Live {
//                        CDAssetTon.shared.getLivePhotoFromAsset(asset: tmpAsset.asset, targetSize: CGSize.zero) { (livePhoto, info) in
//                            if livePhoto != nil{
//                                let dic:[String:Any] = ["fileName":tmpAsset.fileName!,"file":livePhoto!,"imageType":"live"]
//                                self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: i + 1, totalCount: phAssets.count)
//                            }
//                        }
                        CDAssetTon.shared.getOriginalPhotoFromAsset(asset: tmpAsset.asset) { (image) in
                            if image != nil{
                                let dic:[String:Any] = ["fileName":tmpAsset.fileName!,
                                                        "file":image!,
                                                        "imageType":"normal",
                                                        "createTime":createTime,
                                                        "location":location]
                                self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: i + 1, totalCount: phAssets.count)
                                
                            }
                        }
                    }else if tmpAsset.format == .Gif {
                        CDAssetTon.shared.getImageDataFromAsset(asset: tmpAsset.asset) { (data, info) in
                            if data != nil{
                                let dic:[String:Any] = ["fileName":tmpAsset.fileName!,
                                                        "file":data!,
                                                        "imageType":"gif",
                                                        "createTime":createTime,
                                                        "location":location]
                                self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: i + 1, totalCount: phAssets.count)
                            }
                        }
                    }else{
                        CDAssetTon.shared.getOriginalPhotoFromAsset(asset: tmpAsset.asset) { (image) in
                            if image != nil{
                                let dic:[String:Any] = ["fileName":tmpAsset.fileName!,
                                                        "file":image!,
                                                        "imageType":"normal",
                                                        "createTime":createTime,
                                                        "location":location]
                                self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: i + 1, totalCount: phAssets.count)
                                
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    
    private func handleVideo(){

        let tmpAsset = gphAssets.first
        CDAssetTon.shared.getVideoFromAsset(withAsset: tmpAsset!.asset) { (tmpPath) in
            if tmpPath != nil {
                self.performSelector(onMainThread: #selector(self.videoAssetWorkDone(tmpPath:)), with: tmpPath!, waitUntilDone: true)
            }
        }
    }

    @objc private func videoAssetWorkDone(tmpPath:String){
        let index = totalCount - gphAssets.count
        let dic:[String:Any] = ["fileURL":URL(fileURLWithPath: tmpPath)]
        
        self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: index + 1, totalCount: self.totalCount)
        gphAssets.removeFirst()
        if gphAssets.count > 0 {
            
            handleVideo()
            
        }
    }
    //GCD队列
//    private func handleVideo(){
//        let sem = DispatchSemaphore(value: 1)
//        DispatchQueue(label: "handleVideo",qos: .default).sync {
//            for index in 0..<gphAssets.count{
//                sem.wait()
//                let tmpAsset = self.gphAssets[index]
//                CDAssetTon.shared.getVideoFromAsset(withAsset: tmpAsset.asset) { (tmpPath) in
//                    if tmpPath != nil {
//                        let dic:[String:Any] = ["fileURL":URL(fileURLWithPath: tmpPath!)]
//                        self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: index + 1, totalCount: self.totalCount)
//                        sem.signal()
//                    }
//                }
//            }
//        }
//    }
}

