//
//  CDInlineTools.swift
//  MyBox
//
//  Created by changdong  on 2020/7/6.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
@inline(__always) func isFirstInstall() ->Bool{
    let flag = CDConfigFile.getValueFromConfigWith(key: .firstInstall)
    if flag.isEmpty || flag == "NO"{
        return false
    } else {
        return true
    }
}

/*
 获取设备UUID
 */
@inline(__always) func StringWithUUID()->String{
    let uuidObj = CFUUIDCreate(nil)
    let uuidString = CFUUIDCreateString(nil, uuidObj) as String?
    return uuidString!
}

/*
获取当前用户ID
*/
@inline(__always) func CDUserId() -> Int{
    let userId = CDConfigFile.getIntValueFromConfigWith(key: .userId)
    return userId
}

/*
获取文件尺寸大小
*/
@inline(__always) func getFileSizeAtPath(filePath:String) ->Int{

    var fileSize:Int = 0
    if FileManager.default.fileExists(atPath: filePath) {
        do{
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
            fileSize = attr[FileAttributeKey.size] as! Int
        }catch{
            
        }
    }
    return fileSize
}
/*
获取文件夹尺寸大小
*/
@inline(__always) func getFolderSizeAtPath(folderPath:String) -> Int{
    
    
    var isDir:ObjCBool = false
    let manager = FileManager.default
    var fileSize:Int = 0
    if manager.fileExists(atPath: folderPath, isDirectory: &isDir) {
        if isDir.boolValue {
            let fileArr = manager.subpaths(atPath: folderPath)!
            
            fileArr.forEach { (path) in
                let allPath = folderPath + "/" + path
                fileSize = fileSize + getFileSizeAtPath(filePath: allPath)
            }
            return fileSize
            
        }
    }
    return getFileSizeAtPath(filePath: folderPath)
    
}

/*
加载图片
*/
@inline(__always) func LoadImageByName(imageName:String,type:String) -> UIImage? {
    var path = Bundle.main.path(forResource:imageName, ofType:type)
    if path == nil{
        let name = imageName + "@2x"
        path = Bundle.main.path(forResource:name, ofType:type)
    }
    if path == nil{
        return nil
    }
    let image = UIImage(contentsOfFile: path!)
    return image!
}

/*
加载图片
*/
@inline(__always) func fileManagerDeleteFileWithFilePath(filePath:String){
    let manager = FileManager.default
    if manager.fileExists(atPath: filePath) {
        do{
            try manager.removeItem(atPath: filePath)
        }catch{
            
        }
    }
}

/*
格式化时间戳
*/
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

/*
获取32位随机数
*/
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

/*
获取视频的长度
*/
@inline(__always)func getTimeLenWithVideoPath(path:String)->Double{
    let urlAsset = AVURLAsset(url: URL(fileURLWithPath: path))
    let second = Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale)
    return second
}

/*
格式化文件size
*/
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
        sizeStr = String(format: "%.2lfKB", sizef)
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

/*
获取当前时间戳
*/
@inline(__always)func getCurrentTimestamp() -> Int{
    let nowTime = NSDate.init().timeIntervalSince1970 * 1000
    return Int(nowTime)
}

/*
格式化时间戳
*/
@inline(__always)func timestampTurnString(timestamp:Int)->String{
    let formter = DateFormatter()
    formter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp/1000))
    let dateStr = formter.string(from: date)
    return dateStr
}

/*
获取视频的首帧图片
*/
@inline(__always)func getVideoPreviewImage(videoUrl:URL) -> UIImage {
    let avAsset = AVAsset(url: videoUrl)
    let generator = AVAssetImageGenerator(asset: avAsset)
    generator.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
    var actualTime:CMTime = CMTimeMake(value: 0, timescale: 0)
    do {
        let imageRef:CGImage = try generator.copyCGImage(at: time, actualTime: &actualTime)
        let image = UIImage(cgImage: imageRef)

        return image
    } catch  {
        print(error)
        return LoadImageByName(imageName: "file_video_big", type: "png")!
    }
    
}


@inline(__always)func getFileHeadImage(type: NSFileType) -> String? {
    let arr: [String] = [
        "file_txt_big",
        "file_audio_big",
        "file_image_big",
        "file_video_big",
        "file_pdf_big",
        "file_ppt_big",
        "file_doc_big",
        "file_txt_big",
        "file_excel_big",
        "file_rtf_big",
        "file_image_big",
        "file_zip_big",
        "file_image_big",
        "file_other_big"
    ]
    if type.rawValue >= arr.count {
        return "file_other_big"
    }
    return arr[type.rawValue]
}

