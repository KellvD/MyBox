//
//  CDAsset.swift
//  MyRule
//
//  Created by changdong on 2019/4/28.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary
class CDAssetTon: NSObject {

    var mediaType:CDMediaType!
    static let shared = CDAssetTon()


    
    //MARK:获取图片列表
    func getAllAlbums(WithFinished Finished: @escaping ([CDAlbum]) -> Void) {

        var allAlbumArr:[CDAlbum] = []
        //列出所有相册,由subtype决定
        let options = PHFetchOptions()
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: options)
        
        for i in 0..<albums.count{
            let resultsOptions = PHFetchOptions()
            if self.mediaType == .CDMediaVideo{
                resultsOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            }else if self.mediaType == .CDMediaImage{
                resultsOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            }else{
                resultsOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.unknown.rawValue)
            }
            
            let defaluC = albums[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: defaluC, options: resultsOptions)
            if assetsFetchResult.count>0 {
                let title = self.titleOfAlbumForChinse(title: defaluC.localizedTitle)
                if title != "最近删除"{
                    allAlbumArr.append(CDAlbum(title:title, fetchResult:assetsFetchResult))
                    
                }
            }
        }
        Finished(allAlbumArr)
        
    }

    //MARK:相册名转为中文
    private func titleOfAlbumForChinse(title:String?)->String?{
        if title == "Slo-mo" {
            return "慢动作"
        }else if title == "Recently Added" {
            return "最近添加"
        }else if title == "Favorites" {
            return "个人收藏"
        }else if title == "Recently Deleted" {
            return "最近删除"
        }else if title == "Video" {
            return "视频"
        }else if title == "All Photos" {
            return "所有照片"
        }else if title == "Selfies" {
            return "自拍"
        }else if title == "Screenshots" {
            return "屏幕快照"
        }else if title == "Camera Roll" {
            return "相机胶卷"
        }
        return title
    }
    
    func getVideoFromAsset(withAsset asset: PHAsset, Handle:@escaping(String?) ->Void) {

        if asset.mediaType == .video {
            let videoManager = PHImageManager.default()
            let option = PHVideoRequestOptions()
            option.isNetworkAccessAllowed = true
            option.deliveryMode = .automatic
            option.version = .current
            videoManager.requestAVAsset(forVideo: asset, options: option) { (avAsset, audioMix, array) in
                guard let urlAsset: AVURLAsset = avAsset as? AVURLAsset else {
                    print("视频获取失败")
                    return
                }
                
                self.startExportVideo(videoAsset: urlAsset) { (tmpVideoPath) in
                    Handle(tmpVideoPath)
                }
            }

        }
    }


    //视频压缩
    func startExportVideo(videoAsset:AVURLAsset, Handled:@escaping(String?) ->Void){

        let preaets = AVAssetExportSession.exportPresets(compatibleWith: videoAsset)
        if preaets.contains(AVAssetExportPresetHighestQuality) {
            let session:AVAssetExportSession = AVAssetExportSession.init(asset: videoAsset, presetName: AVAssetExportPreset640x480)!
            let time = GetTimestamp(nil)
            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let tmpVideo = (docPath as NSString).appendingPathComponent("/tmpVideo")
            if !FileManager.default.fileExists(atPath: tmpVideo) {
                try! FileManager.default.createDirectory(atPath: tmpVideo, withIntermediateDirectories: true, attributes: nil)
            }
            let tmpVideoPath = (tmpVideo as NSString).appendingPathComponent("/\(time).mp4")
            //输出路径
            session.outputURL = URL.init(fileURLWithPath: tmpVideoPath)
            //优化网络
            session.shouldOptimizeForNetworkUse = true
            let supportedTypeArr = session.supportedFileTypes
            if supportedTypeArr.contains(AVFileType.mp4){
                session.outputFileType = AVFileType.mp4
            }else if supportedTypeArr.count == 0{
                print("视频类型暂不支持导出")
                return
            }else{
                session.outputFileType = supportedTypeArr.first
            }
            //异步导出
            session.exportAsynchronously {
                switch session.status{
                case .unknown, .waiting, .exporting, .failed:
                   break
                case .completed:
                    Handled(tmpVideoPath)
                case .cancelled:
                    break
                @unknown default:
                    break;
                }
            }
        }

    }
    //获取优化后的视频转向信息

    func fixedComposition(videoAsset: AVAsset) -> AVMutableVideoComposition? {
        let videoComposition = AVMutableVideoComposition()
        let degrees = degressFromVideoFile(asset:videoAsset)
        if degrees != 0 {
            var translateToCenter: CGAffineTransform!
            var mixedTransform: CGAffineTransform!
            videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

            let tracks = videoAsset.tracks(withMediaType: .video)
            let videoTrack:AVAssetTrack = tracks[0]

            if degrees == 90 {
                // 顺时针旋转90°
                translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: 0.0)
                mixedTransform = translateToCenter!.rotated(by: CGFloat(Double.pi/2))
                videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
            }else if(degrees == 180){
                translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: 0.0)
                mixedTransform = translateToCenter!.rotated(by: CGFloat(Double.pi))
                videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)

            }else if(degrees == 270){
                translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: 0.0)
                mixedTransform = translateToCenter!.rotated(by: CGFloat(Double.pi * 3.0))
                videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
            }
            let roateInstruction = AVMutableVideoCompositionInstruction()
            roateInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration)
            let roateLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            roateLayerInstruction.setTransform(mixedTransform!, at: CMTime.zero)
            roateInstruction.layerInstructions = [roateLayerInstruction]
            videoComposition.instructions = [roateInstruction]

        }
        return videoComposition
    }

    func degressFromVideoFile(asset: AVAsset) -> Int {
        var degress: Int = 0
        let tracks = asset.tracks(withMediaType: .video)
        if (tracks.count) > 0 {
            let videoTrack: AVAssetTrack = tracks[0]
            let t: CGAffineTransform = videoTrack.preferredTransform
            if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0 {
                // Portrait
                degress = 90
            } else if t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0 {
                // PortraitUpsideDown
                degress = 270
            } else if t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0 {
                // LandscapeRight
                degress = 0
            } else if t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0 {
                // LandscapeLeft
                degress = 180
            }
        }
        return degress
    }




    func getPhotoWithAsset(phAsset: PHAsset, photoWidth: CGFloat,  networkAccessAllowed: Bool, completion:@escaping(UIImage?,NSMutableDictionary?) ->Void) {

        let aspectRatio =  CGFloat(phAsset.pixelWidth / phAsset.pixelHeight)
        let multiple: CGFloat = UIScreen.main.scale
        let pixelWidth: CGFloat = photoWidth * multiple
        let pixelHeight: CGFloat = pixelWidth / aspectRatio
        let imageSize = CGSize(width: pixelWidth, height: pixelHeight)

        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.resizeMode = .exact//exact和目标大小匹配
        var photo = UIImage()
        PHImageManager.default().requestImage(for: phAsset, targetSize: imageSize, contentMode: .aspectFill, options: option) { (result, info) in

            if result != nil{
                photo = result!
            }
            let dict = NSMutableDictionary(dictionary: info!)

            let isCancleKey = dict[PHImageCancelledKey] as? Bool
            let errorey = dict[PHImageErrorKey] ?? nil
            let downloadFinined: Bool = !(isCancleKey ?? false) && (errorey != nil)

            if downloadFinined && result != nil {
                let tmpImage = result
                completion(tmpImage, dict)
                return
            }

            if ((dict[PHImageResultIsInCloudKey] != nil) &&
                (result != nil) &&
                networkAccessAllowed){
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                options.resizeMode = .fast
                PHImageManager.default().requestImageData(for: phAsset, options: options, resultHandler: { (imageData, dataUIT, orientation, info) in
                    if imageData == nil{
                        completion(nil,dict)
                    }else{
                        var resultImage = UIImage(data: imageData!, scale: 0.1)
                        resultImage = self.scaleImageToNewSize(image: resultImage!, newSize: imageSize)
                        if resultImage == nil{
                            resultImage = photo
                        }
//                        resultImage = self.fixOrientation(aImage: resultImage)
                        completion(resultImage,dict)

                    }
                })
            }
            
        }
    }
    /// 修正图片转向
