//
//  CDSqlModel+CDAttendanceInfo.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import SQLite
// MARK: musicClassInfo
extension CDSqlManager {
    internal func createAttendanceInfoTab() {
        do {
            let create1 = AttendanceInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_id, primaryKey: true)
                build.column(db_attendanceId)
                build.column(db_time)
                build.column(db_title)
                build.column(db_type)
                build.column(db_statue)

            }
            try db.run(create1)
            CDPrint(item: "createAttendanceInfo -->success")

        } catch {
            CDPrintManager.log("createAttendanceInfo -->error:\(error)", type: .ErrorLog)
        }
    }

    private func getAttendanceInfoFromItem(item: Row) -> CDAttendanceInfo {
        let info = CDAttendanceInfo()
        info.attendanceId = item[db_attendanceId]
        info.time = item[db_time]
        info.title = item[db_fakePwd]
        info.type = item[db_type]
        info.statue = item[db_statue]
        return info
    }

    public func addOneAttendanceInfoWith(info: CDAttendanceInfo) {
        do {
            try db.run(AttendanceInfo.insert(
                db_attendanceId <- info.attendanceId,
                db_time <- info.time,
                db_day <- info.day,
                db_month <- info.month,
                db_year <- info.year,
                db_title <- info.title,
                db_type <- info.type,
                db_statue <- info.statue
                )
            )
            CDPrint(item: "addOneAttendanceInfo -->success")
        } catch {
            CDPrintManager.log("addOneAttendanceInfo -->error:\(error)", type: .ErrorLog)
        }
    }

    public func deleteOneAttendanceInfo(attendanceId: Int) {
        do {
            try db.run(AttendanceInfo.filter(db_attendanceId == attendanceId).delete())
            // delete from UserInfo where db_userId = userId
            CDPrint(item: "deleteOneAttendanceInfo-->success")
        } catch {
            CDPrintManager.log("deleteOneAttendanceInfo-->error:\(error)", type: .ErrorLog)
        }
    }

    public func queryAllAttendanceInfo(day: Int) -> CDAttendanceInfo {
        var info: CDAttendanceInfo!
        do {
            for item in try db.prepare(AttendanceInfo.filter(db_day == day)) {
                info = getAttendanceInfoFromItem(item: item)
            }
        } catch {
            CDPrintManager.log("queryAllAttendanceInfoWith: day -->error:\(error)", type: .ErrorLog)

        }
        return info
    }

    public func queryAllAttendanceInfo(month: Int) -> CDAttendanceInfo {
        var info: CDAttendanceInfo!
        do {
            for item in try db.prepare(AttendanceInfo.filter(db_month == month)) {
                info = getAttendanceInfoFromItem(item: item)
            }
        } catch {
            CDPrintManager.log("queryAllAttendanceInfoWith: month -->error:\(error)", type: .ErrorLog)

        }
        return info
    }

    public func queryAllAttendanceInfo(year: Int) -> CDAttendanceInfo {
        var info: CDAttendanceInfo!
        do {
            for item in try db.prepare(AttendanceInfo.filter(db_year == year)) {
                info = getAttendanceInfoFromItem(item: item)
            }
        } catch {
            CDPrintManager.log("queryAllAttendanceInfoWith: year -->error:\(error)", type: .ErrorLog)

        }
        return info
    }

}
