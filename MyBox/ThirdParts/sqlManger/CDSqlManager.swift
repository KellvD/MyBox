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
private var db_modifyTime = Expression<Int>("modifyTime")
private var db_accessTime = Expression<Int>("accessTime")
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

//MARK:musicInfo
private var db_musicId = Expression<Int>("musicId")
private var db_musicName = Expression<String>("musicName")
private var db_musicMark = Expression<String>("musicMark")
private var db_musicTimeLength = Expression<Double>("musicTimeLength")
private var db_musicClassId = Expression<Int>("musicClassId")
private var db_musicSinger = Expression<String>("musicSinger")
private var db_musicPath = Expression<String>("musicPath")
private var db_musicImage = Expression<String>("musicImage")
//MARK:musicClass
private var db_classId = Expression<Int>("classId")
private var db_className = Expression<String>("className")
private var db_classAvatar = Expression<String>("classAvatar")
private var db_classCreateTime = Expression<Int>("classCreateTime")
private var db_superId = Expression<Int>("superId")



class CDSqlManager: NSObject {

    static let shared = CDSqlManager()
    var db:Connection!
    let SafeFolder = Table("CDSafeFolder")
    let SafeFileInfo = Table("CDSafeFileInfo")
    let UserInfo = Table("CDUserInfo")
    let MusicInfo = Table("CDMusicInfo")
    let MusicClassInfo = Table("CDMusicClassInfo")
    override init() {
        super.init()
        objc_sync_enter(self)
        openDatabase()
        
        objc_sync_exit(self)
    }

    func CDPrint(item:Any) {
        //print(item)
    }

    public func openDatabase() {
        let documentArr:[String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentPath = documentArr.first!
        let dbpath = "\(documentPath)/\(sqlFileName)"
        if !FileManager.default.fileExists(atPath: dbpath) {
            FileManager.default.createFile(atPath: dbpath, contents: nil, attributes: nil)
            db = try! Connection(dbpath)
            createTable()
            CDPrintManager.log("数据库创建成功", type: .InfoLog)
        }else{
            db = try! Connection(dbpath)
        }
    }

    func createTable() -> Void {
        CDPrintManager.log("创建数据库表", type: .InfoLog)
        do{
            let create = UserInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_userId)
                build.column(db_basePwd)
                build.column(db_fakePwd)
            }
            try db.run(create)
            CDPrint(item:"createUserInfo -->success")

        }catch{
            CDPrintManager.log("createUserInfo -->error:\(error)", type: .ErrorLog)
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
                build.column(db_modifyTime)
                build.column(db_accessTime)
                build.column(db_userId)
                build.column(db_folderPath)
                build.column(db_superId)
            }

            try db.run(create)
            CDPrint(item:"createSafeFolder -->success")

        }catch{
            CDPrintManager.log("createSafeFolder -->error:\(error)", type: .ErrorLog)
        }

        do{
            let create1 = SafeFileInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_id, primaryKey: true)
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
                build.column(db_modifyTime)
                build.column(db_accessTime)
                build.column(db_fileType)
                build.column(db_filePath)
                build.column(db_grade)
                build.column(db_userId)
                build.column(db_markInfo)
                build.column(db_folderType)
            }
            try db.run(create1)
            CDPrint(item:"createSafeFileInfo -->success")
        }catch{
            CDPrintManager.log("createSafeFileInfo-->error:\(error)", type: .ErrorLog)
        }

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
        
        do{
            let create1 = MusicClassInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_id, primaryKey: true)
                build.column(db_classId)
                build.column(db_userId)
                build.column(db_className)
                build.column(db_classAvatar)
                build.column(db_classCreateTime)

            }
            try db.run(create1)
            CDPrint(item:"createMusicClassInfo -->success")
           
        }catch{
            CDPrintManager.log("createMusicClassInfo -->error:\(error)", type: .ErrorLog)
        }
        
        //默添加user
        let user = CDUserInfo()
        user.userId = FIRSTUSERID
        addOneUserInfoWith(usernInfo: user)
    }
    
    func firstUpdate() {
        do{
            try db.run(
                SafeFolder.addColumn(db_accessTime, defaultValue: 0)
            )
            CDPrint(item:"addUserInfo -->success")
        }catch{
            CDPrintManager.log("addUserIn -->error:\(error)", type: .ErrorLog)
        }
        
    }
    
    
    //MARK:extension
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

}
//MARK: userInfo
extension CDSqlManager{
    
