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
import AVFoundation

class CDSignalTon: NSObject {

    var CDLoginType = 0
    var basePwd = String()
    var userId:Int = 0
    var currentType:Int = 0
    var touchIDSwitch:Bool = false
    var fakeSwitch:Bool = false
    var isViewDisappearStopRecording = false
    var selectedVideos = NSMutableArray()
    var tmpDict = NSMutableDictionary()
    var customPickerView:UIViewController!
    var dirNavArr = NSMutableArray()
    
    static let instance:CDSignalTon = CDSignalTon()
    class func shareInstance()->CDSignalTon {
        objc_sync_enter(self)
        if isLogin() {

            instance.basePwd = CDSqlManager.instance().queryUserRealKeyWithUserId(userId: instance.userId)
        }else{
            let userInfo:CDUserInfo  = CDSqlManager.instance().queryOneUserInfoWithUserId(userId: FIRSTUSERID)
            if userInfo.userId == 0{
                userInfo.userId = FIRSTUSERID
                CDSqlManager.instance().addOneUserInfoWith(usernInfo: userInfo)
                CDConfigFile.setIntValueToConfigWith(key: CD_UserId, intValue: FIRSTUSERID)
                instance.userId = FIRSTUSERID
                instance.currentType = CDLoginReal
                createLibraryForUser()
                addDefaultSafeFolder()
                addDefaultMusicClass()

            }
            instance.fakeSwitch = CDConfigFile.getBoolValueFromConfigWith(key: CD_FakeType)
            instance.touchIDSwitch = CDConfigFile.getBoolValueFromConfigWith(key: CD_TouchId)

        }
        objc_sync_exit(self)
        return instance
    }


    func handleSaveVideoWith(assets:[CDPHAsset], folderId: Int) {

        selectedVideos = NSMutableArray(array: assets)
        handleSingleVideo(folderId: folderId)
    }

