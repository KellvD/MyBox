//
//  CDDeviceTools.swift
//  MyRule
//
//  Created by changdong on 2020/4/22.
//  Copyright © 2020 changdong. All rights reserved.
//

import UIKit

class CDDeviceTools: NSObject {

    class func getDeviceMemoryInfo() {

    }
    // 获取电量,电池状态
    class func getBatteryInfo() -> (batteryLevel: String, batteryStatus: UIDevice.BatteryState) {
        let batteryLevel = "\(UIDevice.current.batteryLevel)%"
        let batteryStatus = UIDevice.current.batteryState
        return (batteryLevel, batteryStatus)
    }

    // 获取磁盘
    class func getDiskSpace() -> (total: Int, free: Int) {
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
       let systemAttr = try! FileManager.default.attributesOfFileSystem(forPath: docPath)
        let total = systemAttr[FileAttributeKey.systemSize] as! Int
        let free = systemAttr[FileAttributeKey.systemFreeSize] as! Int
        return (total, free)
    }

    // 手机别名,型号
    class func getIphoneInfo() -> (name: String, model: String) {
        return (UIDevice.current.name, UIDevice.current.model)
    }

    // 系统版本
    class func getSystemVersion() -> (version: String, name: String) {
        return (UIDevice.current.systemVersion, UIDevice.current.systemName)
    }
    /*
     获取设备UUID
     */
    class func getUUID() -> String {
        let uuidObj = CFUUIDCreate(nil)
        let uuidString = CFUUIDCreateString(nil, uuidObj) as String?
        return uuidString!
    }

}
