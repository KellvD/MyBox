//
//  CDLogManager.swift
//  CDLog
//
//  Created by changdong on 2020/11/23.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

open class CDPrintManager: NSObject {
    enum CDLogLevel: Int {
        case DebugLog = 0
        case InfoLog = 1
        case ErrorLog = 2
        case WarnLog = 3
        case AllLog = 4
    }

    static private let _queue = DispatchQueue(label: "myBox.log")
    static private var _gtype: CDLogLevel!
    static private let levelArr = ["[DEBUG💙]", "[INFO💚]", "[Warn‼️]", "[ERROR💔]"]
    class func log(_ items: Any..., file: String = #file, line: Int = #line, type: CDLogLevel) {
        _gtype = type
        create(levelArr[type.rawValue], items, file, line)
    }

    private class func create(_ level: String, _ items: [Any], _ file: String, _ line: Int) {
        let date = dateFormat()
        let fileName = file.lastPathComponent
        let message = items.map({ String(describing: $0) }).joined(separator: " ")
        var result = " \(date) " + "[\(fileName):\(line)] " + message
        if  CDLogBean.isOn {
            if !FileManager.default.fileExists(atPath: CDLogBean.logPath) {
                print("[Warn‼️]" + " \(date) " + "[\(fileName):\(line)] " + "日志文件不存在")
                CDLogBean.closeLogConfig()
            } else {
                writeLogToFile(message: result)
            }
        }
        result = level + result
        _queue.async {
            Swift.print(result)

        }
    }

    private class func dateFormat() -> String {
        let formter = DateFormatter()
        formter.dateFormat = "[yyyy-MM-dd HH:mm:ss]"
        let date = Date()
        let dateStr = formter.string(from: date)
        return dateStr
    }

    private class func writeLogToFile(message: String) {

        if  CDLogBean.logLevel == .AllLog {
            writeToFileWith(message: "[LOG]" + message)
        } else if CDLogBean.logLevel == _gtype {
            writeToFileWith(message: levelArr[_gtype.rawValue] + message)
        }
    }
    private class func writeToFileWith(message: String) {

        objc_sync_enter(self)
        let handle = FileHandle(forUpdatingAtPath: CDLogBean.logPath)!
        handle.seekToEndOfFile()
        let content = message + "\n"
        let data = content.data(using: .utf8)!
        handle.write(data)
        handle.closeFile()
        objc_sync_exit(self)
    }

}