    func handleSingleVideo(folderId: Int) {
        if selectedVideos.count > 0 {
            let phAsset:CDPHAsset = selectedVideos.firstObject as! CDPHAsset
            let asset = phAsset.asset
            let filePath:NSString = phAsset.filePath as NSString
            let fileName = filePath.lastPathComponent

            CDAssetTon.instance.getAssetsInfo(withAsset:asset) { (info) in
                if info == nil{
                    DispatchQueue.main.async {
                        CDHUD.showText(text: "异常数据")
                    }
                    NotificationCenter.default.post(name: RefreshProgress, object: nil)
                    self.selectedVideos.removeObject(at: 0)
                    self.handleSingleVideo(folderId: folderId)
                }
                else if (info?["actionStop"] as! String == "YES"){
                    NotificationCenter.default.post(name: RefreshProgress, object: nil)
                    self.selectedVideos.removeObject(at: 0)
                    self.handleSingleVideo(folderId: folderId)
                }
                else{

                    let timeLength = info?["timeLength"] as! Double
                    let outputPath = info?["outputPath"] as! String
                    let time = info?["createTime"] as! Int
                    self.tmpDict.removeAllObjects()
                    self.tmpDict.setObject(timeLength, forKey: "timeLength" as NSCopying)
                    self.tmpDict.setObject(outputPath, forKey: "videoPath" as NSCopying)
                    self.tmpDict.setObject(time, forKey: "createTime" as NSCopying)
                    self.tmpDict.setObject(folderId, forKey: "folderId" as NSCopying)
                    self.tmpDict.setObject(fileName, forKey: "fileName" as NSCopying)

                    self.performSelector(onMainThread: #selector(self.saveToPathFinish(info:)), with: self.tmpDict, waitUntilDone: true)
                }

            }

        }else{
            NotificationCenter.default.post(name: DismissImagePicker, object: nil)
        }
    }
    @objc func saveToPathFinish(info:NSMutableDictionary){
        let timeLength = info["timeLength"]! as! Double
        let videoPath = info["videoPath"] as! String
        let fileName = info["fileName"] as! String
        let folderId = info["folderId"] as! Int
        let time = info["createTime"] as! Int
        let thump = String.thumpVideoPath().appendingPathComponent(str: "\(time).jpg")

        //第一帧
        let image = firstFrmaeWithTheVideo(videoPath: videoPath)
        let data = image.jpegData(compressionQuality: 1.0)
        do {
            try data?.write(to: URL(fileURLWithPath: thump))
        } catch  {

        }
        let fileInfo = CDSafeFileInfo()
        fileInfo.folderId = folderId
        fileInfo.userId = CDUserId()
        fileInfo.fileName = fileName
        fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: videoPath)
        fileInfo.thumbImagePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: thump)
        let fileSize = getFileSizeAtPath(filePath: videoPath)
        fileInfo.fileSize = fileSize
        fileInfo.timeLength = timeLength
        fileInfo.createTime = time
        fileInfo.fileType = .VideoType
        CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)
        NotificationCenter.default.post(name: RefreshProgress, object: nil)
        selectedVideos.removeObject(at: 0)
        handleSingleVideo(folderId: folderId)
    }
    func handleToSaveImage(image:UIImage,folderId:Int) {
        let time = getCurrentTimestamp()
        let savePath = String.ImagePath().appendingPathComponent(str: "\(time).jpg")
        let thumbPath = String.thumpImagePath().appendingPathComponent(str: "\(time).jpg")
        let smallImage = imageCompressForSize(image: image, maxWidth: 1280)
        do{
            let imageData = smallImage.jpegData(compressionQuality: 0.5)
            try imageData?.write(to: URL(fileURLWithPath: savePath))
        }catch{

        }

        let thumbImage = scaleImageAndCropToMaxSize(image: image, newSize: CGSize(width: 200, height: 200))
        let tmpData:Data = thumbImage.jpegData(compressionQuality: 1.0)! as Data

        do {
            try tmpData.write(to: URL(fileURLWithPath: thumbPath))
        } catch  {

        }
        let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
        fileInfo.folderId = folderId
        fileInfo.fileName = "未命名"
        fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: savePath)
        fileInfo.thumbImagePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: thumbPath)
        fileInfo.fileSize = getFileSizeAtPath(filePath: savePath)
        fileInfo.fileWidth = Double(image.size.width)
        fileInfo.fileHeight = Double(image.size.height)
        fileInfo.createTime = Int(time)
        fileInfo.fileType = .ImageType
        fileInfo.userId = CDUserId()
        CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)
    }

    func firstFrmaeWithTheVideo(videoPath:String) -> UIImage{
        let opts = [AVURLAssetPreferPreciseDurationAndTimingKey : NSNumber(value: false)]
        let urlAsset:AVURLAsset = AVURLAsset(url: URL(fileURLWithPath: videoPath), options: opts)
        let generator = AVAssetImageGenerator(asset: urlAsset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: CDSCREEN_WIDTH, height: CDViewHeight)
        let error: Error? = nil
        var imgRef: CGImage!
        do {
            imgRef = try generator.copyCGImage(at: CMTimeMake(value: 10, timescale: 10), actualTime: nil)
        } catch {
            print(" 0000 " + error.localizedDescription)
        }
        var image: UIImage!
        if error == nil {
            if let imgRef = imgRef {
                image = UIImage(cgImage: imgRef)
            }
        } else {
            image = UIImage(named: returnImgName(type: 8)!)
        }
        return image
    }
    @objc func imagesWithTheVideo(videoPath:String) -> [UIImage]{
        var imageArr:[UIImage] = []

        let url = URL(fileURLWithPath: videoPath)
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let thumbTime = CMTimeMakeWithSeconds(0, preferredTimescale: 1)
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: thumbTime)]) { (requestTime, cgImage, autualTime, result, error) in

            if cgImage != nil{
                let img = UIImage(cgImage: cgImage!)
                imageArr.append(img)
            }
            self.perform(#selector(self.imagesWithTheVideo(videoPath:)), on: .main, with: videoPath, waitUntilDone: true)
        }
        return imageArr
    }
    func returnImgName(type: Int) -> String? {
        var arr: [String] = [
            "file_dir_big",
            "file_audio_big",
            "file_image_big",
            "file_video_big",
            "url",
            "file_pdf_big",
            "file_ppt_big",
            "file_doc_big",
            "file_txt_big",
            "file_excel_big",
            "file_rtf_big",
            "file_image_big",
            "file_zip_big",
            "file_other_big"
        ]
        if type == 30 || type >= (arr.count) {
            return "file_other_big"
        }
        return arr[type]
    }


    func addWartMarkToWindow(appWindow:UIWindow) {
        let imageView = appWindow.viewWithTag(waterMarkTag) as? UIImageView
        if imageView != nil {
            appWindow.bringSubviewToFront(imageView!)
        }else{
//            waterMarkView =

        }


    }
    func setWaterToMark(view:NSObject, appWindow:UIWindow) -> UIImageView {
        let view = view as! UIView

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight))
        imageView.alpha = 0.3
