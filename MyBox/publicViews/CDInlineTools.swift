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
                fileSize = fileSize + allPath.fileAttribute.fileSize
            }
            return fileSize
            
        }
    }
    return folderPath.fileAttribute.fileSize
    
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
格式化时间戳
*/
@inline(__always)func GetMMSSFromSS(timeLength:Double)->String{
    let hour = Int(timeLength / 3600)
    let minute = Int(timeLength) / 60
    let second = Int(timeLength) % 60
    var format:String = ""
    if hour > 0 {
        format = String.init(format: "%02ld:%02ld:%02ld", hour,minute,second)
    }else{
        format = String.init(format: "%02ld:%02ld", minute,second)
    }
    return format
}


/*
获取视频的长度
*/
@inline(__always)func GetVideoLength(path:String)->Double{
    let urlAsset = AVURLAsset(url: path.url, options: nil)
    let second = Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale)
    return second
}

/*
格式化文件size
*/
@inline(__always)func GetSizeFormat(fileSize:Int)->String{
    var sizef = Float(fileSize)
    var i = 0
    while sizef >= 1024 {
        sizef = sizef / 1024.0
        i += 1
    }
    let fortmates = ["%.2ldB","%.2lfKB","%.2lfM","%.2lfG","%.2lfT"]
    return String(format: fortmates[i], sizef)
}

/*
获取当前时间戳
*/
@inline(__always)func GetTimestamp(_ time:String?) -> Int{
    var date = Date()
    if time != nil {
        let datter = DateFormatter()
        date = datter.date(from: time!)!
    }
    let nowTime = date.timeIntervalSince1970 * 1000
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


@inline(__always)func GetFileHeadImage(type: CDSafeFileInfo.NSFileType) -> String? {
    let arr: [String] = [
        "file_txt_big","file_audio_big","file_image_big","file_video_big",
        "file_pdf_big","file_ppt_big","file_doc_big","file_txt_big",
        "file_excel_big","file_rtf_big","file_image_big","file_zip_big",
        "file_image_big","link_icon","file_other_big"
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
        let status = PHPhotoLibrary.authorizationStatus();
        if status == .authorized{
            Result(true)
        }else if status == .notDetermined {
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
    
    DispatchQueue.main.async {
        var title:String!
        var message:String!
        if type == .library {
            title = "相册被拒绝访问".localize
            message =
                String(format: "请在”设置>隐私>照片>%@“，设置读取和写入".localize, GetAppName())
        } else if type == .camera {
            title = "相机访问被拒绝".localize
            message = String(format: "请在“设置>隐私>相机>%@”选项中，打开允许访问的开关".localize, GetAppName())
        } else if type == .micorphone {
            title = "麦克风被拒绝访问".localize
            message = String(format: "请在“设置>隐私>麦克风>%@”选项中，打开允许访问的开关".localize, GetAppName())
            
        } else if type == .location {
            title = "地图定位被拒绝访问".localize
            message = String(format: "请在“设置>隐私>定位服务>%@)”选项中，选择使用权限".localize, GetAppName())
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "稍后设置".localize, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "前去设置".localize, style: .default, handler: { (action) in
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
