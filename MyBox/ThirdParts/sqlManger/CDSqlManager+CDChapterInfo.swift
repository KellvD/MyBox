//
//  CDSqlManager+CDChapterInfo.swift
//  MyBox
//
//  Created by cwx889303 on 2021/10/14.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import Foundation
import SQLite
extension CDSqlManager{
    
    internal func createChapterTab(){
        do{
            let create = ChapterInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_id, primaryKey: true)
                build.column(db_content)
                build.column(db_chapterName)
                build.column(db_charterId)
            }
            
            try db.run(create)
            CDPrint(item:"createChapterTab -->success")
            
        }catch{
            CDPrintManager.log("createChapterTab -->error:\(error)", type: .ErrorLog)
        }
    }
    
    
    public func addChapterInfo(info:CDChapterInfo) {
        
        let maxId = queryMaxChapterId() + 1
        do{
            try db.run(ChapterInfo.insert(
                        db_content <- info.content,
                        db_chapterName <- info.chapterName,
                        db_charterId <- maxId)
            )
            CDPrint(item:"addChapterInfo-->success")
        }catch {
            CDPrintManager.log("addChapterInfo-->error:\(error)", type: .ErrorLog)
        }
    }
    
    
    public func queryMaxChapterId()->Int{
        
        var maxId = 0
        do{
            maxId = try db.scalar(ChapterInfo.select(db_charterId.max)) ?? 0
            CDPrint(item:"queryMaxNovelId -->success")
        }catch{
            CDPrintManager.log("queryMaxNovelId -->error:\(error)", type: .ErrorLog)
        }
        return maxId
    }
    
    public func queryAllNovel()->[CDChapterInfo]{
        var arr:[CDChapterInfo] = []
        do {
            for item in try db.prepare(ChapterInfo) {
                let info = CDChapterInfo()
                info.content = item[db_content]
                info.chapterName = item[db_chapterName]
                info.charterId = item[db_charterId]
                
                arr.append(info)
            }
        } catch  {
            
        }
        
        return arr
    }
}
