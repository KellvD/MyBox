//
//  CDConfigFile.swift
//  MyRule
//
//  Created by changdong on 2018/12/9.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

enum CDConfigKey: String {
    case touchIdSwi = "touchIdSwi"
    case fakeSwi = "fakeSwi"
    case darkSwi = "darkSwi"
    case themeMode = "themeMode"

    case userId = "userId"
    case firstInstall = "firstInstall"

    case waterSwi = "waterSwi"
    case waterText = "waterMarkText"
    case waterTextColor = "waterTextColor"

    case logSwi = "logSwi"
    case logFolder = "logFolder"
    case logLevel = "logLevel"
    case logName = "logName"

    case readerBg = "readerBg"
    case initPwd = "initPwd"

}

class CDConfigFile: NSObject {

    class func databasePath() -> String {

        return String.documentPath().appendingPathComponent(str: "/CDConfig.dat")
    }
    // MARK: Object
    class func setOjectToConfigWith(key: CDConfigKey, value: String) {

        let finaPath = databasePath()
        var writeDict = NSMutableDictionary(contentsOfFile: finaPath)
        if writeDict == nil {
            writeDict = NSMutableDictionary(capacity: 1)
        }
        if writeDict == nil {
            return
        }
        writeDict?.setObject(value, forKey: key.rawValue as NSCopying)
        let bv = writeToFileWith(writeDict: writeDict!, filePath: finaPath)

        if bv {

        }
    }
    class func getValueFromConfigWith(key: CDConfigKey) -> String {
        let finaPath = databasePath()
        var ret = ""
        let readDict = NSMutableDictionary(contentsOfFile: finaPath)
        if readDict == nil {
            return ""
        } else {
            ret = readDict?.object(forKey: key.rawValue) as? String ?? ""
        }

        return ret
    }

    // MARK: Int
    class func setIntValueToConfigWith(key: CDConfigKey, intValue: Int) {

        let finaPath = databasePath()
        var writeDict = NSMutableDictionary(contentsOfFile: finaPath)
        if writeDict == nil {
            writeDict = NSMutableDictionary(capacity: 1)
        }
        if writeDict == nil {
            return
        }
        let num1 = NSNumber(value: intValue)
        writeDict?.setObject(num1, forKey: key.rawValue as NSCopying)
        let bv = writeToFileWith(writeDict: writeDict!, filePath: finaPath)

        if bv {

        }

    }
    class func getIntValueFromConfigWith(key: CDConfigKey) -> Int {
        let finaPath = databasePath()
        var ret = -1
        let readDict = NSMutableDictionary(contentsOfFile: finaPath)
        if readDict == nil {
            return -1
        } else {
            let num1 = readDict?.object(forKey: key.rawValue) as? NSNumber
            ret = num1?.intValue ?? -1
        }
        return ret
    }

    // MARK: Int
    class func setBoolValueToConfigWith(key: CDConfigKey, boolValue: Bool) {

        if boolValue {
            setIntValueToConfigWith(key: key, intValue: 1)
        } else {
            setIntValueToConfigWith(key: key, intValue: 0)
        }

    }
    class func getBoolValueFromConfigWith(key: CDConfigKey) -> Bool {
        let valueC = getIntValueFromConfigWith(key: key)
        return valueC == 1
    }

    class func clearConfigFile() {
        let finaPath = databasePath()
        let nullDict = NSMutableDictionary(contentsOfFile: finaPath)
        nullDict?.removeAllObjects()
        writeToFileWith(writeDict: nullDict!, filePath: finaPath)

    }

    @discardableResult
    private class func writeToFileWith(writeDict: NSMutableDictionary, filePath: String) -> Bool {
        objc_sync_enter(self)
        let writeFlag = writeDict.write(toFile: filePath, atomically: true)
        objc_sync_exit(self)
        return writeFlag

    }
}
