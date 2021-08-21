//
//  CDDeviceConfig.swift
//  CDTextViewDemo
//
//  Created by changdong cwx889303 on 2020/12/2.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import Foundation
import SystemConfiguration

class CDDeviceConfig: NSObject {

    class func getPhoneName()->String{
        var systemInfo = utsname()
        uname(&systemInfo)
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
   
        if platform == "iPhone8,4" {return"iPhone SE"}
        if platform == "iPhone9,1" {return"iPhone 7"}
        if platform == "iPhone9,2" {return"iPhone 7 Plus"}
        if platform == "iPhone10,1" {return"iPhone 8"}
        if platform == "iPhone10,2" {return"iPhone 8 Plus"}
        if platform == "iPhone10,3" {return"iPhone X"}
        if platform == "iPhone10,4" {return"iPhone 8"}
        if platform == "iPhone10,5" {return"iPhone 8 Plus"}
        if platform == "iPhone10,6" {return"iPhone X"}
        if platform == "iPhone11,8" {return "iPhone XR"}
        if platform == "iPhone11,2" {return "iPhone XS"}
        if platform == "iPhone11,4" || platform == "iPhone11,6" {return "iPhone XS Max"}
        if platform == "iPhone12,1" {return "iPhone 11"}
        if platform == "iPhone12,3" {return "iPhone 11 Pro"}
        if platform == "iPhone12,5" {return "iPhone 11 Pro Max"}
        if platform == "iPhone12,8" {return "iPhone SE 2020"}
        if platform == "iPhone13,1" {return "iPhone 12 mini"}
        if platform == "iPhone13,2" {return "iPhone 12"}
        if platform == "iPhone13,3" {return "iPhone 12 Pro"}
        if platform == "iPhone13,4" {return "iPhone 12 Pro Max"}
        if platform == "iPad1,1" {return"iPad 1"}
        if platform == "iPad2,1" || platform == "iPad2,2" || platform == "iPad2,3" || platform == "iPad2,4" {return"iPad 2"}
        if platform == "iPad2,5" || platform == "iPad2,7" || platform == "iPad2,6" {return"iPad Mini 1"}
        if platform == "iPad3,1" || platform == "iPad2,4" || platform == "iPad3,3" {return"iPad 3"}
        if platform == "iPad3,4" || platform == "iPad3,5" || platform == "iPad3,6" {return"iPad 4"}
        if platform == "iPad4,1" || platform == "iPad4,2" || platform == "iPad4,3" {return"iPad Air"}
        if platform == "iPad4,4" || platform == "iPad4,5" || platform == "iPad4,5" {return"iPad Mini 2"}
        if platform == "iPad4,7" || platform == "iPad4,8" || platform == "iPad4,9" {return"iPad Mini 3"}
        if platform == "iPad5,1" || platform == "iPad5,2" {return"iPad Mini 4"}
        if platform == "iPad5,3" || platform == "iPad5,4" {return"iPad Air 2"}
        if platform == "iPad6,3" || platform == "iPad6,4" {return"iPad Pro 9.7"}
        if platform == "iPad6,7" || platform == "iPad6,8" {return"iPad Pro 12.9"}
        if platform == "i386"    || platform == "x86_64"  {return"iPhone Simulator"}
        return platform

    }
}
