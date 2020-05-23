//
//  CDSqlManager.swift
//  MyRule
//
//  Created by changdong on 2018/12/10.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import SQLite

private let sqlFileName = "CDSQL.db"

private let db_id = Expression<Int>("id")
private var db_folderName = Expression<String>("folderName")
private var db_folderId = Expression<Int>("folderId")
private var db_folderType = Expression<Int>("folderType")
private var db_isLock = Expression<Int>("isLock")
private var db_fakeType = Expression<Int>("fakeType")
private var db_createTime = Expression<Int>("createTime")
private var db_folderPath = Expression<String>("folderPath")
private var db_fileId = Expression<Int>("fileId")
private var db_fileSize = Expression<Int>("fileSize")
private var db_fileWidth = Expression<Double>("fileWidth")
private var db_fileHeight = Expression<Double>("fileHeight")
private var db_timeLength = Expression<Double>("timeLength")
private var db_fileType = Expression<Int>("fileType")
private var db_fileName = Expression<String>("fileName")
private var db_fileText = Expression<String>("fileText")
private var db_thumbImagePath = Expression<String>("thumbImagePath")
private var db_filePath = Expression<String>("filePath")
private var db_grade = Expression<Int>("grade")
private var db_userId = Expression<Int>("userId")
private var db_markInfo = Expression<String>("markInfo")

private var db_basePwd = Expression<String>("basePwd")
private var db_fakePwd = Expression<String>("fakePwd")

//TODO:musicInfo
private var db_musicId = Expression<Int>("musicId")
private var db_musicName = Expression<String>("musicName")
private var db_musicMark = Expression<String>("musicMark")
private var db_musicTimeLength = Expression<Double>("musicTimeLength")
private var db_musicClassId = Expression<Int>("musicClassId")
private var db_musicSinger = Expression<String>("musicSinger")
private var db_musicPath = Expression<String>("musicPath")
private var db_musicImage = Expression<String>("musicImage")
//TODO:musicClass
private var db_classId = Expression<Int>("classId")
private var db_className = Expression<String>("className")
private var db_classAvatar = Expression<String>("classAvatar")
private var db_classCreateTime = Expression<Int>("classCreateTime")
private var db_superId = Expression<Int>("superId")



class CDSqlManager: NSObject {

    static var manager:CDSqlManager? = nil
    var db:Connection!
    let SafeFolder = Table("CDSafeFolder")
    let SafeFileInfo = Table("CDSafeFileInfo")
    let UserInfo = Table("CDUserInfo")
    let MusicInfo = Table("CDMusicInfo")
    let MusicClassInfo = Table("CDMusicClassInfo")
    
    static func instance()->CDSqlManager{

        manager = CDSqlManager()
        return manager!
    }
    override init() {
        super.init()
        objc_sync_enter(self)
        openDatabase()
        objc_sync_exit(self)
    }

    func CDPrint(item:Any) {
        print(item)
    }

    public func openDatabase(){
        let documentArr:[String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentPath = documentArr.first!
        let dbpath = "\(documentPath)/\(sqlFileName)"
        if !FileManager.default.fileExists(atPath: dbpath){
            FileManager.default.createFile(atPath: dbpath, contents: nil, attributes: nil)
            db = try! Connection(dbpath)
            createTable()
        }else{
            db = try! Connection(dbpath)
        }


    }

    func createTable() -> Void {

        do{
            let create = UserInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_userId)
                build.column(db_basePwd)
                build.column(db_fakePwd)
            }
            try db.run(create)
            CDPrint(item:"createUserInfo -->success")

        }catch{
            CDPrint(item:"createUserInfo -->error:\(error)")
        }

