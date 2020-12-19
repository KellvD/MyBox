//
//  CDDeviceAPI.swift
//  CDTextViewDemo
//
//  Created by changdong cwx889303 on 2020/12/2.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import Foundation
import UIKit

class CDDeviceIndicatorAPI: NSObject {

    static let share = CDDeviceIndicatorAPI()
    let manager = CDDeviceCollectManager()
    func startCheckDeviceInfo(indicatorArr:[[String]], complete:@escaping(_ dict:[String:String])->Void){
        DispatchQueue.global().async {
            var indicatorResult:[String:String] = [:]
            indicatorArr.forEach { (indicatoritems) in
                indicatoritems.forEach { (key) in
                    let methodName = self.checkMethodDict[key]!
                    let method = Selector(methodName)
                    if self.manager.responds(to: method){
                        let value = self.manager.perform(method)?.takeUnretainedValue() as! String
                        indicatorResult[key] = value
                    }
                }
            }
            DispatchQueue.main.async {
                complete(indicatorResult)
            }
            
        }
       
        
    }
    
    
    
    

    lazy var checkMethodDict: [String:String] = {
        let dict = ["名称":"getPhoneName",
                    "软件版本":"getModelVersion",
                    "型号名称":"getModelName",
                    "运行时长":"getPowerOnTime",
                    "电池电量":"getPowerRate",
                    "省电模式":"getPoweraSaveModel",
                    "CPU":"getCpuState",
                    "CPU核数":"getCpuCount",
                    "内存":"getMemoryRate",
                    "网络":"",
                    "运营商":"getNetworkCarrier",
                    "IP":"getIP",
                    "总容量":"getTotalDiskSize",
                    "可用容量":"getAvailableDiskSize",
                    "UUID":"getUUID"]
        return dict
    }()
    
    
    
}

