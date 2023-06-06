//
//  CDSqlModel+CDSafeFolder.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import SQLite
//MARK:文件夹
extension CDSqlManager{
    internal func createSafeFoldeTab(){
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
                build.column(db_userId)
                build.column(db_folderPath)
                build.column(db_superId)
            }
            
            try db.run(create)
            CDPrint(item:"createSafeFolder -->success")
            
        }catch{
            CDPrintManager.log("createSafeFolder -->error:\(error)", type: .ErrorLog)
        }
    }
    
    private func getSafeFolderFromItem(item:Row) -> CDSafeFolder{
        let folderInfo = CDSafeFolder()
        folderInfo.folderName = item[db_folderName]
        folderInfo.folderId = item[db_folderId]
        folderInfo.folderType = NSFolderType(rawValue: item[db_folderType])
        folderInfo.isLock = item[db_isLock]
        folderInfo.fakeType = CDFakeType(rawValue: item[db_fakeType])!
        folderInfo.createTime = item[db_createTime]
        folderInfo.modifyTime = item[db_modifyTime]
        folderInfo.userId = item[db_userId]
        folderInfo.superId = item[db_superId]
        folderInfo.folderPath = item[db_folderPath]
        folderInfo.isSelected = .no
        return folderInfo
    }

    @discardableResult
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
    ///folderId: 除该文件夹以外的所有同类型文件夹
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
    
    func queryAllOtherFolderWith(folderType:NSFolderType) -> [Array<CDSafeFolder>] {
        var unlockArr:[CDSafeFolder] = []
        var lockArr:[CDSafeFolder] = []
        var totalArr:[Array<CDSafeFolder>] = []
        do {

            var sql = SafeFolder.where(db_folderType == folderType.rawValue)

            if CDSignalTon.shared.loginType != .real{
                sql = SafeFolder.where( (db_folderType == folderType.rawValue) && (db_fakeType == 2))
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
            
            try db.run(sql.update(db_folderName <- folderName,db_modifyTime <- GetTimestamp(nil)))
            CDPrint(item:"updateOneSafeFolderName-->success")
            
            
        }catch{
            CDPrintManager.log("updateOneSafeFolderName-->error:\(error)", type: .ErrorLog)
        }
    }
    
    public func updateOneSafeFolderFakeType(fakeType:CDFakeType,folderId:Int) {

        do{
            let sql = SafeFolder.filter(db_folderId == folderId)
            try db.run(sql.update(db_fakeType <- fakeType.rawValue,db_modifyTime <- GetTimestamp(nil)))
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
    
    //MARK:extension
    //获取文件夹下所有子文件和子文件夹
    public func queryAllContentFromFolder(folderId:Int) -> (foldersArr:[CDSafeFolder],filesArr:[CDSafeFileInfo]) {
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
