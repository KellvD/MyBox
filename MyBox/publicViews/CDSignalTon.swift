//
//  CDSignalTon.swift
//  MyRule
//
//  Created by changdong on 2018/11/12.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics.CGImage
import Photos
import CoreLocation

class CDSignalTon: NSObject,CLLocationManagerDelegate {

    var basePwd = String() //
    var userId:Int = 0
    var loginType:CDLoginType!
    var touchIDSwitch:Bool = false //touch ID开关
    var fakeSwitch:Bool = false  //访客开关
    var isViewDisappearStopRecording = false
    var tmpDict = NSMutableDictionary()
    var customPickerView:UIViewController! //记录present的页面，程序进入后台时dismiss掉
    var dirNavArr = NSMutableArray()
    var waterBean:CDWaterBean!
    var tab:CDTabBarViewController!
    var navigationBar:CDNavigationController!
    var locationManager:CLLocationManager!
    var shareType:String!
    static let shared = CDSignalTon()
    private override init() {
        super.init()
        if isFirstInstall() {//首次登陆需要创建文件夹等等
            //写入文件
            userId = FIRSTUSERID
            CDConfigFile.setIntValueToConfigWith(key: .userId, intValue: userId)
            //登录模式
            loginType = .real
            //创建默认沙盒文件夹
            createLibraryForUser()
            //创建默认界面文件夹
            addDefaultSafeFolder()
            //创建音频
            addDefaultMusicClass()
            //配置水印
            CDWaterBean.setWaterConfig(isOn: false, text: GetAppName())
            
            CDConfigFile.setOjectToConfigWith(key: .firstInstall, value: "YES")
        }else{
            basePwd = CDSqlManager.shared.queryUserRealKeyWithUserId(userId: userId)
        }
        
        loginType = .real
        //初始化开关
        fakeSwitch = CDConfigFile.getBoolValueFromConfigWith(key: .fakeSwi)
        touchIDSwitch = CDConfigFile.getBoolValueFromConfigWith(key: .touchIdSwi)
        
        waterBean = CDWaterBean()
        NotificationCenter.default.addObserver(self, selector: #selector(onObserverTheme), name: NSNotification.Name(rawValue: "changeAppTheme"), object: nil)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
    }
    /**
    添加沙盒文件夹
    */
    func addDefaultSafeFolder() -> Void {
        let nameArr:[String] = ["图片文件".localize, "音频文件".localize,"视频文件".localize,"文本文件".localize]
        let pathArr:[String] = [String.ImagePath(),String.AudioPath(),String.VideoPath(),String.OtherPath()]
        for i in 0..<nameArr.count {
            let nowTime = GetTimestamp(nil)
            let createtime:Int = nowTime;
            let folderInfo = CDSafeFolder()
            folderInfo.folderName = nameArr[i]
            folderInfo.folderType = NSFolderType(rawValue: i)
            folderInfo.isLock = LockOff
            folderInfo.fakeType = .visible
            folderInfo.createTime = Int(createtime)
            folderInfo.modifyTime = Int(createtime)
            folderInfo.folderPath = pathArr[i].relativePath
            folderInfo.userId = CDUserId()
            folderInfo.superId = ROOTSUPERID//-2默认文件夹，-1默认文件夹下子文件
            _ = CDSqlManager.shared.addSafeFoldeInfo(folder: folderInfo)
        }
    }
    
    /**
    添加沙盒文件夹
    */
    func createLibraryForUser(){
        _ = String.ImagePath()
        _ = String.AudioPath()
        _ = String.VideoPath()
        _ = String.OtherPath()
        _ = String.MusicPath()
    }
    
    /**
    添加默认音乐类别
    */
    func addDefaultMusicClass() {
        let titleArr:[String] = Array(arrayLiteral: "最喜欢", "最近播放","乐库")
        let imageArr:[String] = Array(arrayLiteral: "music_love", "music_recent","music_list")
        for i in 0..<titleArr.count {
            let nowTime = GetTimestamp(nil)
            let createtime:Int = nowTime;
            let classInfo = CDMusicClassInfo()
            classInfo.className = titleArr[i]
            classInfo.classId = i + 1
            classInfo.classAvatar = imageArr[i]
            classInfo.classCreateTime = Int(createtime)
            classInfo.userId = CDUserId()
            CDSqlManager.shared.addOneMusicClassInfoWith(classInfo: classInfo)

        }
    }
    
    /**
    保存文件
    */
    func saveFileWithUrl(fileUrl:URL,folderId:Int,subFolderType:NSFolderType,isFromDocment:Bool){
        let tmpFilePath = isFromDocment ? fileUrl.absoluteString : fileUrl.path
        let fileName = tmpFilePath.fileName
        let suffix = tmpFilePath.suffix
        var contentData = Data()
        //保存数据到临时data
        do {
            try contentData = Data(contentsOf: fileUrl)
        } catch  {
            print("saveFileWithUrl Fail :\(error.localizedDescription)")
            return
        }
        if contentData.count <= 0 {
            print("saveFileWithUrl Fail :Content is nil")
            return;
        }
        //拍照，合成Gif等操作将文件预先保存在本地，在此处将文件读到data临时存放，删除原本地文件，统一在下面按照格式化路径入库
        if FileManager.default.fileExists(atPath: tmpFilePath) {
            try! FileManager.default.removeItem(atPath: tmpFilePath)
        }
        
        let fileType = suffix.fileType
        let currentTime = GetTimestamp(nil)
        let fileInfo = CDSafeFileInfo()
        fileInfo.folderId = folderId
        fileInfo.userId = CDUserId()
        fileInfo.fileName = fileName
        fileInfo.importTime = currentTime
        fileInfo.modifyTime = currentTime
        fileInfo.fileType = fileType
        fileInfo.folderType = subFolderType
        var filePath:String!

        if subFolderType == .ImageFolder{
            filePath = String.ImagePath().appendingPathComponent(str: "\(currentTime).\(suffix)")
            try! contentData.write(to: filePath.url)
            let thumbPath = String.thumpImagePath().appendingPathComponent(str: "\(currentTime).\(suffix)")
            let image = UIImage(data: contentData)!
            let thumbImage = image.scaleAndCropToMaxSize(newSize: CGSize(width: 200, height: 200))
            let data = thumbImage.jpegData(compressionQuality: 0.5)
            try! data?.write(to: thumbPath.url)
            fileInfo.fileWidth = Double(image.size.width)
            fileInfo.fileHeight = Double(image.size.height)
            fileInfo.thumbImagePath = thumbPath.relativePath
        }else if subFolderType == .AudioFolder || subFolderType == .VideoFolder{
            if subFolderType == .VideoFolder{
                filePath = String.VideoPath().appendingPathComponent(str: "\(currentTime).\(suffix)")
                try! contentData.write(to: filePath.url)
                let thumbPath = String.thumpVideoPath().appendingPathComponent(str: "\(currentTime).jpg")
                let image = UIImage.previewImage(videoUrl: filePath.url)
                let data = image.jpegData(compressionQuality: 0.5)
                try! data?.write(to: thumbPath.url)
                fileInfo.thumbImagePath = thumbPath.relativePath
            }else{
                filePath = String.AudioPath().appendingPathComponent(str: "\(currentTime).\(suffix)")
                try! contentData.write(to: filePath.url)
            }
            fileInfo.timeLength = GetVideoLength(path: filePath)
        }else{
            filePath = String.OtherPath().appendingPathComponent(str: "\(fileName).\(suffix)")
            try! contentData.write(to: filePath.url)
        }
        let fileAttribute = filePath.fileAttribute
        fileInfo.fileSize = fileAttribute.fileSize
        fileInfo.createTime = fileAttribute.createTime
        fileInfo.filePath = filePath.relativePath
        CDSqlManager.shared.addSafeFileInfo(fileInfo: fileInfo)
        print("OK")
    }
    
    /**
     保存原始图片
     */
    func saveOrigialImage(obj:Dictionary<String,Any?>,folderId:Int) {
        let fileName = obj["fileName"] as! String
        let imageType = obj["imageType"] as! String
        let createTime = obj["createTime"] as! Int
        let location = obj["location"] as? CLLocation
        
        let suffix = fileName.suffix
        let fileType = suffix.fileType
        
        let importTime = GetTimestamp(nil)
        let savePath = String.ImagePath().appendingPathComponent(str: "\(importTime).\(suffix)")
        let thumbPath = String.thumpImagePath().appendingPathComponent(str: "\(importTime).\(suffix)")
        
//        var photo:PHLivePhoto!
        var image:UIImage
        if imageType == "gif"{
            let data = obj["file"] as! Data
            image = UIImage(data: data)!
            do{
                try data.write(to: savePath.url)
            }catch{
                return
            }
        }else{
            
            image = obj["file"] as! UIImage
            let smallImage = image.compress(maxWidth: 1280)
            do{
                let imageData = smallImage.jpegData(compressionQuality: 0.5)
                try imageData?.write(to: savePath.url)
            }catch{
                return
            }
            
        }
        
        
        //缩略图
        let thumbImage = image.scaleAndCropToMaxSize(newSize: CGSize(width: 200, height: 200))
        let tmpData = thumbImage.jpegData(compressionQuality: 1.0)! as Data
        do {
            try tmpData.write(to: thumbPath.url)
        } catch  {
            return
        }
        let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
        fileInfo.folderId = folderId
        fileInfo.fileName = fileName.removeSuffix()
        fileInfo.filePath = savePath.relativePath
        fileInfo.thumbImagePath = thumbPath.relativePath
        let fileAttribute = savePath.fileAttribute
        fileInfo.fileSize = fileAttribute.fileSize
        fileInfo.fileWidth = Double(image.size.width)
        fileInfo.fileHeight = Double(image.size.height)
        fileInfo.createTime = createTime
        fileInfo.importTime = importTime
        fileInfo.modifyTime = importTime
        fileInfo.fileType = fileType
        
        fileInfo.userId = CDUserId()
        fileInfo.folderType = .ImageFolder
        CDLocationManager.shared.reverseGeocode(oTocation: location) { locationStr in
            fileInfo.createLocation = locationStr
            CDSqlManager.shared.addSafeFileInfo(fileInfo: fileInfo)
        }
        
    }
    
    func savePlainText(content:String,folderId:Int){
        let fileName = content.count > 6 ? content.subString(to: 6) : content
        let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
        fileInfo.userId = CDUserId()
        fileInfo.folderId = folderId
        fileInfo.fileName = fileName
        fileInfo.fileText = content
        fileInfo.importTime = GetTimestamp(nil)
        fileInfo.createTime = GetTimestamp(nil)
        fileInfo.modifyTime = GetTimestamp(nil)
        fileInfo.folderType = .TextFolder
        fileInfo.fileType = .PlainTextType
        CDSqlManager.shared.addSafeFileInfo(fileInfo: fileInfo)
    }
    
    func saveUrl(url:String,title:String,folderId:Int){
        let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
        fileInfo.userId = CDUserId()
        fileInfo.folderId = folderId
        fileInfo.fileName = title
        fileInfo.fileText = url
        fileInfo.importTime = GetTimestamp(nil)
        fileInfo.createTime = GetTimestamp(nil)
        fileInfo.modifyTime = GetTimestamp(nil)
        fileInfo.folderType = .TextFolder
        fileInfo.fileType = .htmlType
        CDSqlManager.shared.addSafeFileInfo(fileInfo: fileInfo)
    }
    
    /**
     获取视频的每一帧图像
    */
    @objc func getVideoAllFrame(videoPath:String) -> [UIImage]{
        var imageArr:[UIImage] = []

        let url = videoPath.url
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let thumbTime = CMTimeMakeWithSeconds(0, preferredTimescale: 1)
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: thumbTime)]) { (requestTime, cgImage, autualTime, result, error) in

            if cgImage != nil{
                let img = UIImage(cgImage: cgImage!)
                imageArr.append(img)
            }
            self.perform(#selector(self.getVideoAllFrame(videoPath:)), on: .main, with: videoPath, waitUntilDone: true)
        }
        return imageArr
    }
    

    /**
     添加水印
    */
    func addWartMarkToWindow(appWindow:UIWindow) {
        var imageView = appWindow.viewWithTag(waterMarkTag) as? UIImageView
        if imageView != nil {
            appWindow.bringSubviewToFront(imageView!)
        }else{
            imageView = setWaterToMark(window: appWindow, text: waterBean.text, textColor: waterBean.color)
            imageView?.tag = waterMarkTag
            appWindow.bringSubviewToFront(imageView!)
        }
    }
    /**
     更新水印
    */
    func updateWaterMarkViewFromWindow(window:UIWindow){
        removeWaterMarkFromWindow(window: window)
        let imageView = setWaterToMark(window: window, text: waterBean.text, textColor: waterBean.color)
        imageView.tag = waterMarkTag
        window.bringSubviewToFront(imageView)
    }
    
    /**
     移除水印
    */
    func removeWaterMarkFromWindow(window:UIWindow) -> Void{
        let imageView = window.viewWithTag(waterMarkTag) as? UIImageView
        if imageView != nil {
            imageView?.removeFromSuperview()
        }

    }
    
    /**
     设置水印
    */
    let HORIZONTAL_SPACE:CGFloat = 30.0//水平间距
    let VERTICAL_SPACE:CGFloat = 50.0//竖直间距
    func setWaterToMark(window:UIWindow,text:String,textColor:UIColor) -> UIImageView {
        
        func drawWaterMark(frame:CGRect,text:String,color:UIColor) -> UIImage {
            let viewHeight = frame.height
            let viewWidth = frame.width
            //为防止图片失真,绘制图片和原始图片宽高一致
            UIGraphicsBeginImageContext(CGSize(width: viewWidth, height: viewHeight))
            let sqrtLength = sqrt(viewWidth * viewWidth + viewHeight * viewHeight)

            let attr = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),
                        NSAttributedString.Key.foregroundColor:color]
            
            let attrStr = NSMutableAttributedString(string: text, attributes: attr)

            //绘制文字宽高
            let strWidth = attrStr.size().width
            let strHeight = attrStr.size().height

            //开始旋转上下文矩阵，绘制水印文字
            let context = UIGraphicsGetCurrentContext()
            //将绘制原点调整到image中心
            context?.concatenate(CGAffineTransform(translationX: viewWidth/2, y: viewHeight/2))
            //以绘制圆点为中心旋转
            context?.concatenate(CGAffineTransform(rotationAngle: CGFloat(-(Double.pi/2 / 3))))
            context?.concatenate(CGAffineTransform(translationX: -viewWidth/2, y: -viewHeight/2))
            
            let horCount = sqrtLength / (strWidth + HORIZONTAL_SPACE) + 1
            let verCount = sqrtLength / (strHeight + VERTICAL_SPACE) + 1
            
            //
            let orignX = -(sqrtLength - viewWidth)/2
            let orignY = -(sqrtLength - viewHeight)/2
            var tempOrignX = orignX
            var tempOrignY = orignY
            for i in 0..<Int(horCount * verCount) {
                (text as NSString).draw(in: CGRect(x: tempOrignX, y: tempOrignY, width: strWidth, height: strHeight), withAttributes: attr)
                if i % Int(horCount) == 0 && i != 0 {
                    tempOrignX = orignX
                    tempOrignY += (strHeight + VERTICAL_SPACE)
                } else {
                    tempOrignX += (strWidth + HORIZONTAL_SPACE)
                }
            }
            
            let finalImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            context?.restoreGState()
            return finalImg!
            
            
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        imageView.alpha = 0.3
        imageView.image = drawWaterMark(frame: imageView.frame, text: text, color: textColor)
        imageView.isUserInteractionEnabled = false
        window.addSubview(imageView)
        return imageView
    }
    
