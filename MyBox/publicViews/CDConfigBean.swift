//
//  CDLogBean.swift
//  MyBox
//
//  Created by changdong  on 2020/7/6.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit

class CDLogBean: NSObject {
    var isOn:Bool!
    var logLevel:CDLogLevel!
    var logPath:String!
    var logName:String!
    
    override init() {
        super.init()
        self.isOn = CDConfigFile.getBoolValueFromConfigWith(key: .logSwi)
        self.logLevel = CDLogLevel(rawValue: CDConfigFile.getIntValueFromConfigWith(key: .logLevel))
        self.logName = CDConfigFile.getValueFromConfigWith(key: .logName)
        self.logPath = CDConfigFile.getValueFromConfigWith(key: .logPath)
    }
    
    class func setLogConfig(isOn:Bool,logLevel:CDLogLevel,logName:String,logPath:String){
        CDConfigFile.setBoolValueToConfigWith(key: .logSwi, boolValue: isOn)
        CDConfigFile.setOjectToConfigWith(key: .logPath, value: logPath)
        CDConfigFile.setIntValueToConfigWith(key: .logLevel, intValue: logLevel.rawValue)
        CDConfigFile.setOjectToConfigWith(key: .logName, value: logName)
    }
}


class CDWaterBean: NSObject {
    var isOn:Bool!
    var text:String!
    var color:UIColor!
    
    override init() {
        super.init()
        self.isOn = CDConfigFile.getBoolValueFromConfigWith(key: .waterSwi)
        self.text = CDConfigFile.getValueFromConfigWith(key: .waterText)
        self.color = .blue
    }
    
    class func setWaterConfig(isOn:Bool,text:String){
        CDConfigFile.setBoolValueToConfigWith(key: .waterSwi, boolValue: isOn)
        CDConfigFile.setOjectToConfigWith(key: .waterText, value: text)
    }
}
