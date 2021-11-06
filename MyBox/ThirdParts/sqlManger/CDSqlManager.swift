//
//  CDSqlManager.swift
//  MyRule
//
//  Created by changdong on 2018/12/10.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import SQLite


class CDSqlManager: NSObject {

    static let shared = CDSqlManager()
    var db:Connection!
    let SafeFolder = Table("CDSafeFolder")
    
    private override init() {
        super.init()
        objc_sync_enter(self)
        openDatabase()
        objc_sync_exit(self)
    }

    func CDPrint(item:Any) {
        //print(item)
    }

    private func openDatabase() {
        let documentArr:[String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentPath = documentArr.first!
        let dbpath = "\(documentPath)/\(sqlFileName)"
        if !FileManager.default.fileExists(atPath: dbpath) {
            FileManager.default.createFile(atPath: dbpath, contents: nil, attributes: nil)
            db = try! Connection(dbpath)
            createTable()
            CDPrintManager.log("数据库创建成功", type: .InfoLog)
        }else{
            do{
                db = try Connection(dbpath)
                CDPrintManager.log("数据库连接成功", type: .InfoLog)
            }catch{
                CDPrintManager.log("数据库连接失败:\(error.localizedDescription)", type: .ErrorLog)
            }
            
        }
    }

    private func createTable() -> Void {
        CDPrintManager.log("创建数据库表", type: .InfoLog)
        createUserTab()
        createSafeFoldeTab()
        createMusicInfoTab()
        createMusicClassInfoTab()
        createSafeFileInfoTab()
        createAttendanceInfoTab()
        createNovelTab()
        createChapterTab()
        
        //默添加user
        let user = CDUserInfo()
        user.userId = FIRSTUSERID
        addOneUserInfoWith(usernInfo: user)
    }

    
    
}