//    /**
//     音频文件获取音频信息
//    */
//    func getMusicInfoFromMusicFile(filePath:String)-> MusicInfo{
//        let url = filePath.url
//        let opts = [AVURLAssetPreferPreciseDurationAndTimingKey : NSNumber(value: false)]
//        let urlAsset: AVURLAsset = AVURLAsset(url: url, options: opts)
//        let time = Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale)
//
//        var musicInfo = MusicInfo()
//        musicInfo.length = time
//        for format:AVMetadataFormat in urlAsset.availableMetadataFormats {
//            for metadata:AVMetadataItem in urlAsset.metadata(forFormat: format){
//                let key = metadata.commonKey?.rawValue
////                if key == "title"{ //歌名
////                    musicInfo.musicName = metadata.value as! String
////                }
////                else if key == "albumName"{ //专辑
////                    musicInfo.albumName = metadata.value as! String
////                }else
//                if key == "artist"{   //歌手
//                    musicInfo.artist = (metadata.value as! String)
//                }else if key == "artwork"{  //图片
//                    musicInfo.image = UIImage(data: metadata.value as! Data)!
//                }
//
//            }
//        }
//        return musicInfo
//    }

    /**
     音频拼接
    */
    func appendAudio(folderId:Int,appendFile:[CDSafeFileInfo],Complete:@escaping(_ success:Bool)->Void){
        let nowTime = GetTimestamp(nil)
        //导出路径
        let composePath = String.AudioPath().appendingPathComponent(str: "\(nowTime).m4a")
        let composition = AVMutableComposition()
        var lastAsset:AVURLAsset!
        for index in 0..<appendFile.count {
            let tmpFile = appendFile[index]
            let tmpPath = String.RootPath().appendingPathComponent(str: tmpFile.filePath)
            let audioAsset = AVURLAsset(url: tmpPath.url)
            let audioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)!
            let audioAssetTrack = audioAsset.tracks(withMediaType: .audio).first
        
            do{
                if index == 0{// 第0个拼接自己本身
                    try audioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAsset.duration), of: audioAssetTrack!, at: CMTime.zero)
                }else{
                    try audioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAsset.duration), of: audioAssetTrack!, at: lastAsset.duration)

                }
                lastAsset = audioAsset
            }catch{

            }
            
        }
        let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        session?.outputURL = composePath.url
        session?.outputFileType = .m4a
        session?.shouldOptimizeForNetworkUse = true //优化网络
        session?.exportAsynchronously(completionHandler: {
            if session?.status == AVAssetExportSession.Status.completed{
                self.saveFileWithUrl(fileUrl: composePath.url, folderId: folderId, subFolderType: .AudioFolder,isFromDocment: false)
                Complete(true)
            }else{
                Complete(false)
            }
        })
    }
    
    @objc func onObserverTheme(){
        if GetAppThemeSwi() {
            //跟随系统
        }else{
            let applicate = UIApplication.shared.delegate as! CDAppDelegate
            if GetThemeMode() == .Nomal {
                //普通模式
                applicate.window?.backgroundColor = .lightGray
            }else{
                //深色模式
                
                applicate.window?.backgroundColor = .darkGray
            }
        }
    }
    
    
    
}