@inline(__always)func getAppName() -> String{
    
    let appInfo = Bundle.main.infoDictionary
    let appName = appInfo!["CFBundleDisplayName"] as! String
    return appName
    
}

@inline(__always)func getAppShortVersion() -> String{
    
    let appInfo = Bundle.main.infoDictionary
    let appVersion = appInfo!["CFBundleShortVersionString"] as! String
    return appVersion
    
}

@inline(__always)func getAppVersion() -> String{
    
    let appInfo = Bundle.main.infoDictionary
    let appVersionNUm = appInfo!["CFBundleVersion"] as! String
    return appVersionNUm
}


/**
 判断权限
 */
@inline(__always)func checkPermission(type:CDDevicePermissionType,Result:@escaping (Bool)->Void){
    if type == .library {
       let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized{
            Result(true)
        }else if status == .notDetermined{
            PHPhotoLibrary.requestAuthorization { (status) in
                Result(status == .authorized)
            }
        }else{
            Result(false)
        }
    } else if type == .camera {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized{
            Result(true)
        }else if status == .notDetermined{
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                Result(status)
            }
        }else{
            Result(false)
        }
    } else if type == .micorphone {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .authorized{
            Result(true)
        }else if status == .notDetermined{
            AVCaptureDevice.requestAccess(for: .audio) { (status) in
                Result(status)
            }
        }else{
            Result(false)
        }
    } else if type == .location {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways ||
        status == .authorizedWhenInUse{
            Result(true)
        } else if status == .notDetermined{
            CLLocationManager().requestWhenInUseAuthorization()
            Result(true)
        } else {
            Result(false)
        }
    }
}

/**
 *配置相机、相册、地图、麦克风权限
 */
@inline(__always)func openPermission(type:CDDevicePermissionType,viewController:CDBaseAllViewController){
    
    var title:String!
    var message:String!
    if type == .library {
        title = "相册被拒绝访问"
        message = "请在”设置>隐私>照片>\(getAppName())“，设置读取和写入"
    } else if type == .camera {
        title = "相机访问被拒绝"
        message = "请在“设置>隐私>相机>\(getAppName())”选项中，打开允许访问的开关"
    } else if type == .micorphone {
        title = "麦克风被拒绝访问"
        message = "请在“设置>隐私>麦克风>\(getAppName())”选项中，打开允许访问的开关"
    } else if type == .location {
        title = "地图定位被拒绝访问"
        message = "请在“设置>隐私>定位服务>\(getAppName())”选项中，选择使用权限"
    }
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "以后设置", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "前去设置", style: .default, handler: { (action) in
        var url = URL(string: "App-Prefs:root=Privacy")
        if #available(iOS 10.3, *) {
            url = URL(string: UIApplication.openSettingsURLString)
        }
        if UIApplication.shared.canOpenURL(url!) {
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }))
    viewController.present(alert, animated: true, completion: nil)
}

/**
 *获取状态栏高度
 */
@inline(__always)func GetStatusHeight() ->CGFloat{
    var statusHeight:CGFloat = 0
    if #available(iOS 13.0,*){
        let defaul = iPhoneX ? 44.0 : 20.0
        statusHeight = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? CGFloat(defaul)
    }else{
        statusHeight = UIApplication.shared.statusBarFrame.height
    }
    print("statusHeight = \(statusHeight)")
    return statusHeight
}

@inline(__always)func UIColorFromRGB(_ red:CGFloat,_ green:CGFloat,_ blue:CGFloat) -> UIColor{
    return UIColor(red:red/255.0, green:green/255.0,blue:blue/255.0,alpha:1.0)
}

@inline(__always)func UIColorFromRGBA(_ red:CGFloat,_ green:CGFloat,_ blue:CGFloat,_ alpha:CGFloat) -> UIColor{
    return UIColor(red:red/255.0, green:green/255.0,blue:blue/255.0,alpha:alpha)
}

@inline(__always)func UIColorFromHex(hexNum:Int) -> UIColor{
    return UIColor(red: CGFloat((hexNum & 0xFF0000) >> 16) / 255.0,
                   green: CGFloat((hexNum & 0x00FF00) >> 8) / 255.0,
                   blue: CGFloat((hexNum & 0x0000FF) >> 0) / 255.0,
                   alpha: 1.0)
}