//        imageView.image =
        imageView.isUserInteractionEnabled = false
        view.addSubview(imageView)
        return imageView



    }
//    func drawWaterMark(frame:CGRect) -> Void {
//        let viewHeight = frame.height
//        let viewWidth = frame.width
//        //为防止图片失真
//        UIGraphicsBeginImageContext(CGSize(width: viewWidth, height: viewHeight))
//        let sqrtLength = sqrt(viewWidth * viewWidth + viewHeight * viewHeight)
//
//        let mark = "墨凌风起"
//
//        let attrStr = NSMutableAttributedString(string: mark, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor:UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)])
//
//        //绘制文字宽高
//        let strWidth = attrStr.size().width
//        let strHeight = attrStr.size().height
//
//        let finalImg = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        CGContextRestoreGState(context)
//    }

    func removeWaterMarkFromWindow(window:UIWindow) -> Void{
        let imageView = window.viewWithTag(waterMarkTag) as! UIImageView
        imageView.removeFromSuperview()

    }


    func getMusicInfoFromMusicFile(filePath:String)-> MusicInfo{
        let url = URL(fileURLWithPath: filePath)
        let opts = [AVURLAssetPreferPreciseDurationAndTimingKey : NSNumber(value: false)]
        let urlAsset: AVURLAsset = AVURLAsset(url: url, options: opts)
        let time = Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale)

        var musicInfo = MusicInfo()
        musicInfo.length = time
        for format:AVMetadataFormat in urlAsset.availableMetadataFormats {
            for metadata:AVMetadataItem in urlAsset.metadata(forFormat: format){
                let key = metadata.commonKey?.rawValue
//                if key == "title"{ //歌名
//                    musicInfo.musicName = metadata.value as! String
//                }
//                else if key == "albumName"{ //专辑
//                    musicInfo.albumName = metadata.value as! String
//                }else
                if key == "artist"{   //歌手
                    musicInfo.artist = (metadata.value as! String)
                }else if key == "artwork"{  //图片
                    musicInfo.image = UIImage(data: metadata.value as! Data)!
                }

            }
        }
        return musicInfo
    }

}

@inline(__always) func StringWithUUID()->String{
    let uuidObj = CFUUIDCreate(nil)
    let uuidString = CFUUIDCreateString(nil, uuidObj) as String?
    return uuidString!
}
@inline(__always) func getFileSizeAtPath(filePath:String) ->Int{
    let manager = FileManager.default
    var fileSize:Int = 0
    if manager.fileExists(atPath: filePath) {
        do{
            let attr = try manager.attributesOfItem(atPath: filePath)
            fileSize = attr[FileAttributeKey.size] as! Int
        }catch{

        }
    }
    return fileSize
}

@inline(__always) func getFolderSizeAtPath(folderPath:String!) ->Int{
    var isDir:ObjCBool = false
    let manager = FileManager.default
    var fileSize:Int = 0
    if manager.fileExists(atPath: folderPath, isDirectory: &isDir) {
        if isDir.boolValue {
            let fileArr = manager.subpaths(atPath: folderPath)!
            for i in 0..<fileArr.count{
                let path = fileArr[i]
                fileSize = fileSize + getFileSizeAtPath(filePath: path)
            }
            return fileSize
        }
    }
    return getFileSizeAtPath(filePath: folderPath)
}
@inline(__always) func createLibraryForUser(){
    _ = String.ImagePath()
    _ = String.AudioPath()
    _ = String.VideoPath()
    _ = String.OtherPath()
    _ = String.MusicPath()
}
@inline(__always) func isLogin()->Bool{
    let isLogin = CDConfigFile.getValueFromConfigWith(key: CD_IsLogin)
    if isLogin == "NO" || isLogin == ""{
        return false
    }else{
        return true
    }
}
@inline(__always) func CDUserId() -> Int{
    let userId = CDConfigFile.getIntValueFromConfigWith(key: CD_UserId)
    return userId
}
@inline(__always) func deleteLibraryForUser(){
    String.deleteLibraryUserdataPath()
}

