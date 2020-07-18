//
//  CDCustomDefines.swift
//  MyRule
//
//  Created by changdong on 2018/11/12.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Foundation




let CDSCREEN_WIDTH = UIScreen.main.bounds.size.width
let CDSCREEN_HEIGTH = UIScreen.main.bounds.size.height
let CDViewHeight = CDSCREEN_HEIGTH - NavigationHeight - StatusHeight
let iPhoneX = (UIScreen.main.bounds.size.width == 375.0 && UIScreen.main.bounds.size.height == 812.0) || (UIScreen.main.bounds.size.width == 414.0 && UIScreen.main.bounds.size.height == 869.0)

let StatusHeight = GetStatusHeight()
let NavigationHeight:CGFloat = 44

let thumpImageWidth = (CDSCREEN_WIDTH-6.0)/4.0
let thumpImageHeight = (CDSCREEN_WIDTH-6.0)/4.0


//颜色的定义
let CustomBlueColor = UIColor(red: 39/255, green: 162/255.0, blue: 242/255.0, alpha: 1.0)
let TextDarkBlackColor  = UIColor(red:26/255.0, green:26/255.0,blue:26/255.0,alpha:1.0)
let TextBlackColor     =  UIColor(red:61/255.0, green:81/255.0,blue:97/255.0,alpha:1.0)
let TextLightBlackColor = UIColor(red:154/255.0, green:154/255.0,blue:154/255.0,alpha:1.0)
let TextLightBlueColor  = UIColor(red:39/255.0,green:162/255.0,blue:242/255.0,alpha:1.0) //27a2f2
let TextLightGrayColor =   UIColor(red:141/255.0,green:151/255.0,blue:167/255.0,alpha:1.0)//#9a9a9a

let SeparatorLightGrayColor =  UIColor(red:153/255.0,green:153/255.0,blue:153/255.0,alpha:1.0)//#999999

let SeparatorGrayColor  = UIColor(red:243/255.0,green:243/255.0,blue:243/255.0,alpha:1.0)
let TextGrayColor    =    UIColor(red:141/255.0,green:151/255.0,blue:167/255.0,alpha:1.0)

let LightBlueColor   =    UIColor(red:213/255.0,green:230/255.0,blue:244/255.0,alpha:1.0)
let NavigationColor   =    UIColor(red:0/255.0,green:95/255.0,blue:187/255.0,alpha:1.0)
let BaseBackGroundColor   =    UIColor(red:242/255.0,green:243/255.0,blue:243/255.0,alpha:1.0)

let CustomPinkColor   =   UIColor(red:255/255.0,green:73/255.0,blue:0/255.0,alpha:1.0)
let ProgressViewBgColor = UIColor(red:0, green:104/255.0,blue:183/255.0,alpha:0.3)

let FIRSTUSERID = 100001 //数据库ID，扩展多账户模式
let waterMarkTag = 98764
let CDPrint = print
let ROOTSUPERID = -1

let CD_ReaderBgModel = "ReaderBgModel"
let CD_ChapterIndex = "chapterIndex"

let DismissImagePicker = NSNotification.Name(rawValue: "DismissImagePicker")
let NeedReloadData = NSNotification.Name(rawValue: "NeedReloadData")
let DocumentInputFile = NSNotification.Name(rawValue: "DocumentInputFile")

let RefreshProgress = NSNotification.Name(rawValue: "RefreshProgress")
let BarsHiddenOrNot = NSNotification.Name(rawValue: "BarsHiddenOrNot")
let PlayThePlayer = NSNotification.Name(rawValue: "PlayThePlayer")

let EmojiRegularExpression = "\\[[a-zA-Z0-9\\u4e00-\\u9fa5 ]+\\]"

let TextBigFont = UIFont.systemFont(ofSize: 20)
let TextMidFont =  UIFont.systemFont(ofSize: 17)
let TextSmallFont =  UIFont.systemFont(ofSize: 12)
let TextMidSmallFont = UIFont.systemFont(ofSize: 15)

enum NSFolderType:Int {
    case ImageFolder = 0
    case AudioFolder = 1
    case VideoFolder = 2
    case TextFolder = 3
//    case OtherFolder = 4
}
//
enum NSFileType:Int {
    case PlainTextType = 0
    case AudioType = 1
    case ImageType = 2
    case VideoType = 3
    case PdfType = 4
    case PptType = 5
    case DocType = 6
    case TxtType = 7
    case ExclType = 8
    case RtfType = 9
    case GifType = 10
    case ZipType = 11
    case LiveType = 12
    case OtherType = 13
}
enum CDBrightType:Int {
    case Bright = 0
}
enum CDEditorsType:Int {
    case Crop = 1 //剪裁
    case Filter = 2 //滤镜
    case Bright = 3 //亮度
    case Rotate = 4 //旋转
    case Mosaic = 5//马赛克
    case Watermark = 6 //水印
    case Text = 7//文字
}
//登录模式
enum CDLoginType:Int{
    case real = 1   // 超级用户模式
    case fake = 2   // 访客模式
}


let LockOn = 1   //可删除
let LockOff = 2   //不可删除

enum CDFakeType:Int{
    case visible = 1
    case invisible = 2
}

enum NSFileGrade:Int {
    case lovely   //喜爱收藏
    case normal   //普通


}

enum AlertType:Int
{
    case AlertShootVideoType = 1   // 录像
    case AlertVideosType = 2      // 从系统库导入视频
    case AlertPlayVideoType = 3    // 播放视频
    case AlertTakePhotoType = 4    // 拍照
    case AlertPhotosType = 5       // 从系统库导入图片
    case AlertBrowsePhotosType = 6 // 浏览图片
    case AlertMakeRecordType = 7   // 录音
    case AlertRecordsType = 8      // 播放录音
}



enum SDImageFormat:NSInteger {
    case SDImageFormatUndefined = -1
    case SDImageFormatJPEG = 0
    case SDImageFormatPNG = 1
    case SDImageFormatGIF
    case SDImageFormatTIFF
    case SDImageFormatWebP
    case SDImageFormatHEIC
}

enum CDSelectedStatus:String {
    case CDTrue = "selected_true" //选中
    case CDFalse = "selected_false"  //未选中
}
let IOSVersion = Float(UIDevice.current.systemVersion)

enum CDDevicePermissionType:Int {
    case Library = 1 //图库
    case camera = 2
    case micorphone = 3
    case location = 4
    
}
//-----------------------------logCongig
enum CDLogLevel:Int {
    case Debug = 0
    case Info = 1
    case Error = 2
}

