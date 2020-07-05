//
//  CDConfigFile.swift
//  MyRule
//
//  Created by changdong on 2018/12/9.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDConfigFile: NSObject {

    class func databasePath()->String{

        return GetDocumentPath().appendingPathComponent(str: "/CDConfig.dat")
    }
    //MARK: Object
    class func setOjectToConfigWith(key:String,value:String){

        let finaPath = databasePath()
        var writeDict = NSMutableDictionary(contentsOfFile: finaPath)
        if writeDict == nil {
            writeDict = NSMutableDictionary(capacity: 1)
        }
        if writeDict == nil {
            return
        }
        writeDict?.setObject(value, forKey: key as NSCopying)
        let bv = writeToFileWith(writeDict: writeDict!, filePath: finaPath)

        if bv {
            print("写入文件成功")
        }
    }
    class func getValueFromConfigWith(key:String)->String{
        let finaPath = databasePath()
        var ret = ""
        let readDict = NSMutableDictionary(contentsOfFile: finaPath)
        if readDict == nil {
            return ""
        }else{
            ret = readDict?.object(forKey: key) as? String ?? ""
        }

        return ret
    }

    //MARK: Int
    class func setIntValueToConfigWith(key:String,intValue:Int){
        let finaPath = databasePath()
        var writeDict = NSMutableDictionary(contentsOfFile: finaPath)
        if writeDict == nil {
            writeDict = NSMutableDictionary(capacity: 1)
        }
        if writeDict == nil {
            return
        }
        let num1 = NSNumber(value:intValue)
        writeDict?.setObject(num1, forKey: key as NSCopying)
        let bv = writeToFileWith(writeDict: writeDict!, filePath: finaPath)

        if bv {
            print("Int 值写入成功")
        }

    }
    class func getIntValueFromConfigWith(key:String)->Int{
        let finaPath = databasePath()
        var ret = -1
        let readDict = NSMutableDictionary(contentsOfFile: finaPath)
        if readDict == nil {
            return -1
        }else{
            let num1 = readDict?.object(forKey: key) as? NSNumber
            ret = num1?.intValue ?? -1
        }
        return ret
    }

    //MARK: Int
    class func setBoolValueToConfigWith(key:String,boolValue:Bool){

        if boolValue {
            setIntValueToConfigWith(key: key, intValue: 1)
        }else{
            setIntValueToConfigWith(key: key, intValue: 0)
        }

    }
    class func getBoolValueFromConfigWith(key:String)->Bool{
        let valueC = getIntValueFromConfigWith(key: key)
        if valueC == 1 {
            return true
        }else{
            return false
        }
    }

    class func clearConfigFile(){
        let finaPath = databasePath()
        let nullDict = NSMutableDictionary(contentsOfFile: finaPath)
        nullDict?.removeAllObjects()
        let _ = writeToFileWith(writeDict: nullDict!, filePath: finaPath)

    }

    class func writeToFileWith(writeDict:NSMutableDictionary,filePath:String)->Bool{
        objc_sync_enter(self)
        let writeFlag = writeDict.write(toFile: filePath, atomically: true)
        objc_sync_exit(self)
        return writeFlag


    }
}
