//
//  CDDeviceTools.swift
//  MyRule
//
//  Created by changdong on 2020/4/22.
//  Copyright © 2020 changdong. All rights reserved.
//

import UIKit

class CDDeviceTools: NSObject {

    class func getDeviceMemoryInfo(){
        
    }
    //获取电量,电池状态
    class func getBatteryInfo() -> (batteryLevel:String, batteryStatus:UIDevice.BatteryState){
        let batteryLevel = "\(UIDevice.current.batteryLevel)%"
        let batteryStatus = UIDevice.current.batteryState
        return (batteryLevel,batteryStatus)
    }
    //获取
}