@inline(__always) func addDefaultSafeFolder() -> Void {
    let nameArr:[String] = Array(arrayLiteral: "图片文件", "音频文件","视频文件","文本文件")
    
    for i in 0..<nameArr.count {
        let nowTime = getCurrentTimestamp()
        let createtime:Int = nowTime;
        let folderInfo = CDSafeFolder()
        folderInfo.folderName = nameArr[i]
        folderInfo.folderType = NSFolderType(rawValue: i)
        folderInfo.isLock = LockOff
        folderInfo.identify  = 1
        folderInfo.createTime = Int(createtime)
        folderInfo.userId = CDUserId()
        folderInfo.superId = ROOTSUPERID//-2默认文件夹，-1默认文件夹下子文件
        _ = CDSqlManager.instance().addSafeFoldeInfo(folder: folderInfo)
    }
}

@inline(__always) func addDefaultMusicClass() {
    let titleArr:[String] = Array(arrayLiteral: "最喜欢", "最近播放","乐库")
    let imageArr:[String] = Array(arrayLiteral: "music_love", "music_recent","music_list")
    for i in 0..<titleArr.count {
        let nowTime = getCurrentTimestamp()
        let createtime:Int = nowTime;
        let classInfo = CDMusicClassInfo()
        classInfo.className = titleArr[i]
        classInfo.classId = i + 1
        classInfo.classAvatar = imageArr[i]
        classInfo.classCreateTime = Int(createtime)
        classInfo.userId = CDUserId()
        CDSqlManager.instance().addOneMusicClassInfoWith(classInfo: classInfo)

    }
}
@inline(__always) func JudgeStringIsEmpty(string:String) -> Bool {
    if string == "" ||
        string.count == 0{
        return true
    }else{
        return false
    }
}

@inline(__always) func LoadImageByName(imageName:String,type:String) -> UIImage {
    var path = Bundle.main.path(forResource:imageName, ofType:type)
    if path == nil{
        let name = imageName + "@2x"
        path = Bundle.main.path(forResource:name, ofType:type)
    }
    let image = UIImage(contentsOfFile: path!)
    return image!
}

@inline(__always) func createTextFiled(placeholder:String,frame:CGRect) -> UITextField{
    let textFiled = UITextField(frame: frame)
    textFiled.placeholder = placeholder
    textFiled.contentVerticalAlignment = .center
    textFiled.textColor = TextDarkBlackColor
    textFiled.font = TextMidFont
    textFiled.backgroundColor = UIColor.clear
    return textFiled
}
@inline(__always) func GetDocumentPath()->String{

    let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    return docPath
}

@inline(__always) func fileManagerDeleteFileWithFilePath(filePath:String){
    let manager = FileManager.default
    if manager.fileExists(atPath: filePath) {
        do{
            try manager.removeItem(atPath: filePath)
        }catch{
            
        }
    }
}
@inline(__always) func scaleImageAndCropToMaxSize(image:UIImage,newSize:CGSize) ->UIImage {
    let largestSize = newSize.width > newSize.height ? newSize.width : newSize.height
    var imageSize:CGSize = image.size
    var ratio:CGFloat = 0
    if imageSize.width > imageSize.height{
        ratio = largestSize/imageSize.height
    }else{
        ratio = largestSize/imageSize.width
    }
    let rect = CGRect(x: 0.0, y: 0.0, width: ratio * imageSize.width, height: ratio * imageSize.height)
    UIGraphicsBeginImageContext(rect.size)
    image.draw(in: rect)

    let scaleImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    var offSetX:CGFloat = 0
    var offSetY:CGFloat = 0

    imageSize = scaleImage.size
    if imageSize.width < imageSize.height {
        offSetY = (imageSize.height / 2) - (imageSize.width / 2)
    }else{
        offSetX = (imageSize.width / 2) - (imageSize.height / 2)
    }


    let corpRect = CGRect(x: offSetX, y: offSetY, width: imageSize.width - offSetX * 2, height: imageSize.height - offSetY * 2)

    let sourceImageRef:CGImage = scaleImage.cgImage!
    let croppedImageRef:CGImage = sourceImageRef.cropping(to: corpRect)!
    let newImage = UIImage(cgImage: croppedImageRef)
    UIGraphicsEndImageContext()
    return newImage
}