        do{
            let create = SafeFolder.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_id, primaryKey: true)
                build.column(db_folderName)
                build.column(db_folderId)
                build.column(db_folderType)
                build.column(db_isLock)
                build.column(db_fakeType)
                build.column(db_createTime)
                build.column(db_userId)
                build.column(db_folderPath)
                build.column(db_superId)
            }

            try db.run(create)
            CDPrint(item:"createSafeFolder -->success")

        }catch{
            CDPrint(item:"createSafeFolder -->error:\(error)")
        }

        do{
            let create1 = SafeFileInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_fileText)
                build.column(db_thumbImagePath)
                build.column(db_fileName)
                build.column(db_fileId)
                build.column(db_folderId)
                build.column(db_fileSize)
                build.column(db_fileWidth)
                build.column(db_fileHeight)
                build.column(db_timeLength)
                build.column(db_createTime)
                build.column(db_fileType)
                build.column(db_filePath)
                build.column(db_grade)
                build.column(db_userId)
                build.column(db_markInfo)
            }
            try db.run(create1)
            CDPrint(item:"createSafeFileInfo -->success")
        }catch{
            CDPrint(item:"createSafeFileInfo-->error:\(error)")
        }

        do{
            let create1 = MusicInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
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
            CDPrint(item:"createMusicInfo -->error:\(error)")
        }
        do{
            let create1 = MusicClassInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_classId)
                build.column(db_userId)
                build.column(db_className)
                build.column(db_classAvatar)
                build.column(db_classCreateTime)

            }
            try db.run(create1)
            CDPrint(item:"createMusicClassInfo -->success")
           
        }catch{
            CDPrint(item:"createMusicClassInfo -->error:\(error)")
        }
    }

    //TODO: userInfo
    public func addOneUserInfoWith(usernInfo:CDUserInfo){
        do{
            try db.run(UserInfo.insert(
                db_userId <- usernInfo.userId,
                db_basePwd <- usernInfo.basePwd,
                db_fakePwd <- usernInfo.fakePwd
                )
            )
            CDPrint(item:"addUserInfo -->success")
        }catch{
            CDPrint(item:"addUserIn -->error:\(error)")
        }
    }
    public func queryOneUserInfoWithUserId(userId:Int) -> CDUserInfo{

        let userInfo:CDUserInfo = CDUserInfo()

        for item in try! db.prepare(UserInfo.filter(db_userId == userId)) {
            userInfo.userId = item[db_userId]
            userInfo.basePwd = item[db_basePwd]
            userInfo.fakePwd = item[db_fakePwd]
        }
        return userInfo
    }

    public func queryUserRealKeyWithUserId(userId:Int) -> String{

        var realKey = String()

        do{
            let sql = UserInfo.filter(db_userId == CDUserId())
            for item in try db.prepare(sql.select(db_basePwd)) {
                realKey = item[db_basePwd]
            }
            CDPrint(item:"queryUserRealKeyWithUserId -->success")
        }catch{
            CDPrint(item:"queryUserRealKeyWithUserId -->error:\(error)")
        }
        return realKey
    }
    public func queryUserFakeKeyWithUserId(userId:Int) -> String{

        var fakeKey = String()

        do{
            let sql = UserInfo.filter(db_userId == CDUserId())
            for item in try db.prepare(sql.select(db_fakePwd)) {
                fakeKey = item[db_fakePwd]
            }
            CDPrint(item:"queryUserFakeKeyWithUserId-->success")
        }catch{
            CDPrint(item:"queryUserFakeKeyWithUserId-->error")
        }
        return fakeKey
    }

    public func updateUserRealPwdWith(pwd:String){
        do{
            let sql = UserInfo.filter(db_userId == CDUserId())

            try db.run(sql.update(db_basePwd <- pwd))
            CDPrint(item:"updateUserRealPwdWith-->success")
        }catch{
            CDPrint(item:"updateUserRealPwdWith-->error")
        }
        
    }
    public func updateUserFakePwdWith(pwd:String){
        do{
            let sql = UserInfo.filter(db_userId == CDUserId())

            try db.run(sql.update(db_basePwd <- pwd))
            CDPrint(item:"updateUserRealPwdWith-->success")
        }catch{
            CDPrint(item:"updateUserRealPwdWith-->error")
        }
    }
    public func deleteOneUser(useId:Int){
        do{
            try db.run(UserInfo.filter(db_userId == useId).delete())
            //delete from UserInfo where db_userId = userId
            CDPrint(item:"deleteOneUser-->success")
        }catch{
            CDPrint(item:"deleteOneUser-->error")
        }
    }

    //TODO:文件夹
    public func addSafeFoldeInfo(folder:CDSafeFolder) -> Int {

        let folderId = queryMaxSafeFolderId()+1

        do{
            try db.run(SafeFolder.insert(
                db_folderName <- folder.folderName,
                db_folderId <- folderId,
                db_folderType <- folder.folderType!.rawValue,
                db_isLock <- folder.isLock,
                db_fakeType <- folder.fakeType.rawValue,
                db_createTime <- folder.createTime,
                db_userId <- folder.userId,
                db_folderPath <- folder.folderPath,
                db_superId <- folder.superId,
                db_folderPath <- folder.folderPath)
            )

            CDPrint(item:"addSafeFoldeInfo-->success")
            
        }catch{
            CDPrint(item:"addSafeFoldeInfo-->error:\(error)")
        }
        return folderId
    }

    public func queryDefaultAllFolder() -> [Array<CDSafeFolder>]{
        var unlockArr:[CDSafeFolder] = []
        var lockArr:[CDSafeFolder] = []
        var totalArr:[Array<CDSafeFolder>] = []
        do {

            var sql = SafeFolder.where(db_fakeType == 1 && db_superId == ROOTSUPERID)

            if CDSignalTon.shareInstance().currentType != CDLoginReal{
                sql = SafeFolder.where(db_fakeType == 2 && db_superId == ROOTSUPERID)
            }
            for item in (try db.prepare(sql)) {
                let folderInfo = CDSafeFolder()
                folderInfo.folderName = item[db_folderName]
                folderInfo.folderId = item[db_folderId]
                folderInfo.folderType = NSFolderType(rawValue: item[db_folderType])
                folderInfo.isLock = item[db_isLock]
                folderInfo.fakeType = CDFakeType(rawValue: item[db_fakeType])!
                folderInfo.createTime = item[db_createTime]
                folderInfo.userId = item[db_userId]
                if folderInfo.isLock == LockOn {
                    unlockArr.append(folderInfo)
                }else{
                    lockArr.append(folderInfo)
                }
            }
            totalArr.insert(lockArr, at: 0)
            totalArr.insert(unlockArr, at: 1)
        } catch  {
            CDPrint(item:"queryDefaultAllFolder-->error:\(error)")
        }
        return totalArr

    }
    public func querySubAllFolder(folderId:Int) -> [CDSafeFolder]{
        var totalArr:[CDSafeFolder] = []
        do {
            for item in (try db.prepare(SafeFolder.where(db_superId == folderId))) {
                let folderInfo = CDSafeFolder()
                folderInfo.folderName = item[db_folderName]
                folderInfo.folderId = item[db_folderId]
                folderInfo.folderType = NSFolderType(rawValue: item[db_folderType])
                folderInfo.isLock = item[db_isLock]
                folderInfo.fakeType = CDFakeType(rawValue: item[db_fakeType])!
                folderInfo.createTime = item[db_createTime]
                folderInfo.userId = item[db_userId]
                folderInfo.superId = item[db_superId]
                folderInfo.folderPath = item[db_folderPath]
                folderInfo.isSelected = .CDFalse
                totalArr.append(folderInfo)
            }
        } catch  {
            CDPrint(item:"querySubAllFolder-->error:\(error)")
        }
        return totalArr

    }
    public func querySubAllFolderId(folderId:Int) -> [Int]{
        var totalArr:[Int] = []
        do {
            for item in (try db.prepare(SafeFolder.where(db_superId == folderId))) {
                let folderId = item[db_folderId]
                totalArr.append(folderId)
            }
        } catch  {
            CDPrint(item:"querySubAllFolder-->error:\(error)")
        }
        return totalArr

    }
    public func queryOneSafeFolderWith(folderId:Int) -> CDSafeFolder{
        let folderInfo = CDSafeFolder()

        for item in try! db.prepare(SafeFolder.filter(db_folderId == folderId)) {
            folderInfo.folderName = item[db_folderName]
            folderInfo.folderId = item[db_folderId]
            folderInfo.folderType =  NSFolderType(rawValue: item[db_folderType])
            folderInfo.isLock = item[db_isLock]
            folderInfo.fakeType = CDFakeType(rawValue: item[db_fakeType])!
            folderInfo.createTime = item[db_createTime]
            folderInfo.userId = item[db_userId]
            folderInfo.superId = item[db_superId]
            folderInfo.folderPath = item[db_folderPath]
        }
        return folderInfo
    }

    public func queryFolderSizeByFolderId(folderId:Int)->Int{

        var totalSize = 0

        do{
            let sql = SafeFolder.filter(db_folderId == folderId)
            for item in try db.prepare(sql.select(db_fileSize)) {
                totalSize += item[db_fileSize]
            }
            CDPrint(item:"queryFolderSizeByFolderId-->success")
        }catch{
            CDPrint(item:"queryFolderSizeByFolderId-->error:\(error)")
        }
        return totalSize
    }
    public func updateOneSafeFolderName(folderName:String,folderId:Int){

        do{
            let sql = UserInfo.filter(db_folderId == folderId)

            try db.run(sql.update(db_folderName <- folderName))
            CDPrint(item:"updateOneSafeFolderName-->success")
        }catch{
            CDPrint(item:"updateOneSafeFolderName-->error:\(error)")
        }
    }

    public func queryOneFolderSizeByFolder(folderId:Int) -> Int{

        var totalSize = 0
        do{
            let sql = SafeFileInfo.filter(db_folderId == folderId)
            for item in try db.prepare(sql.select(db_fileSize)) {
                let size = item[db_fileSize]
                totalSize += size
            }
            CDPrint(item:"queryOneFolderSizeByFolder-->success")
        }catch{
            CDPrint(item:"queryOneFolderSizeByFolder-->error:\(error)")
        }
        return totalSize
    }
    public func deleteOneFolder(folderId:Int){
        do{
            try db.run(SafeFolder.filter(db_folderId == folderId).delete())
            CDPrint(item:"deleteOneFolder-->success")
        }catch{
            CDPrint(item:"deleteOneFolder-->error:\(error)")
        }
    }
    public func deleteAllSubSafeFolder(superId:Int){
        do{
            try db.run(SafeFolder.filter(db_superId >= superId).delete())
            CDPrint(item:"deleteAllSubSafeFolder-->success")
        }catch{
            CDPrint(item:"deleteAllSubSafeFolder-->error:\(error)")
        }
    }
    public func queryMaxSafeFolderId()->Int{

        var maxFolderId = 0
        do{
            let sql = SafeFolder.filter(db_userId == CDUserId())

            for item in try db.prepare(sql.select(db_folderId)) {
                 let folderId = item[db_folderId]
                if  maxFolderId < folderId{
                    maxFolderId = folderId
                }
            }
            CDPrint(item:"querySafeFolderCount-->success")
        }catch{
            CDPrint(item:"querySafeFolderCount-->error:\(error)")
        }
        return maxFolderId
    }
    func queryAllOtherFolderWith(folderType:NSFolderType, folderId:Int) -> [Array<CDSafeFolder>] {
        var unlockArr:[CDSafeFolder] = []
        var lockArr:[CDSafeFolder] = []
        var totalArr:[Array<CDSafeFolder>] = []
        do {

            var sql = SafeFolder.where((db_folderId != folderId) && (db_folderType == folderType.rawValue))

            if CDSignalTon.shareInstance().currentType != CDLoginReal{
                sql = SafeFolder.where(
                    (db_folderId != folderId) &&
                    (db_folderType == folderType.rawValue) &&
                    (db_fakeType == 2))
            }
            for item in (try db.prepare(sql)) {
                let folderInfo = CDSafeFolder()
                folderInfo.folderName = item[db_folderName]
                folderInfo.folderId = item[db_folderId]
                folderInfo.folderType = NSFolderType(rawValue: item[db_folderType])
                folderInfo.isLock = item[db_isLock]
                folderInfo.fakeType = CDFakeType(rawValue: item[db_fakeType])!
                folderInfo.createTime = item[db_createTime]
                folderInfo.userId = item[db_userId]
                folderInfo.isSelected = .CDFalse
                if folderInfo.isLock == LockOn {
                    unlockArr.append(folderInfo)
                }else{
                    lockArr.append(folderInfo)
                }
            }
            totalArr.insert(lockArr, at: 0)
            totalArr.insert(unlockArr, at: 1)
        } catch  {
            CDPrint(item:"查询失败\(error)")
        }
        return totalArr
    }
    func updateOneSafeFileForMove(fileInfo:CDSafeFileInfo) {
        do{
            let sql = SafeFileInfo.filter(db_fileId == fileInfo.fileId)

            try db.run(sql.update(db_folderId <- fileInfo.folderId))
            CDPrint(item:"updateOneSafeFileForMove-->success")
        }catch{
            CDPrint(item:"updateOneSafeFileForMove-->error:\(error)")
        }
    }
    //TODO:
    public func addSafeFileInfo(fileInfo:CDSafeFileInfo) -> Void {

        let fileId = queryMaxFileId() + 1
        do{
            try db.run(SafeFileInfo.insert(
                db_fileId <- fileId,
                db_fileText <- fileInfo.fileText,
                db_thumbImagePath <- fileInfo.thumbImagePath,
                db_fileName <- fileInfo.fileName,
                db_folderId <- fileInfo.folderId,
                db_fileSize <- fileInfo.fileSize,
                db_fileWidth <- fileInfo.fileWidth,
                db_fileHeight <- fileInfo.fileHeight,
                db_timeLength <- fileInfo.timeLength,
                db_createTime <- fileInfo.createTime,
                db_fileType <- fileInfo.fileType!.rawValue,
                db_grade <- 1,
                db_filePath <- fileInfo.filePath,
                db_userId <- fileInfo.userId,
                db_markInfo <- fileInfo.markInfo)
            )

            CDPrint(item:"addSafeFileInfo-->success")
        }catch {
            CDPrint(item:"addSafeFileInfo-->error:\(error)")
        }
    }
    public func queryMaxFileId()->Int{

        var maxFileId = 0
        do{
            let sql = SafeFileInfo.filter(db_userId == CDUserId())

            for item in try db.prepare(sql.select(db_fileId)) {
                let folderId = item[db_fileId]
                if  maxFileId < folderId{
                    maxFileId = folderId
                }
            }
            CDPrint(item:"queryMaxFileId -->success")
        }catch{
            CDPrint(item:"queryMaxFileId -->error:\(error)")
        }
        return maxFileId
    }
    public func queryAllFileFromFolder(folderId:Int)-> Array<CDSafeFileInfo>{
        var fileArr:[CDSafeFileInfo] = []
        do {
            let sql = SafeFileInfo.filter(db_folderId == folderId ).order(db_createTime.desc)
            for item in try db.prepare(sql) {
                let file = CDSafeFileInfo()
                file.fileId = item[db_fileId]
                file.folderId = item[db_folderId]
                file.fileSize = item[db_fileSize]
                file.fileWidth = item[db_fileWidth]
                file.fileHeight = item[db_fileHeight]
                file.timeLength = item[db_timeLength]
                file.createTime = item[db_createTime]
                file.filePath = item[db_filePath]
                file.fileType = NSFileType(rawValue: item[db_fileType])
                file.grade = NSFileGrade(rawValue: item[db_grade])
                file.fileName = item[db_fileName]
                file.fileText = item[db_fileText]
                file.thumbImagePath = item[db_thumbImagePath]
                file.userId = item[db_userId]
                file.markInfo = item[db_markInfo]
                file.isSelected = .CDFalse
                fileArr.append(file)
            }
        } catch  {
            CDPrint(item:"queryAllFileFromFolder -->error:\(error)")
        }
        return fileArr
    }
   
    public func queryOneSafeFileWithFileId(fileId:Int)-> CDSafeFileInfo{
        let file = CDSafeFileInfo()
        do {
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            for item in try db.prepare(sql) {
                file.fileId = item[db_fileId]
                file.folderId = item[db_folderId]
                file.fileSize = item[db_fileSize]
                file.fileWidth = item[db_fileWidth]
                file.fileHeight = item[db_fileHeight]
                file.timeLength = item[db_timeLength]
                file.createTime = item[db_createTime]
                file.filePath = item[db_filePath]
                file.fileType = NSFileType(rawValue: item[db_fileType])
                file.grade = NSFileGrade(rawValue: item[db_grade])
                file.fileName = item[db_fileName]
                file.fileText = item[db_fileText]
                file.thumbImagePath = item[db_thumbImagePath]
                file.userId = item[db_userId]
                file.markInfo = item[db_markInfo]
                
            }
        } catch  {
            CDPrint(item:"queryOneSafeFileWithFileId -->error:\(error)")
        }
        return file
    }
    public func deleteOneSafeFile(fileId:Int){
        do{
            try db.run(SafeFileInfo.filter(db_fileId == fileId).delete())
            //delete from SafeFile where db_fileId = fileId
            CDPrint(item:"deleteOneSafeFile-->success")
        }catch{
            CDPrint(item:"deleteOneSafeFile-->error:\(error)")
        }
    }
    public func deleteAllSubSafeFile(folderId:Int){
        do{
            try db.run(SafeFileInfo.filter(db_folderId == folderId).delete())
            CDPrint(item:"deleteAllSubSafeFile-->success")
        }catch{
            CDPrint(item:"deleteAllSubSafeFile-->error:\(error)")
        }
    }
    public func updateOneSafeFileIsLock(isLock:Int,folderId:Int){

        do{
            let sql = SafeFileInfo.filter(db_folderId == folderId)
            try db.run(sql.update(db_isLock <- isLock))
            CDPrint(item:"updateOneSafeFileIsLock-->success")
        }catch{
            CDPrint(item:"updateOneSafeFileIsLock-->error:\(error)")
        }
    }
    public func updateOneSafeFileName(fileName:String,fileId:Int){

        do{
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            try db.run(sql.update(db_fileName <- fileName))
            CDPrint(item:"updateOneSafeFileName-->success")
        }catch{
            CDPrint(item:"updateOneSafeFileName-->error:\(error)")
        }
    }
    public func updateOneSafeFileMarkInfo(markInfo:String,fileId:Int){

        do{
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            try db.run(sql.update(db_markInfo <- markInfo))
            CDPrint(item:"updateOneSafeFileMarkInfo-->success")
        }catch{
            CDPrint(item:"updateOneSafeFileMarkInfo-->error:\(error)")
        }
    }
    public func updateOneSafeFileFakeType(fakeType:CDFakeType,folderId:Int){

        do{
            let sql = SafeFileInfo.filter(db_folderId == folderId)
            try db.run(sql.update(db_fakeType <- fakeType.rawValue))
            CDPrint(item:"updateOneSafeFileIndentity-->success")
        }catch{
            CDPrint(item:"updateOneSafeFileIndentity-->error:\(error)")
        }
    }

    func updateOneSafeFileGrade(grade:NSFileGrade,fileId:Int) {
        do{
            let sql = SafeFileInfo.filter((db_fileId == fileId)&&(db_userId == CDUserId()))
            try db.run(sql.update(db_grade <- grade.rawValue))
            CDPrint(item:"updateOneSafeFileGrade-->success")
        }catch{
            CDPrint(item:"updateOneSafeFileGrade-->error:\(error)")
        }
    }
    func queryOneSafeFileGrade(fileId:Int) ->NSFileGrade {
        var grade = NSFileGrade(rawValue: 1)
        do{
            let sql = SafeFileInfo.filter(db_userId == CDUserId())

            for item in try db.prepare(sql.select(db_grade)) {
                grade = NSFileGrade(rawValue: item[db_grade])

            }
            CDPrint(item:"queryMaxFileId -->success")
        }catch{
            CDPrint(item:"queryMaxFileId -->error:\(error)")
        }
        return grade!
    }

    //TODO:extension
    //获取文件夹下所有子文件和子文件夹
    func queryAllContentFromFolder(folderId:Int) -> (foldersArr:[CDSafeFolder],filesArr:[CDSafeFileInfo]) {
        var subFileArr = queryAllFileFromFolder(folderId: folderId)
        var subFolderArr = querySubAllFolder(folderId: folderId)
        subFileArr.sort { (obj1, obj2) -> Bool in
            return obj1.createTime > obj2.createTime
        }
        
        subFolderArr.sort { (obj1, obj2) -> Bool in
            return obj1.createTime > obj2.createTime
        }
        
        return (subFolderArr,subFileArr)
    
    }
    //TODO:musicInfo
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
            CDPrint(item:"addCDMusicInfoInfo-->error:\(error)")
        }
    }
    func deleteOneMusicInfoWith(musicId:Int) -> Void {
        do{
            try db.run(MusicInfo.filter((db_musicId == musicId) && (db_userId == CDUserId())).delete())
            CDPrint(item:"deleteOneMusicInfo-->success")
        }catch{
            CDPrint(item:"deleteOneMusicInfo-->error:\(error)")
        }
    }
    func deleteOneClassAllMusicClassInfoWith(musicClassId:Int) -> Void {
        do{
            try db.run(MusicInfo.filter((db_musicClassId == musicClassId) && (db_userId == CDUserId())).delete())
            //delete from UserInfo where db_userId = userId
            CDPrint(item:"deleteOneClassAllMusicClassInfo-->success")
        }catch{
            CDPrint(item:"deleteOneClassAllMusicClassInfo-->error:\(error)")
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
            CDPrint(item:"updateOneMusicInfo -->error:\(error)")
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

            for _ in try db.prepare(sql.select(db_musicId)) {
                count += 1
            }
            CDPrint(item:"queryMusicCount -->success")
        }catch{
            CDPrint(item:"queryMusicCount -->error:\(error)")
        }
        return count
    }

    //TODO:musicClassInfo
    func addOneMusicClassInfoWith(classInfo:CDMusicClassInfo) -> Void {
        let count = queryMusicClassCount() + 1

        do{
            try db.run(MusicClassInfo.insert(
                db_classAvatar <- classInfo.classAvatar,
                db_className <- classInfo.className,
                db_classId <- count,
                db_classCreateTime <- classInfo.classCreateTime,
                db_userId <- classInfo.userId)

            )

            CDPrint(item:"addCDMusicClassInfo-->success")
        }catch{
            CDPrint(item:"addCDMusicClassInfo-->error:\(error)")
        }
    }
    func deleteOneMusicClassInfoWith(classId:Int) -> Void {
        do{
            try db.run(MusicClassInfo.filter((db_classId == classId) && (db_userId == CDUserId())).delete())
            CDPrint(item:"deleteOneMusicClassInfo-->success")
        }catch{
            CDPrint(item:"deleteOneMusicClassInfo-->error:\(error)")
        }
    }
    func deleteAllMusicClassInfoWith(userId:Int) -> Void {
        do{
            try db.run(MusicClassInfo.filter(db_userId == CDUserId()).delete())
            CDPrint(item:"deleteAllMusicClassInfo-->success")
        }catch{
            CDPrint(item:"deleteAllMusicClassInfo-->error:\(error)")
        }
    }
    func updateOneMusicClassInfoWith(classInfo:CDMusicClassInfo) -> Void {
        do{
            let sql = MusicClassInfo.filter((db_classId == classInfo.classId) && (db_userId == classInfo.userId))
            try db.run(sql.update(
                db_classAvatar <- classInfo.classAvatar,
                db_className <- classInfo.className,
                db_classId <- classInfo.classId))
            CDPrint(item:"updateOneMusicClassInfo-->success")
        }catch{
            CDPrint(item:"updateOneMusicClassInfo -->error:\(error)")
        }
    }
    public func queryMusicClassCount()->Int{

        var count = 0
        do{
            let sql = MusicClassInfo.filter(db_userId == CDUserId())

            for _ in try db.prepare(sql.select(db_musicId)) {
                count += 1
            }
            CDPrint(item:"queryMusicClassCount -->success")
        }catch{
            CDPrint(item:"queryMusicClassCount -->error:\(error)")
        }
        return count
    }
    func queryOneMusicClassWith(userId:Int,classId:Int) -> CDMusicClassInfo {
        let classInfo = CDMusicClassInfo()

        for item in try! db.prepare(MusicClassInfo.filter((db_classId == classId) && (db_userId == userId))) {
            classInfo.classId = item[db_classId]
            classInfo.className = item[db_className]
            classInfo.classAvatar = item[db_classAvatar]
        }
        return classInfo
    }
    func queryAllMusicClass() -> [CDMusicClassInfo] {
        var classArr:[CDMusicClassInfo] = []


        for item in try! db.prepare(MusicClassInfo.filter(db_userId == CDUserId())) {
            let classInfo = CDMusicClassInfo()
            classInfo.classId = item[db_classId]
            classInfo.className = item[db_className]
            classInfo.classAvatar = item[db_classAvatar]
            classArr.append(classInfo)
        }
        return classArr
    }
}
