//
//  CDSqlModel+CDMusicClassInfo.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import SQLite
// MARK: musicClassInfo
extension CDSqlManager {
    internal func createMusicClassInfoTab() {
        do {
            let create1 = MusicClassInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_id, primaryKey: true)
                build.column(db_classId)
                build.column(db_userId)
                build.column(db_className)
                build.column(db_classAvatar)
                build.column(db_classCreateTime)

            }
            try db.run(create1)
            CDPrint(item: "createMusicClassInfo -->success")

        } catch {
            CDPrintManager.log("createMusicClassInfo -->error:\(error)", type: .ErrorLog)
        }
    }

    public func addOneMusicClassInfoWith(classInfo: CDMusicClassInfo) {
        let count = queryMusicClassCount() + 1

        do {
            try db.run(MusicClassInfo.insert(
                db_classAvatar <- classInfo.classAvatar,
                db_className <- classInfo.className,
                db_classId <- count,
                db_classCreateTime <- classInfo.classCreateTime,
                db_userId <- classInfo.userId)

            )

            CDPrint(item: "addCDMusicClassInfo-->success")
        } catch {
            CDPrintManager.log("addCDMusicClassInfo-->error:\(error)", type: .ErrorLog)
        }
    }

    public func deleteOneMusicClassInfoWith(classId: Int) {
        do {
            try db.run(MusicClassInfo.filter((db_classId == classId) && (db_userId == CDUserId())).delete())
            CDPrint(item: "deleteOneMusicClassInfo-->success")
        } catch {
            CDPrintManager.log("deleteOneMusicClassInfo-->error:\(error)", type: .ErrorLog)
        }
    }

    public func deleteAllMusicClassInfoWith(userId: Int) {
        do {
            try db.run(MusicClassInfo.filter(db_userId == CDUserId()).delete())
            CDPrint(item: "deleteAllMusicClassInfo-->success")
        } catch {
            CDPrintManager.log("deleteAllMusicClassInfo-->error:\(error)", type: .ErrorLog)
        }
    }

    public func updateOneMusicClassInfoWith(classInfo: CDMusicClassInfo) {
        do {
            let sql = MusicClassInfo.filter((db_classId == classInfo.classId) && (db_userId == classInfo.userId))
            try db.run(sql.update(
                db_classAvatar <- classInfo.classAvatar,
                db_className <- classInfo.className,
                db_classId <- classInfo.classId))
            CDPrint(item: "updateOneMusicClassInfo-->success")
        } catch {
            CDPrintManager.log("updateOneMusicClassInfo -->error:\(error)", type: .ErrorLog)
        }
    }

    public func queryMusicClassCount() -> Int {

        var count = 0
        do {
            let sql = MusicClassInfo.filter(db_userId == CDUserId())

            for _ in try db.prepare(sql.select(db_musicId)) {
                count += 1
            }
            CDPrint(item: "queryMusicClassCount -->success")
        } catch {
            CDPrintManager.log("queryMusicClassCount -->error:\(error)", type: .ErrorLog)
        }
        return count
    }

    public func queryOneMusicClassWith(userId: Int, classId: Int) -> CDMusicClassInfo {
        let classInfo = CDMusicClassInfo()
        do {
            for item in try db.prepare(MusicClassInfo.filter((db_classId == classId) && (db_userId == userId))) {
                classInfo.classId = item[db_classId]
                classInfo.className = item[db_className]
                classInfo.classAvatar = item[db_classAvatar]
            }
        } catch {
            CDPrintManager.log("queryOneMusicClassWith -->error:\(error)", type: .ErrorLog)
        }
        return classInfo
    }

    public func queryAllMusicClass() -> [CDMusicClassInfo] {
        var classArr: [CDMusicClassInfo] = []

        do {
            for item in try db.prepare(MusicClassInfo.filter(db_userId == CDUserId())) {
                let classInfo = CDMusicClassInfo()
                classInfo.classId = item[db_classId]
                classInfo.className = item[db_className]
                classInfo.classAvatar = item[db_classAvatar]
                classArr.append(classInfo)
            }
        } catch {
            CDPrintManager.log("queryAllMusicClass -->error:\(error)", type: .ErrorLog)
        }
        return classArr
    }
}