@inline(__always)func getMMSSFromSS(second:Double)->String{
    let hour = Int(second / 3600)
    let minute = (Int(second) % 3600)/3600
    let second = Int(second) % 60
    var format:String = ""
    if hour > 0 {
        format = String.init(format: "%02ld:%02ld:%02ld", hour,minute,second)
    }else{
        format = String.init(format: "%02ld:%02ld", minute,second)
    }
    return format
}


@inline(__always)func getLengthOfStr(text: String, needTrimSpaceCheck: Bool) -> Int {
    if needTrimSpaceCheck {
        let realText = removeSpaceAndNewline(str: text)
        if 0 == realText.count {
            return 0
        }
    }

    var len = 0
    for scalar in text.unicodeScalars {
        if scalar.value > 0 && scalar.value < 127{
            len += 1
        }else{
            len += 2
        }
    }
    return len
}

@inline(__always)func removeSpaceAndNewline(str:String)->String{
    let text = str.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    return text

}

@inline(__always)func getRandString() -> String? {
    let NUMBER_OF_CHARS: Int = 32
    let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    var ranStr = ""
    for _ in 0..<NUMBER_OF_CHARS {
        let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
        ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
    }
    return ranStr
}

@inline(__always)func getTimeLenWithVideoPath(path:String)->Double{
    let urlAsset = AVURLAsset(url: URL(fileURLWithPath: path))
    let second = Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale)
    return second
}
@inline(__always)func canPlayRecord(filePath:String)->Bool{

    let freeDiskSpace = getFreeDiskSpace() - 300 * 1024 * 1024.0
    let recordSpace = getFileSizeAtPath(filePath: filePath)
    if Int(freeDiskSpace) > Int(recordSpace) {
        return true
    }else{
        return false
    }
}
@inline(__always)func getFreeDiskSpace() ->Double{
    return 100.0
}

@inline(__always)func returnSize(fileSize:Int)->String{
    var sizeStr = ""
    var sizef = Float(fileSize)
    var i = 0
    while sizef >= 1024 {
        sizef = sizef / 1024.0
        i += 1
    }
    switch i {
    case 0:
        sizeStr = String(format: "%.2ldB", sizef)
    case 1:
        sizeStr = String(format: "%.2lfK", sizef)
    case 2:
        sizeStr = String(format: "%.2lfM", sizef)
    case 3:
        sizeStr = String(format: "%.2lfG", sizef)
    case 4:
        sizeStr = String(format: "%.2lfT", sizef)
    default:
        sizeStr = ""
    }
    return sizeStr
}

