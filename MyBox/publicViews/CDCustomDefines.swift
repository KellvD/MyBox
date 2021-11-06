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
let bottomSafeHeight:CGFloat = (iPhoneX || iPhone12) ? 34.0 : 0.0
let topSafeHeight:CGFloat = (iPhoneX || iPhone12) ? GetStatusHeight() : 0.0
let StatusHeight = GetStatusHeight()
let NavigationHeight:CGFloat = 44.0
let CDViewHeight = CDSCREEN_HEIGTH - NavigationHeight - StatusHeight

let iPhoneX = (CDSCREEN_WIDTH == 375.0 && CDSCREEN_HEIGTH == 812.0) ||
                (CDSCREEN_WIDTH == 414.0 && CDSCREEN_HEIGTH == 896.0)



let iPhone12 = (CDSCREEN_WIDTH == 428.0 && CDSCREEN_HEIGTH == 926.0) ||
                (CDSCREEN_WIDTH == 390.0 && CDSCREEN_HEIGTH == 844.0) ||
                (CDSCREEN_WIDTH == 360.0 && CDSCREEN_HEIGTH == 780.0)


//底部自定义工具栏高度
let BottomBarHeight:CGFloat = bottomSafeHeight + 48.0

let thumpImageWidth = (CDSCREEN_WIDTH-6.0)/4.0
let thumpImageHeight = (CDSCREEN_WIDTH-6.0)/4.0


let FIRSTUSERID = 100001 //数据库ID，扩展多账户模式
let waterMarkTag = 98764
let ROOTSUPERID = -1
let CDMaxWatermarkLength = 20

let CD_ReaderBgModel = "ReaderBgModel"
let CD_ChapterIndex = "chapterIndex"

let SECTION_SPACE:CGFloat = 15.0
let CELL_HEIGHT:CGFloat = 48.0




let EmojiRegularExpression = "\\[[a-zA-Z0-9\\u4e00-\\u9fa5 ]+\\]"
let symbolExpression = "[`~!@#$%^&*+=|{}':',\\[\\].<>/?~！@#￥%……& amp;*（）——+|{}‘；：”“’。，、？|]"


enum NSFolderType:Int {
    case ImageFolder = 0
    case AudioFolder = 1
    case VideoFolder = 2
    case TextFolder = 3
//    case OtherFolder = 4
}
//


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



enum DiskSpaceAlertType:String
{
    case AlertShootVideoType = "可用存储空间不足，无法拍摄视频。您可以在设置里管理存储空间。"   // 录像
    case AlertVideosType = "可用存储空间不足，无法导入此视频。您可以在设置里管理存储空间。"      // 从系统库导入视频
    case AlertPlayVideoType = "可用存储空间不足，无法播放视频。您可以在设置里管理存储空间。"    // 播放视频
    case AlertTakePhotoType = "可用存储空间不足，无法拍摄照片。您可以在设置里管理存储空间。"    // 拍照
    case AlertPhotosType = "可用存储空间不足，无法导入这些图片。您可以在设置里管理存储空间"       // 从系统库导入图片
    case AlertBrowsePhotosType = "可用存储空间不足，无法浏览照片。您可以在设置里管理存储空间。" // 浏览图片
    case AlertMakeRecordType = "可用存储空间不足，无法录制音频。您可以在设置里管理存储空间。"   // 录音
    case AlertRecordsType = "可用存储空间不足，无法播放音频。您可以在设置里管理存储空间。"      // 播放录音
    case AlertDocumentType = "可用存储空间不足，无法导入文件。您可以在设置里管理存储空间。"      // Document
    case AlertFormatType = "读取文件失败，权限不足"
}



enum SDImageFormat:NSInteger {
    case Undefined = -1
    case JPEG = 0
    case PNG = 1
    case GIF
    case TIFF
    case WebP
    case HEIC
}


let IOSVersion = Float(UIDevice.current.systemVersion)

enum CDDevicePermissionType:Int {
    case library = 1 //图库
    case camera = 2
    case micorphone = 3
    case location = 4
    
}
//-----------------------------logCongig

enum CDThemeMode :Int{
    case Nomal = 0
    case Dark = 1
}

let NotInitPwd = -1;
let HasInitPwd = 0;
let DelayInitPwd = 1;


