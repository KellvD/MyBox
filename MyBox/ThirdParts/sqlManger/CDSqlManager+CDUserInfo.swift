//
//  CDSqlManager+CDUserInfo.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//
// MARK: userInfo
import UIKit
import SQLite

extension CDSqlManager {

    internal func createUserTab() {
        do {
            let create = UserInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_userId)
                build.column(db_basePwd)
                build.column(db_fakePwd)
            }
            try db.run(create)
            CDPrint(item: "createUserInfo -->success")

        } catch {
            CDPrintManager.log("createUserInfo -->error:\(error)", type: .ErrorLog)
        }
    }

    public func addOneUserInfoWith(usernInfo: CDUserInfo) {
        do {
            try db.run(UserInfo.insert(
                db_userId <- usernInfo.userId,
                db_basePwd <- usernInfo.basePwd,
                db_fakePwd <- usernInfo.fakePwd
                )
            )
            CDPrint(item: "addUserInfo -->success")
        } catch {
            CDPrintManager.log("addUserIn -->error:\(error)", type: .ErrorLog)
        }
    }

    public func queryOneUserInfoWithUserId(userId: Int) -> CDUserInfo {
        let userInfo: CDUserInfo = CDUserInfo()
        for item in try! db.prepare(UserInfo.filter(db_userId == userId)) {
            userInfo.userId = item[db_userId]
            userInfo.basePwd = item[db_basePwd]
            userInfo.fakePwd = item[db_fakePwd]
        }
        return userInfo
    }

    public func queryUserRealKeyWithUserId(userId: Int) -> String {

        var realKey: String? = ""
        do {
            let sql = UserInfo.filter(db_userId == CDUserId())
            for item in try db.prepare(sql.select(db_basePwd)) {
                realKey = item[db_basePwd]
            }
            CDPrint(item: "queryUserRealKeyWithUserId -->success")
        } catch {
            CDPrintManager.log("queryUserRealKeyWithUserId -->error:\(error)", type: .ErrorLog)
        }
        return realKey!
    }
    public func queryUserFakeKeyWithUserId(userId: Int) -> String {

        var fakeKey: String? = ""
        do {
            let sql = UserInfo.filter(db_userId == CDUserId())
            for item in try db.prepare(sql.select(db_fakePwd)) {
                fakeKey = item[db_fakePwd]
            }
            CDPrint(item: "queryUserFakeKeyWithUserId-->success")
        } catch {
            CDPrintManager.log("queryUserFakeKeyWithUserId-->error:\(error)", type: .ErrorLog)
        }
        return fakeKey!
    }

    public func updateUserRealPwdWith(pwd: String) {
        do {
            let sql = UserInfo.filter(db_userId == CDUserId())

            try db.run(sql.update(db_basePwd <- pwd))
            CDPrint(item: "updateUserRealPwdWith-->success")
        } catch {
            CDPrintManager.log("updateUserRealPwdWith-->error:\(error)", type: .ErrorLog)
        }

    }

    public func updateUserFakePwdWith(pwd: String) {
        do {
            let sql = UserInfo.filter(db_userId == CDUserId())

            try db.run(sql.update(db_basePwd <- pwd))
            CDPrint(item: "updateUserRealPwdWith-->success")
        } catch {
            CDPrintManager.log("updateUserRealPwdWith-->error:\(error)", type: .ErrorLog)
        }
    }

    public func deleteOneUser(useId: Int) {
        do {
            try db.run(UserInfo.filter(db_userId == useId).delete())
            // delete from UserInfo where db_userId = userId
            CDPrint(item: "deleteOneUser-->success")
        } catch {
            CDPrintManager.log("deleteOneUser-->error:\(error)", type: .ErrorLog)
        }
    }
}
