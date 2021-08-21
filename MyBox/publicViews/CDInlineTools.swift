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
    return flag != "YES"
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
@inline(__always) func GetFileSize(filePath:String) ->Int{

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
@inline(__always) func GetFolderSize(folderPath:String) -> Int{
    
    
    var isDir:ObjCBool = false
    let manager = FileManager.default
    var fileSize:Int = 0
    if manager.fileExists(atPath: folderPath, isDirectory: &isDir) {
        if isDir.boolValue {
            let fileArr = manager.subpaths(atPath: folderPath)!
            fileArr.forEach { (path) in
                let allPath = folderPath + "/" + path
                fileSize = fileSize + GetFileSize(filePath: allPath)
            }
            return fileSize
            
        }
    }
    return GetFileSize(filePath: folderPath)
    
}


/// 加载图片
/// - Parameters:
///   - imageName: 图片名称
///   - type: 图片格式
/// - Returns: 图片
@inline(__always) func LoadImage(_ imageName:String) -> UIImage? {
    if imageName.hasPrefix(String.RootPath()) { //判断是否是沙盒文件
        let image = UIImage(contentsOfFile: imageName)
        if image != nil {
            return image
        }else{
            return UIImage(named:"图片加载失败");
        }
    }
    
    return UIImage(named: imageName )
    
}

/*
删除文件
*/
@inline(__always) func DeleteFile(filePath:String){
    let manager = FileManager.default
    if manager.fileExists(atPath: filePath) {
        do{
            try manager.removeItem(atPath: filePath)
        }catch{
            CDPrintManager.log("文件删除失败" + error.localizedDescription, type: .WarnLog)
        }
    }
}

/*
格式化时间戳
*/
@inline(__always)func GetMMSSFromSS(second:Double)->String{
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
@inline(__always)func GetRandString() -> String? {
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
@inline(__always)func GetVideoLength(path:String)->Double{
    let urlAsset = AVURLAsset(url: URL(fileURLWithPath: path), options: nil)
    let second = Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale)
    return second
}

/*
格式化文件size
*/
@inline(__always)func GetSizeFormat(fileSize:Int)->String{
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
        break
    }
    return sizeStr
}

/*
获取当前时间戳
*/
@inline(__always)func GetTimestamp() -> Int{
    let nowTime = NSDate.init().timeIntervalSince1970 * 1000
    return Int(nowTime)
}

/*
格式化时间戳
*/
@inline(__always)func GetTimeFormat(_ timestamp:Int)->String{
    let formter = DateFormatter()
    formter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp/1000))
    let dateStr = formter.string(from: date)
    return dateStr
}


@inline(__always)func GetFileHeadImage(type: NSFileType) -> String? {
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

@inline(__always)func GetAppName() -> String{
    
    let appInfo = Bundle.main.infoDictionary
    let appName = appInfo!["CFBundleName"] as! String
    return appName
    
}

@inline(__always)func GetAppShortVersion() -> String{
    
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
        title = LocalizedString("Album is denied access")
        message = LocalizedString("Please go to \"Settings>Privacy>Photos>%@)\" to set read and write", GetAppName())
    } else if type == .camera {
        title = LocalizedString("Camera access denied")
        message = LocalizedString("Please turn on the switch to allow access in the \"Settings>Privacy>Camera>%@)\" option", GetAppName())
    } else if type == .micorphone {
        title = LocalizedString("Microphone access denied")
        message = LocalizedString("Please turn on the switch to allow access in the \"Settings>Privacy>Microphone>%@)\" option", GetAppName())
    } else if type == .location {
        title = LocalizedString("Map location access denied")
        message = LocalizedString("Please select the usage permission in the \"Settings>Privacy>Location Services>%@)\" option", GetAppName())
    }
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: LocalizedString("Set Up Later"), style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: LocalizedString("Go to Settings"), style: .default, handler: { (action) in
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

@inline(__always)func GetAppThemeSwi() ->Bool{
    let theme = CDConfigFile.getBoolValueFromConfigWith(key: .darkSwi)
    return theme
}

@inline(__always)func GetThemeMode() ->CDThemeMode{
    let theme = CDConfigFile.getIntValueFromConfigWith(key: .themeMode)
    return CDThemeMode(rawValue: max(0, theme))!
}

//MARK:获取图片格式
@inline(__always)func imageFormat(imageData:NSData) ->SDImageFormat{
   var c: UInt8?
   imageData.getBytes(&c, length: 1)

   switch c {
   case 0xff:
       return SDImageFormat.JPEG
   case 0x89:
       return SDImageFormat.PNG;
   case 0x47:
       return SDImageFormat.GIF;
   case 0x49,0x4D:
       return SDImageFormat.TIFF;
   case 0x52:
       if imageData.length > 12{
           let string = String(data: imageData.subdata(with: NSRange(location: 0, length: 12)), encoding: String.Encoding.ascii)!
           if (string.hasPrefix("PIFF") &&
               string.hasSuffix("WEBP")){
               return SDImageFormat.WebP;
           }
       }
   case 0x00:
       if imageData.length > 12{
           let string = String(data: imageData.subdata(with: NSRange(location: 4, length: 8)), encoding: String.Encoding.ascii)!
           if (string == "ftypheic" ||
               string == "WEBP" ||
               string == "ftyphevc" ||
               string == "ftyphevx"){
               return SDImageFormat.HEIC;
           }
       }
   default:
       return SDImageFormat.Undefined;
   }
   return SDImageFormat.Undefined;
}



@inline(__always)func LocalizedString(_ key:String,_ comment:String) -> String{
    return String(format: NSLocalizedString(key, comment:""), comment)
}

@inline(__always)func LocalizedString(_ key:String) -> String{
    
    return NSLocalizedString(key, comment: "")
}