@inline(__always)func getCurrentTimestamp() -> Int{
    let nowTime = NSDate.init().timeIntervalSince1970 * 1000
    return Int(nowTime)
}
@inline(__always)func timestampTurnString(timestamp:Int)->String{
    let formter = DateFormatter()
    formter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp/1000))
    let dateStr = formter.string(from: date)
    return dateStr
}
@inline(__always)func getVideoPreviewImage(videoUrl:URL) -> UIImage {
    let avAsset = AVAsset(url: videoUrl)
    let generator = AVAssetImageGenerator(asset: avAsset)
    generator.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
    var actualTime:CMTime = CMTimeMake(value: 0, timescale: 0)
    let imageRef:CGImage = try! generator.copyCGImage(at: time, actualTime: &actualTime)
    let image = UIImage(cgImage: imageRef)

    return image
}
@inline(__always)func checkFileTypeWithExternString(externStr:String)-> NSFileType{
    if (externStr.uppercased() == "PDF") ||
        (externStr.uppercased() == "PDFX") {
        return .PdfType
    } else if (externStr.uppercased() == "PPT") ||
        (externStr.uppercased() == "PPTX") ||
        (externStr.uppercased() == "KEY") {
        return .PptType
    } else if (externStr.uppercased() == "DOC") ||
        (externStr.uppercased() == "DOCX") ||
        (externStr.uppercased() == "DOCUMENT") ||
        (externStr.uppercased() == "PAGES") {
        return .DocType
    }else if (externStr.uppercased() == "TXT") {
        return .TxtType
    } else if (externStr.uppercased() == "XLS") ||
        (externStr.uppercased() == "XLSX") ||
        (externStr.uppercased() == "NUMBERS") {
        return .ExclType
    } else if (externStr.uppercased() == "RTF") {
        return .RtfType
    } else if (externStr.uppercased() == "GIF") {
        return .GifType
    }else if (externStr.uppercased() == "PNG") ||
        (externStr.uppercased() == "JPG") ||
        (externStr.uppercased() == "TIF") ||
        (externStr.uppercased() == "JPEG") ||
        (externStr.uppercased() == "BMP") ||
        (externStr.uppercased() == "PCD") ||
        (externStr.uppercased() == "MAC") ||
        (externStr.uppercased() == "PCX") ||
        (externStr.uppercased() == "DXF") ||
        (externStr.uppercased() == "CDR") ||
        (externStr.uppercased() == "HEIC"){
        return .ImageType
    }else if (externStr.uppercased() == "MP3") ||
        (externStr.uppercased() == "WAV") ||
        (externStr.uppercased() == "CAF") ||
        (externStr.uppercased() == "CDA") ||
        (externStr.uppercased() == "MID") ||
        (externStr.uppercased() == "RAM") ||
        (externStr.uppercased() == "RMX") ||
        (externStr.uppercased() == "VQF") ||
        (externStr.uppercased() == "AIF") ||
        (externStr.uppercased() == "AIFF") ||
        (externStr.uppercased() == "SND") ||
        (externStr.uppercased() == "SVX") ||
        (externStr.uppercased() == "VOC") ||
        (externStr.uppercased() == "AMR") ||
        (externStr.uppercased() == "M4A") ||/*add_cd 系统录音 */
        (externStr.uppercased() == "M4R") {
    return .AudioType
    }else if (externStr.uppercased() == "MOV") ||
        (externStr.uppercased() == "MP4") ||
        (externStr.uppercased() == "AVI") ||
        (externStr.uppercased() == "MPG") ||
        (externStr.uppercased() == "M2V") ||
        (externStr.uppercased() == "VOB") ||
        (externStr.uppercased() == "ASF") ||
        (externStr.uppercased() == "WMF") ||
        (externStr.uppercased() == "RMVB") ||
        (externStr.uppercased() == "RM") ||
        (externStr.uppercased() == "DIVX") ||
        (externStr.uppercased() == "MKV") {
        return .VideoType
    }else if (externStr.uppercased() == "ZIP") ||
        (externStr.uppercased() == "RAR") ||
        (externStr.uppercased() == "7-ZIP") ||
        (externStr.uppercased() == "ACE") ||
        (externStr.uppercased() == "ARJ") ||
        (externStr.uppercased() == "BV2") ||
        (externStr.uppercased() == "CAD") ||
        (externStr.uppercased() == "GZIP") ||
        (externStr.uppercased() == "ISO") ||
        (externStr.uppercased() == "JAR") ||
        (externStr.uppercased() == "LZH") ||
        (externStr.uppercased() == "TAR") ||
        (externStr.uppercased() == "UUE") ||
        (externStr.uppercased() == "XZ") {
        return .ZipType
    } else {
        return .OtherType
    }


}

