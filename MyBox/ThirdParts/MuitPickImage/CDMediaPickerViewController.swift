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
    private var gphAssets:[CDPHAsset] = []
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

    func selectedAssetsComplete(phAssets: [CDPHAsset]) {
       
        if isForVideo{
            totalCount = phAssets.count
            self.gphAssets = phAssets
            handleVideo()
        }else{
            for i in 0..<phAssets.count {
                autoreleasepool {
                    let tmpAsset:CDPHAsset = phAssets[i]
                    if CDDeviceTools.getDiskSpace().free < tmpAsset.fileSize{
                        diskAlert()
                        return;
                    }
                    //Live图片本地暂无法保存
//                    if tmpAsset.format == .Live {
//                        CDAssetTon.shared.getLivePhotoFromAsset(asset: tmpAsset.asset, targetSize: CGSize.zero) { (livePhoto, info) in
//                            if livePhoto != nil{
//                                let dic:[String:Any] = ["fileName":tmpAsset.fileName!,"file":livePhoto!,"imageType":"live"]
//                                self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: i + 1, totalCount: phAssets.count)
//                            }
//                        }
//                    }else{
                        CDAssetTon.shared.getOriginalPhotoFromAsset(asset: tmpAsset.asset) { (image) in
                            if image != nil{
                                let dic:[String:Any] = ["fileName":tmpAsset.fileName!,"file":image!,"imageType":"normal"]
                                self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: i + 1, totalCount: phAssets.count)
                                
                            }
                        }
//                    }
                    
                    
                }
            }
        }
    }

    
    private func handleVideo(){
        
        let tmpAsset = gphAssets.first
        if CDDeviceTools.getDiskSpace().free < tmpAsset!.fileSize{
            diskAlert()
            return;
        }
        CDAssetTon.shared.getVideoFromAsset(withAsset: tmpAsset!.asset) { (tmpPath) in
            if tmpPath != nil {
                self.performSelector(onMainThread: #selector(self.videoAssetWorkDone(tmpPath:)), with: tmpPath!, waitUntilDone: true)
            }
        }
    }
    @objc func videoAssetWorkDone(tmpPath:String){
        let index = totalCount - gphAssets.count
        let dic:[String:Any] = ["fileURL":URL(fileURLWithPath: tmpPath)]
        self.pickerDelegate.onMediaPickerDidFinished!(picker: self, data: dic, index: index + 1, totalCount: self.totalCount)
        gphAssets.removeFirst()
        if gphAssets.count > 0 {
            handleVideo()
        }
    }
    
    private func diskAlert(){
        
        let alert = UIAlertController(title: "警告", message: "磁盘空间不足，导入失败！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