    public func addOneUserInfoWith(usernInfo:CDUserInfo) {
        do{
            try db.run(UserInfo.insert(
                db_userId <- usernInfo.userId,
                db_basePwd <- usernInfo.basePwd,
                db_fakePwd <- usernInfo.fakePwd
                )
            )
            CDPrint(item:"addUserInfo -->success")
        }catch{
            CDPrintManager.log("addUserIn -->error:\(error)", type: .ErrorLog)
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

        var realKey:String? = ""
        do{
            let sql = UserInfo.filter(db_userId == CDUserId())
            for item in try db.prepare(sql.select(db_basePwd)) {
                realKey = item[db_basePwd]
            }
            CDPrint(item:"queryUserRealKeyWithUserId -->success")
        }catch{
            CDPrintManager.log("queryUserRealKeyWithUserId -->error:\(error)", type: .ErrorLog)
        }
        return realKey!
    }
    public func queryUserFakeKeyWithUserId(userId:Int) -> String{

        var fakeKey:String? = ""
        do{
            let sql = UserInfo.filter(db_userId == CDUserId())
            for item in try db.prepare(sql.select(db_fakePwd)) {
                fakeKey = item[db_fakePwd]
            }
            CDPrint(item:"queryUserFakeKeyWithUserId-->success")
        }catch{
            CDPrintManager.log("queryUserFakeKeyWithUserId-->error:\(error)", type: .ErrorLog)
        }
        return fakeKey!
    }

    public func updateUserRealPwdWith(pwd:String) {
        do{
            let sql = UserInfo.filter(db_userId == CDUserId())

            try db.run(sql.update(db_basePwd <- pwd))
            CDPrint(item:"updateUserRealPwdWith-->success")
        }catch{
            CDPrintManager.log("updateUserRealPwdWith-->error:\(error)", type: .ErrorLog)
        }
        
    }
    
    public func updateUserFakePwdWith(pwd:String) {
        do{
            let sql = UserInfo.filter(db_userId == CDUserId())

            try db.run(sql.update(db_basePwd <- pwd))
            CDPrint(item:"updateUserRealPwdWith-->success")
        }catch{
            CDPrintManager.log("updateUserRealPwdWith-->error:\(error)", type: .ErrorLog)
        }
    }
    
    public func deleteOneUser(useId:Int) {
        do{
            try db.run(UserInfo.filter(db_userId == useId).delete())
            //delete from UserInfo where db_userId = userId
            CDPrint(item:"deleteOneUser-->success")
        }catch{
            CDPrintManager.log("deleteOneUser-->error:\(error)", type: .ErrorLog)
        }
    }
}


extension CDSqlManager{
/** --------------------------------------------------- **/
    //MARK: SafeFile
    private func getSafeFileInfoFromItem(item:Row) -> CDSafeFileInfo {
        let file = CDSafeFileInfo()
        file.fileId = item[db_fileId]
        file.folderId = item[db_folderId]
        file.fileSize = item[db_fileSize]
        file.fileWidth = item[db_fileWidth]
        file.fileHeight = item[db_fileHeight]
        file.timeLength = item[db_timeLength]
        file.createTime = item[db_createTime]
        file.modifyTime = item[db_modifyTime]
        file.accessTime = item[db_accessTime]
        file.filePath = item[db_filePath]
        file.fileType = NSFileType(rawValue: item[db_fileType])
        file.grade = NSFileGrade(rawValue: item[db_grade])
        file.fileName = item[db_fileName]
        file.fileText = item[db_fileText]
        file.thumbImagePath = item[db_thumbImagePath]
        file.userId = item[db_userId]
        file.markInfo = item[db_markInfo]
        file.isSelected = .CDFalse
        file.folderType = NSFolderType(rawValue: item[db_folderType])
        
        return file
    }
    
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
                db_modifyTime <- fileInfo.modifyTime,
                db_accessTime <- fileInfo.accessTime,
                db_fileType <- fileInfo.fileType!.rawValue,
                db_grade <- 1,
                db_filePath <- fileInfo.filePath,
                db_userId <- fileInfo.userId,
                db_markInfo <- fileInfo.markInfo,
                db_folderType <- fileInfo.folderType!.rawValue)
            )

            CDPrint(item:"addSafeFileInfo-->success")
        }catch {
            CDPrintManager.log("addSafeFileInfo-->error:\(error)", type: .ErrorLog)
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
            CDPrintManager.log("queryMaxFileId -->error:\(error)", type: .ErrorLog)
        }
        return maxFileId
    }
    public func queryAllFileFromFolder(folderId:Int)-> Array<CDSafeFileInfo>{
        var fileArr:[CDSafeFileInfo] = []
        do {
            let sql = SafeFileInfo.filter(db_folderId == folderId ).order(db_createTime.desc)
            for item in try db.prepare(sql) {
                let file = getSafeFileInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch  {
            CDPrintManager.log("queryAllFileFromFolder -->error:\(error)", type: .ErrorLog)
        }
        return fileArr
    }
   
    public func queryOneSafeFileWithFileId(fileId:Int)-> CDSafeFileInfo{
        var file:CDSafeFileInfo!
        do {
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            for item in try db.prepare(sql) {
                file = getSafeFileInfoFromItem(item: item)
                
            }
        } catch  {
            CDPrintManager.log("queryOneSafeFileWithFileId -->error:\(error)", type: .ErrorLog)
        }
        return file
    }
    
    func queryOneSafeFileGrade(fileId:Int) ->NSFileGrade {
        var grade = NSFileGrade(rawValue: 1)
        do{
            let sql = SafeFileInfo.filter(db_fileId == fileId)
           
            for item in try db.prepare(sql.select(db_grade)) {
                grade = NSFileGrade(rawValue: item[db_grade])

            }
        }catch{
            CDPrintManager.log("queryOneSafeFileGrade -->error:\(error)", type: .ErrorLog)
        }
        return grade!
    }
    
    func queryEveryFileCount()->(imageCount:Int,videoCount:Int,audioCount:Int,otherCount:Int){
        do {
            
            let imageCount = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.ImageFolder.rawValue).count)
            let videoCount = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.VideoFolder.rawValue).count)
            let audioCount = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.AudioFolder.rawValue).count)
            let otherCount = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.TextFolder.rawValue).count)
            
            //            for item in try db.prepare("select count(*) from CDSafeFileInfo where folderType = 0") {
            //                CDPrint(item: item)
            //            }
            return(imageCount,videoCount,audioCount,otherCount)
            
        } catch  {
            CDPrintManager.log("queryEveryFileCount -->error:\(error)", type: .ErrorLog)
        }
        return(0,0,0,0)
    }
    
    func queryEveryFileTotalSize()->(imageSize:Int,videoSize:Int,audioSize:Int,otherSize:Int){
        do {
       
            let imageSize = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.ImageFolder.rawValue).select(db_fileSize.sum)) ?? 0
            let videoSize = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.VideoFolder.rawValue).select(db_fileSize.sum)) ?? 0
            let audioSize = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.AudioFolder.rawValue).select(db_fileSize.sum)) ?? 0
            let otherSize =  try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.TextFolder.rawValue).select(db_fileSize.sum)) ?? 0
            return(imageSize,videoSize,audioSize,otherSize)
        } catch  {
            CDPrintManager.log("queryEveryFileTotalSize -->error:\(error)", type: .ErrorLog)
        }
        return(0,0,0,0)
    }
    
    public func queryAllTextSafeFile()-> [CDSafeFileInfo]{
        var fileArr:[CDSafeFileInfo] = []
        do {
            let sql = SafeFileInfo.filter(db_fileType == NSFileType.TxtType.rawValue)
            for item in try db.prepare(sql) {
                let file = getSafeFileInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch  {
            CDPrintManager.log("queryAllTextSafeFile -->error:\(error)", type: .ErrorLog)
        }
        return fileArr
    }
    
    public func updateOneSafeFileName(fileName:String,fileId:Int) {

        do{
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            try db.run(sql.update(db_fileName <- fileName,db_modifyTime <- GetTimestamp()))
        }catch{
            CDPrintManager.log("updateOneSafeFileName-->error:\(error)", type: .ErrorLog)
        }
    }
    public func updateOneSafeFileMarkInfo(markInfo:String,fileId:Int) {

        do{
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            try db.run(sql.update(db_markInfo <- markInfo,db_modifyTime <- GetTimestamp()))
        }catch{
            CDPrintManager.log("updateOneSafeFileMarkInfo-->error:\(error)", type: .ErrorLog)
        }
    }

    func updateOneSafeFileGrade(grade:NSFileGrade,fileId:Int) {
        do{
            let sql = SafeFileInfo.filter((db_fileId == fileId)&&(db_userId == CDUserId()))
            try db.run(sql.update(db_grade <- grade.rawValue,db_modifyTime <- GetTimestamp()))
        }catch{
            CDPrintManager.log("updateOneSafeFileGrade-->error:\(error)", type: .ErrorLog)
        }
    }
    
    /*
    文件移动文件夹，更新文件新的folderID
    */
    func updateOneSafeFileForMove(fileInfo:CDSafeFileInfo) {
        do{
            let sql = SafeFileInfo.filter(db_fileId == fileInfo.fileId)

            try db.run(sql.update(db_folderId <- fileInfo.folderId,db_modifyTime <- GetTimestamp()))
        }catch{
            CDPrintManager.log("updateOneSafeFileForMove-->error:\(error)", type: .ErrorLog)
        }
    }
    
    public func updateOneSafeFileModifyTime(modifyTime:Int,fileId:Int) {

        do{
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            try db.run(sql.update(db_modifyTime <- modifyTime))
        }catch{
            CDPrintManager.log("updateOneSafeFileModifyTime-->error:\(error)", type: .ErrorLog)
        }
    }
    
    public func updateOneSafeFileAccessTime(accessTime:Int,fileId:Int) {

        do{
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            try db.run(sql.update(db_accessTime <- accessTime))
        }catch{
            CDPrintManager.log("updateOneSafeFileAccessTime-->error:\(error)", type: .ErrorLog)
        }
    }
    
    public func deleteOneSafeFile(fileId:Int) {
        do{
            try db.run(SafeFileInfo.filter(db_fileId == fileId).delete())
            //delete from SafeFile where db_fileId = fileId
        }catch{
            CDPrintManager.log("deleteOneSafeFile-->error:\(error)", type: .ErrorLog)
        }
    }
    
    public func deleteAllSubSafeFile(folderId:Int) {
        do{
            try db.run(SafeFileInfo.filter(db_folderId == folderId).delete())
            CDPrint(item:"deleteAllSubSafeFile-->success")
        }catch{
            CDPrintManager.log("deleteAllSubSafeFile-->error:\(error)", type: .ErrorLog)
        }
    }
  
}

//MARK:文件夹
extension CDSqlManager{
    
    private func getSafeFolderFromItem(item:Row) -> CDSafeFolder{
        let folderInfo = CDSafeFolder()
        folderInfo.folderName = item[db_folderName]
        folderInfo.folderId = item[db_folderId]
        folderInfo.folderType = NSFolderType(rawValue: item[db_folderType])
        folderInfo.isLock = item[db_isLock]
        folderInfo.fakeType = CDFakeType(rawValue: item[db_fakeType])!
        folderInfo.createTime = item[db_createTime]
        folderInfo.modifyTime = item[db_modifyTime]
        folderInfo.accessTime = item[db_accessTime]
        folderInfo.userId = item[db_userId]
        folderInfo.superId = item[db_superId]
        folderInfo.folderPath = item[db_folderPath]
        folderInfo.isSelected = .CDFalse
        return folderInfo
    }

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
                db_modifyTime <- folder.modifyTime,
                db_accessTime <- folder.accessTime,
                db_userId <- folder.userId,
                db_folderPath <- folder.folderPath,
                db_superId <- folder.superId,
                db_folderPath <- folder.folderPath)
            )

            CDPrint(item:"addSafeFoldeInfo-->success")
            
        }catch{
            CDPrintManager.log("addSafeFoldeInfo-->error:\(error)", type: .ErrorLog)
        }
        return folderId
    }

    public func queryDefaultAllFolder() -> [Array<CDSafeFolder>]{
        var unlockArr:[CDSafeFolder] = []
        var lockArr:[CDSafeFolder] = []
        var totalArr:[Array<CDSafeFolder>] = []
        do {

            //超级模式，全部可见
            var sql = SafeFolder.where(db_superId == ROOTSUPERID)

            //访客模式下。进查看访客可见的部分
            if CDSignalTon.shared.loginType == .fake{
                sql = SafeFolder.where(db_fakeType == CDFakeType.visible.rawValue && db_superId == ROOTSUPERID)
            }
            for item in (try db.prepare(sql)) {
                let folderInfo = getSafeFolderFromItem(item: item)
                if folderInfo.isLock == LockOn {
                    unlockArr.append(folderInfo)
                }else{
                    lockArr.append(folderInfo)
                }
            }
            totalArr.insert(lockArr, at: 0)
            totalArr.insert(unlockArr, at: 1)
        } catch  {
            CDPrintManager.log("queryDefaultAllFolder-->error:\(error)", type: .ErrorLog)
        }
        return totalArr

    }
    public func querySubAllFolder(folderId:Int) -> [CDSafeFolder]{
        var totalArr:[CDSafeFolder] = []
        do {
            for item in (try db.prepare(SafeFolder.where(db_superId == folderId))) {
                let folderInfo = getSafeFolderFromItem(item: item)
                totalArr.append(folderInfo)
            }
        } catch  {
            CDPrintManager.log("querySubAllFolder-->error:\(error)", type: .ErrorLog)
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
            CDPrintManager.log("querySubAllFolder-->error:\(error)", type: .ErrorLog)
        }
        return totalArr

    }
    public func queryOneSafeFolderWith(folderId:Int) -> CDSafeFolder{
        var folderInfo:CDSafeFolder!

        for item in try! db.prepare(SafeFolder.filter(db_folderId == folderId)) {
            folderInfo = getSafeFolderFromItem(item: item)
        }
        return folderInfo
    }

    public func queryOneFolderSize(folderId:Int) -> Int{

        var totalSize = 0
        do{
            let sql = SafeFileInfo.filter(db_folderId == folderId)
            totalSize = try db.scalar(sql.select(db_fileSize.sum)) ?? 0
        }catch{
            CDPrintManager.log("queryOneFolderSizeByFolder-->error:\(error)", type: .ErrorLog)
        }
        return totalSize
    }
    
    public func queryOneFolderFileCount(folderId:Int) -> Int{

        var totalCount = 0
        do{
            let sql = SafeFileInfo.filter(db_folderId == folderId)
            totalCount = try db.scalar(sql.count)
        }catch{
            CDPrintManager.log("queryOneFolderFileCount-->error:\(error)", type: .ErrorLog)
        }
        return totalCount
    }
    
    public func queryOneFolderSubFolderCount(folderId:Int) ->Int{
        var totalCount = 0
        do{
            let sql = SafeFolder.filter(db_superId == folderId)
            totalCount = try db.scalar(sql.count)
        }catch{
            CDPrintManager.log("queryOneFolderSubFolderCount-->error:\(error)", type: .ErrorLog)
        }
        return totalCount
    }
    
    public func queryMaxSafeFolderId()->Int{

        var maxFolderId = 0
        do{
            let sql = SafeFolder.filter(db_userId == CDUserId())
            maxFolderId = try db.scalar(sql.select(db_folderId.max)) ?? 0
        }catch{
            CDPrintManager.log("querySafeFolderCount-->error:\(error)", type: .ErrorLog)
        }
        return maxFolderId
    }
    
    func queryAllOtherFolderWith(folderType:NSFolderType, folderId:Int) -> [Array<CDSafeFolder>] {
        var unlockArr:[CDSafeFolder] = []
        var lockArr:[CDSafeFolder] = []
        var totalArr:[Array<CDSafeFolder>] = []
        do {

            var sql = SafeFolder.where((db_folderId != folderId) && (db_folderType == folderType.rawValue))

            if CDSignalTon.shared.loginType != .real{
                sql = SafeFolder.where(
                    (db_folderId != folderId) &&
                    (db_folderType == folderType.rawValue) &&
                    (db_fakeType == 2))
            }
            for item in (try db.prepare(sql)) {
                let folderInfo = getSafeFolderFromItem(item: item)
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
    
    
    /*
     更新文件夹名称（更新修改时间）
     */
    public func updateOneSafeFolderName(folderName:String,folderId:Int) {
        do{
            let sql = SafeFolder.filter(db_folderId == folderId)
            
            try db.run(sql.update(db_folderName <- folderName,db_modifyTime <- GetTimestamp()))
            CDPrint(item:"updateOneSafeFolderName-->success")
            
            
        }catch{
            CDPrintManager.log("updateOneSafeFolderName-->error:\(error)", type: .ErrorLog)
        }
    }
    
    public func updateOneSafeFolderFakeType(fakeType:CDFakeType,folderId:Int) {

        do{
            let sql = SafeFolder.filter(db_folderId == folderId)
            try db.run(sql.update(db_fakeType <- fakeType.rawValue,db_modifyTime <- GetTimestamp()))
            CDPrint(item:"updateOneSafeFileIndentity-->success")
        }catch{
            CDPrintManager.log("updateOneSafeFileIndentity-->error:\(error)", type: .ErrorLog)
        }
    }
    /*
    更新文件夹修改时间
    */
    public func updateOneSafeFolderModifyTime(modifyTime:Int,folderId:Int) {

        do{
            let sql = SafeFolder.filter(db_folderId == folderId)
            try db.run(sql.update(db_modifyTime <- modifyTime))
            CDPrint(item:"updateOneSafeFolderModifyTime-->success")
        }catch{
            CDPrintManager.log("updateOneSafeFolderModifyTime-->error:\(error)", type: .ErrorLog)
        }
    }
    
    /*
    更新文件夹访问时间
    */
    public func updateOneSafeFolderAccessTime(accessTime:Int,folderId:Int) {

        do{
            let sql = SafeFolder.filter(db_folderId == folderId)
            try db.run(sql.update(db_accessTime <- accessTime))
            CDPrint(item:"updateOneSafeFolderAccessTime-->success")
        }catch{
            CDPrintManager.log("updateOneSafeFolderAccessTime-->error:\(error)", type: .ErrorLog)
        }
    }
    
    public func deleteOneFolder(folderId:Int) {
        do{
            try db.run(SafeFolder.filter(db_folderId == folderId).delete())
            CDPrint(item:"deleteOneFolder-->success")
        }catch{
            CDPrintManager.log("deleteOneFolder-->error:\(error)", type: .ErrorLog)
        }
    }
    
    public func deleteAllSubSafeFolder(superId:Int) {
        do{
            try db.run(SafeFolder.filter(db_superId >= superId).delete())
            CDPrint(item:"deleteAllSubSafeFolder-->success")
        }catch{
            CDPrintManager.log("deleteAllSubSafeFolder-->error:\(error)", type: .ErrorLog)
        }
    }
}

//MARK:musicInfo
extension CDSqlManager {
    
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
//MARK:musicClassInfo
extension CDSqlManager {
    
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
            CDPrintManager.log("addCDMusicClassInfo-->error:\(error)", type: .ErrorLog)
        }
    }
    func deleteOneMusicClassInfoWith(classId:Int) -> Void {
        do{
            try db.run(MusicClassInfo.filter((db_classId == classId) && (db_userId == CDUserId())).delete())
            CDPrint(item:"deleteOneMusicClassInfo-->success")
        }catch{
            CDPrintManager.log("deleteOneMusicClassInfo-->error:\(error)", type: .ErrorLog)
        }
    }
    func deleteAllMusicClassInfoWith(userId:Int) -> Void {
        do{
            try db.run(MusicClassInfo.filter(db_userId == CDUserId()).delete())
            CDPrint(item:"deleteAllMusicClassInfo-->success")
        }catch{
            CDPrintManager.log("deleteAllMusicClassInfo-->error:\(error)", type: .ErrorLog)
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
            CDPrintManager.log("updateOneMusicClassInfo -->error:\(error)", type: .ErrorLog)
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
            CDPrintManager.log("queryMusicClassCount -->error:\(error)", type: .ErrorLog)
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