//    func fixOrientation(aImage:UIImage!) -> UIImage{
//
//        if aImage.imageOrientation == .up {
//            return aImage
//        }
//
//        var transform: CGAffineTransform = .identity
//
//        switch aImage.imageOrientation {
//        case .down, .downMirrored:
//            transform = transform.translatedBy(x: aImage.size.width, y: aImage.size.height)
//            transform = transform.rotated(by: .pi)
//        case .left, .leftMirrored:
//            transform = transform.translatedBy(x: aImage.size.width, y: 0)
//            transform = transform.rotated(by: CGFloat(Double.pi / 2))
//        case .right, .rightMirrored:
//            transform = transform.translatedBy(x: 0, y: aImage.size.height)
//            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
//        default:
//            break
//        }
//
//        switch aImage.imageOrientation {
//        case .upMirrored, .downMirrored:
//            transform = transform.translatedBy(x: aImage.size.width, y: 0)
//            transform = transform.scaledBy(x: -1, y: 1)
//        case .leftMirrored, .rightMirrored:
//            transform = transform.translatedBy(x: aImage.size.height, y: 0)
//            transform = transform.scaledBy(x: -1, y: 1)
//        default:
//            break
//        }
//        let ctx = CGContext(data: nil, width: Int(aImage.size.width), height: Int(aImage.size.height), bitsPerComponent: CGImageGetBitsPerComponent(aImage.cgImage!), bytesPerRow: 0, space: CGCClor, bitmapInfo: CGImageGetBitmapInfo(aImage.cgImage!).rawValue)
//
//        ctx?.concatenate(transform)
//        switch aImage.imageOrientation {
//        case .left, .leftMirrored, .right, .rightMirrored:
//            ctx?.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.height, height: aImage.size.width))
//        default:
//            ctx?.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.width, height: aImage.size.height))
//        }
//
//        let cgimg = ctx?.makeImage()
//        let img = UIImage(cgImage: cgimg!)
//
//        return img
//
//    }

    func scaleImageToNewSize(image:UIImage,newSize:CGSize) -> UIImage?{
        if image.size.width > newSize.width {
            UIGraphicsBeginImageContext(newSize)
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage ?? nil
        }else{
            return image
        }
    }

    func getImageFromAsset(asset:PHAsset,targetSize:CGSize,Result:@escaping(UIImage?,[AnyHashable:Any]?) ->Void) {
        let manager:PHCachingImageManager! = PHCachingImageManager()

        let imageRequestOption = PHImageRequestOptions()
        imageRequestOption.isSynchronous = false// 是否同步
        imageRequestOption.resizeMode = .none // 缩略图的压缩模式设置为无
        imageRequestOption.deliveryMode = .opportunistic// 缩略图的质量为高质量
        imageRequestOption.isNetworkAccessAllowed = true
        let tSize = targetSize == CGSize.zero ? PHImageManagerMaximumSize : targetSize
        manager.requestImage(for: asset, targetSize: tSize, contentMode: .default, options: imageRequestOption) { (image, ofo) in
            Result(image,ofo)

        }
    }
    
    func getImageDataFromAsset(asset:PHAsset,Result:@escaping(Data?,[AnyHashable:Any]?) ->Void) {
        let manager:PHCachingImageManager! = PHCachingImageManager()

        let imageRequestOption = PHImageRequestOptions()
        imageRequestOption.isSynchronous = false// 是否同步
        imageRequestOption.resizeMode = .none // 缩略图的压缩模式设置为无
        imageRequestOption.deliveryMode = .opportunistic// 缩略图的质量为高质量
        imageRequestOption.isNetworkAccessAllowed = true
        if #available(iOS 13, *) {
            manager.requestImageDataAndOrientation(for: asset, options: imageRequestOption) { (data, des, orientation, info) in
                Result(data,info)
            }
        } else {
            manager.requestImageData(for: asset, options: imageRequestOption) { (data, des, orientation, info) in
                Result(data,info)
            }
        }
    }
    
    func getLivePhotoFromAsset(asset:PHAsset,targetSize:CGSize,Result:@escaping(PHLivePhoto?,[AnyHashable:Any]?) ->Void){
        let manager:PHCachingImageManager! = PHCachingImageManager()
        let imageRequestOption = PHLivePhotoRequestOptions()
        imageRequestOption.deliveryMode = .opportunistic
        imageRequestOption.isNetworkAccessAllowed = true
        let tSize = targetSize == CGSize.zero ? PHImageManagerMaximumSize : targetSize
        manager.requestLivePhoto(for: asset, targetSize: tSize, contentMode: .default, options: imageRequestOption) { (livePhoto, info) in
            Result(livePhoto,info)
        }
    }
    
    func getVideoPlayerItem(asset:PHAsset,Result:@escaping(AVPlayerItem?,[AnyHashable:Any]??) ->Void){
        let videoManager = PHImageManager.default()
        let option = PHVideoRequestOptions()
        option.version = .current
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .automatic
        
        videoManager.requestPlayerItem(forVideo:asset, options: option) { (playerItem, info) in
            Result(playerItem,info)
        }
    }
    
    func getOriginalPhotoFromAsset(asset:PHAsset,Result:@escaping(UIImage?) ->Void) {
        
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.isNetworkAccessAllowed = true
        option.resizeMode = .none
        option.deliveryMode = .opportunistic
        PHImageManager().requestImage(for: asset, targetSize: CGSize(width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH), contentMode: .default, options: option) { (image, info) in
            
            Result(image)
        }
        
    }
}
