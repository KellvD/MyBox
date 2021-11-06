//
//  CDLogBean.swift
//  MyBox
//
//  Created by changdong  on 2020/7/6.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit

class CDLogBean: NSObject {
    
    static var logFolder:String{
        set {
            CDConfigFile.setOjectToConfigWith(key: .logFolder, value: newValue)
            let folder = String.documentPath().appendingPathComponent(str: newValue)
            var isDir:ObjCBool = true
            if !FileManager.default.fileExists(atPath: folder, isDirectory: &isDir) {
                do {
                    try FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
                } catch  {
                    CDPrintManager.log("日志目录创建失败", type: .InfoLog)
                }
            }
        }
        get {
            let path = CDConfigFile.getValueFromConfigWith(key: .logFolder)
            return path == "" ? "LOG" : path
        }
    }
    static var logName:String{
        set{
            CDConfigFile.setOjectToConfigWith(key: .logName, value: newValue)
        }
       
        get {
            let name = CDConfigFile.getValueFromConfigWith(key: .logName)
            return name == "" ? "log \(GetTimeFormat(GetTimestamp(nil))).log" : name
        }
    }
    
    static var isOn: Bool {
        set {
            CDConfigFile.setBoolValueToConfigWith(key: .logSwi, boolValue: newValue)
        }
        get {
            return CDConfigFile.getBoolValueFromConfigWith(key: .logSwi)
        }
    }
    static var logLevel: CDPrintManager.CDLogLevel {
        set {
            CDConfigFile.setIntValueToConfigWith(key: .logLevel, intValue: newValue.rawValue)
        }
        get {
            let level = CDConfigFile.getIntValueFromConfigWith(key: .logLevel)
            return  level == -1 ? .DebugLog : CDPrintManager.CDLogLevel(rawValue: level)!
        }
    }
    static var logPath: String {
        set{
            if newValue != "" && !FileManager.default.fileExists(atPath: newValue) {
                if FileManager.default.createFile(atPath: newValue, contents: nil, attributes: nil) {
                    CDPrintManager.log("日志文件创建完成", type: .InfoLog)
                }else{
                    CDPrintManager.log("日志文件创建失败", type: .InfoLog)
                }
            }
            
        }
        get {
            return  String.documentPath().appendingPathComponent(str: "/\(logFolder)/\(logName)")
        }
    }
    
    class func closeLogConfig(){
        CDLogBean.isOn = false
        
        do {
            try FileManager.default.removeItem(atPath: logPath)
            CDPrintManager.log("日志关闭，文件删除完成", type: .InfoLog)
        } catch  {
            CDPrintManager.log("日志关闭，文件删除失败error:\(error.localizedDescription)", type: .ErrorLog)
        }
        CDLogBean.logLevel = .DebugLog
        CDLogBean.logFolder = ""
        CDLogBean.logName = ""
        CDLogBean.logPath = ""
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
