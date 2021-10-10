//
//  CDSqlModel+CDMusicInfo.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import SQLite
//MARK:musicInfo
extension CDSqlManager {
    internal func createMusicInfoTab(){
        do{
            let create1 = MusicInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_id, primaryKey: true)
                build.column(db_musicId)
                build.column(db_musicMark)
                build.column(db_musicName)
                build.column(db_musicPath)
                build.column(db_musicSinger)
                build.column(db_musicClassId)
                build.column(db_musicTimeLength)
                build.column(db_userId)
                build.column(db_musicImage)

            }
            try db.run(create1)
            CDPrint(item:"createMusicInfo -->success")
        }catch{
            CDPrintManager.log("createMusicInfo -->error:\(error)", type: .ErrorLog)
        }
    }
    
    
    func addOneMusicInfoWith(musicInfo:CDMusicInfo) -> Void {
        let musicId = queryMusicCount() + 1

        do{
            try db.run(MusicInfo.insert(
                db_musicId <- musicId,
                db_musicMark <- musicInfo.musicMark,
                db_musicName <- musicInfo.musicName,
                db_musicPath <- musicInfo.musicPath,
                db_musicTimeLength <- musicInfo.musicTimeLength,
                db_musicSinger <- musicInfo.musicSinger,
                db_musicClassId <- musicInfo.musicClassId,
                db_userId <- musicInfo.userId,
                db_musicImage <- musicInfo.musicImage)
            )

            CDPrint(item:"addCDMusicInfoInfo-->success")
        }catch{
            CDPrintManager.log("addCDMusicInfoInfo-->error:\(error)", type: .ErrorLog)
        }
    }
    func deleteOneMusicInfoWith(musicId:Int) -> Void {
        do{
            try db.run(MusicInfo.filter((db_musicId == musicId) && (db_userId == CDUserId())).delete())
            CDPrint(item:"deleteOneMusicInfo-->success")
        }catch{
            CDPrintManager.log("deleteOneMusicInfo-->error:\(error)", type: .ErrorLog)
        }
    }
    func deleteOneClassAllMusicClassInfoWith(musicClassId:Int) -> Void {
        do{
            try db.run(MusicInfo.filter((db_musicClassId == musicClassId) && (db_userId == CDUserId())).delete())
            //delete from UserInfo where db_userId = userId
            CDPrint(item:"deleteOneClassAllMusicClassInfo-->success")
        }catch{
            CDPrintManager.log("deleteOneClassAllMusicClassInfo-->error:\(error)", type: .ErrorLog)
        }
    }
    func updateOneMusicInfoWith(musicInfo:CDMusicInfo) -> Void {
        do{
            let sql = MusicInfo.filter((db_musicId == musicInfo.musicId) && (db_userId == musicInfo.userId))
            try db.run(sql.update(
                db_musicId <- musicInfo.musicId,
                db_musicMark <- musicInfo.musicMark,
                db_musicName <- musicInfo.musicName,
                db_musicPath <- musicInfo.musicPath,
                db_musicTimeLength <- musicInfo.musicTimeLength,
                db_musicSinger <- musicInfo.musicSinger,
                db_musicClassId <- musicInfo.musicClassId,
                db_userId <- musicInfo.userId,
                db_musicImage <- musicInfo.musicImage)
            )
            CDPrint(item:"updateOneMusicInfo-->success")
        }catch{
            CDPrintManager.log("updateOneMusicInfo -->error:\(error)", type: .ErrorLog)
        }
    }
    func queryOneMusicInfoWith(userId:Int,musicId:Int) -> CDMusicInfo {
        let musicInfo = CDMusicInfo()

        for item in try! db.prepare(MusicInfo.filter((db_musicId == musicId) && (db_userId == userId))) {
            musicInfo.musicId = item[db_musicId]
            musicInfo.musicMark = item[db_musicMark]
            musicInfo.musicName = item[db_musicName]
            musicInfo.musicTimeLength = item[db_musicTimeLength]
            musicInfo.musicPath = item[db_musicPath]
            musicInfo.musicSinger = item[db_musicSinger]
            musicInfo.musicClassId = item[db_musicClassId]
            musicInfo.userId = item[db_userId]
            musicInfo.musicImage = item[db_musicImage]
        }
        return musicInfo
    }
    func queryAllMusic() -> [CDMusicInfo] {

        var musicArr:[CDMusicInfo] = []

        for item in try! db.prepare(MusicInfo) {
            let musicInfo = CDMusicInfo()
            musicInfo.musicId = item[db_musicId]
            musicInfo.musicMark = item[db_musicMark]
            musicInfo.musicName = item[db_musicName]
            musicInfo.musicTimeLength = item[db_musicTimeLength]
            musicInfo.musicPath = item[db_musicPath]
            musicInfo.musicSinger = item[db_musicSinger]
            musicInfo.musicClassId = item[db_musicClassId]
            musicInfo.userId = item[db_userId]
            musicInfo.musicImage = item[db_musicImage]
            musicArr.append(musicInfo)
        }
        return musicArr
    }
    func queryAllMusicWithClassId(classId:Int) -> [CDMusicInfo] {

        var musicArr:[CDMusicInfo] = []

        for item in try! db.prepare(MusicInfo.filter(db_musicClassId == classId)) {
            let musicInfo = CDMusicInfo()
            musicInfo.musicId = item[db_musicId]
            musicInfo.musicMark = item[db_musicMark]
            musicInfo.musicName = item[db_musicName]
            musicInfo.musicTimeLength = item[db_musicTimeLength]
            musicInfo.musicPath = item[db_musicPath]
            musicInfo.musicSinger = item[db_musicSinger]
            musicInfo.musicClassId = item[db_musicClassId]
            musicInfo.userId = item[db_userId]
            musicInfo.musicImage = item[db_musicImage]
            musicArr.append(musicInfo)
        }
        return musicArr
    }
    public func queryMusicCount()->Int{
        var count = 0
        do{
            let sql = MusicInfo.filter(db_userId == CDUserId())
            count = try db.scalar(sql.select(db_musicId.max)) ?? 0
            count += 1
        }catch{
            CDPrintManager.log("queryMusicCount -->error:\(error)", type: .ErrorLog)
        }
        return count
    }
}
