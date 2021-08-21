//
//  CDImageCustom.swift
//  CDImagePicker
//
//  Created by changdong cwx889303 on 2021/2/8.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import Foundation
import UIKit

let CDSCREEN_WIDTH = UIScreen.main.bounds.size.width
let CDSCREEN_HEIGTH = UIScreen.main.bounds.size.height
let bottomSafeHeight:CGFloat = (iPhoneX || iPhone12) ? 34.0 : 0.0
let StatusHeight = CD_StatusHeight()
let NavigationHeight:CGFloat = 44.0
let CDViewHeight = CDSCREEN_HEIGTH - NavigationHeight - StatusHeight

let iPhoneX = (CDSCREEN_WIDTH == 375.0 && CDSCREEN_HEIGTH == 812.0) ||
                (CDSCREEN_WIDTH == 414.0 && CDSCREEN_HEIGTH == 896.0)



let iPhone12 = (CDSCREEN_WIDTH == 428.0 && CDSCREEN_HEIGTH == 926.0) ||
                (CDSCREEN_WIDTH == 390.0 && CDSCREEN_HEIGTH == 844.0) ||
                (CDSCREEN_WIDTH == 360.0 && CDSCREEN_HEIGTH == 780.0)


//底部自定义工具栏高度
let BottomBarHeight:CGFloat = bottomSafeHeight + 48.0

let itemWidth_Height = (CDSCREEN_WIDTH - 10)/4
let normalLoadCount = 36


enum CDSelected_Status:String {
    case CD_True = "selected_true" //选中
    case CD_False = "selected_false"  //未选中
}



@inline(__always)func CD_StatusHeight() ->CGFloat{
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

@inline(__always)func GetTimestamp() -> Int{
    let nowTime = NSDate.init().timeIntervalSince1970 * 1000
    return Int(nowTime)
}



