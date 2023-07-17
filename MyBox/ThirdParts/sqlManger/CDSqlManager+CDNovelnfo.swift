//
//  CDSqlManager+CDNovelInfo.swift
//  MyBox
//
//  Created by cwx889303 on 2021/10/14.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import Foundation
import SQLite
// MARK: 文件夹
extension CDSqlManager {

    internal func createNovelTab() {
        do {
            let create = NovelInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_id, primaryKey: true)
                build.column(db_novelId)
                build.column(db_novelPath)
                build.column(db_novelName)
                build.column(db_importTime)
            }

            try db.run(create)
            CDPrint(item: "createNovelTab -->success")

        } catch {
            CDPrintManager.log("createNovelTab -->error:\(error)", type: .ErrorLog)
        }
    }

    public func addNovelInfo(novel: CDNovelInfo) {

        let novelId = queryMaxNovelId() + 1
        do {
            try db.run(NovelInfo.insert(
                        db_novelId <- novelId,
                        db_novelPath <- novel.novelPath,
                        db_novelName <- novel.novelName,
                        db_importTime <- novel.importTime)

            )

            CDPrint(item: "addNovelInfo-->success")
        } catch {
            CDPrintManager.log("addNovelInfo-->error:\(error)", type: .ErrorLog)
        }
    }

    public func queryMaxNovelId() -> Int {

        var maxFileId = 0
        do {
            maxFileId = try db.scalar(NovelInfo.select(db_novelId.max)) ?? 0
            CDPrint(item: "queryMaxNovelId -->success")
        } catch {
            CDPrintManager.log("queryMaxNovelId -->error:\(error)", type: .ErrorLog)
        }
        return maxFileId
    }

    public func queryAllNovel() -> [CDNovelInfo] {
        var novelArr: [CDNovelInfo] = []
        do {
            for item in try db.prepare(NovelInfo) {
                let info = CDNovelInfo()
                info.novelPath = item[db_novelPath]
                info.novelId = item[db_novelId]
                info.novelName = item[db_novelName]
                info.importTime = item[db_importTime]

                novelArr.append(info)
            }
        } catch {

        }

        return novelArr
    }

    public func deleteOneNovel(novelId: Int) {
        do {
            try db.run(NovelInfo.filter(db_novelId == novelId).delete())
            CDPrint(item: "deleteOneNovel-->success")
        } catch {
            CDPrintManager.log("deleteOneNovel-->error:\(error)", type: .ErrorLog)
        }
    }
}