@inline(__always)func imageCompressForSize(image:UIImage,maxWidth:CGFloat) -> UIImage{
    // 宽高比
    var ratio: CGFloat = image.size.width / image.size.height
    // 目标大小
    var targetW: CGFloat = maxWidth
    var targetH: CGFloat = maxWidth

    // 宽高均 <= 1280，图片尺寸大小保持不变
    if image.size.width < maxWidth && image.size.height < maxWidth {
        return image
    }
        // 宽高均 > 1280 && 宽高比 > 2，
    else if image.size.width > maxWidth && image.size.height > maxWidth {

        // 宽大于高 取较小值(高)等于1280，较大值等比例压缩
        if ratio > 1 {
            targetH = maxWidth
            targetW = targetH * ratio
        }
// 高大于宽 取较小值(宽)等于1280，较大值等比例压缩 (宽高比在0.5到2之间 )
        else {
            targetW = maxWidth
            targetH = targetW / ratio
        }
    }else{// 宽或高 > 1280
        if ratio > 2 { // 宽图 图片尺寸大小保持不变
            targetW = image.size.width
            targetH = image.size.height
        } else if ratio < 0.5 {  // 长图 图片尺寸大小保持不变
            targetW = image.size.width
            targetH = image.size.height
        } else if ratio > 1 { // 宽大于高 取较大值(宽)等于1280，较小值等比例压缩
            targetW = maxWidth
            targetH = targetW / ratio
        } else { // 高大于宽 取较大值(高)等于1280，较小值等比例压缩
            targetH = maxWidth
            targetW = targetH * ratio
        }
    }
    UIGraphicsBeginImageContext(CGSize(width: targetW, height: targetH))
    image.draw(in: CGRect(x: 0, y: 0, width: targetW, height: targetH))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!

}

@inline(__always) func stringContainsEmoji(string:String) -> Bool {
    var returnValue = false
    let nsStr = string as NSString

    nsStr.enumerateSubstrings(in: NSRange(location: 0, length: string.count), options: .byComposedCharacterSequences) { (substring, substringRange, enclosingRange, stop) in
        let nsSub = substring! as NSString

        let hs = unichar(nsSub.character(at: 0))
        // surrogate pair
        if 0xd800 <= hs && hs <= 0xdbff {
            if nsSub.length > 1 {
                let ls = unichar(nsSub.character(at: 1))
                let uc = (Int((hs - 0xd800)) * 0x400) + Int((ls - 0xdc00)) + 0x10000
                if 0x1d000 <= uc && uc <= 0x1f77f {
                    returnValue = true
                }
            }else if nsSub.length > 1 {
                let ls = unichar(nsSub.character(at: 1))
                if ls == 0x20e3 {
                    returnValue = true
                }
            }else{
                if 0x2100 <= hs && hs <= 0x27ff {
                    returnValue = true
                } else if 0x2b05 <= hs && hs <= 0x2b07 {
                    returnValue = true
                } else if 0x2934 <= hs && hs <= 0x2935 {
                    returnValue = true
                } else if 0x3297 <= hs && hs <= 0x3299 {
                    returnValue = true
                } else if hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50 {
                    returnValue = true
                }

            }
        }
    }
    return returnValue;
}


@inline(__always) func imageFormatForImageData(data:NSData) ->SDImageFormat{
    var c: UInt8?
    data.getBytes(&c, length: 1)
    switch c {
    case 0xff:
        return SDImageFormat.SDImageFormatJPEG
    case 0x89:
        return SDImageFormat.SDImageFormatPNG;
    case 0x47:
        return SDImageFormat.SDImageFormatGIF;
    case 0x49,0x4D:
        return SDImageFormat.SDImageFormatTIFF;
    case 0x52:
        if data.length > 12{
            let string = String(data: data.subdata(with: NSRange(location: 0, length: 12)), encoding: String.Encoding.ascii)!
            if (string.hasPrefix("PIFF") &&
                string.hasSuffix("WEBP")){
                return SDImageFormat.SDImageFormatWebP;
            }
        }
    case 0x00:
        if data.length > 12{
            let string = String(data: data.subdata(with: NSRange(location: 4, length: 8)), encoding: String.Encoding.ascii)!
            if (string == "ftypheic" ||
                string == "WEBP" ||
                string == "ftyphevc" ||
                string == "ftyphevx"){
                return SDImageFormat.SDImageFormatHEIC;
            }
        }
    default:
        return SDImageFormat.SDImageFormatUndefined;
    }
    return SDImageFormat.SDImageFormatUndefined;
}


