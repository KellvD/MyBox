//
//  CDSqlModel+CDSafeFileInfo.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import SQLite
extension CDSqlManager {
    internal func  createSafeFileInfoTab() {
        do {
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
                build.column(db_importTime)
                build.column(db_createTime)
                build.column(db_modifyTime)
                build.column(db_fileType)
                build.column(db_filePath)
                build.column(db_grade)
                build.column(db_userId)
                build.column(db_markInfo)
                build.column(db_folderType)
                build.column(db_createLocation)
            }
            try db.run(create1)
            CDPrint(item: "createSafeFileInfo -->success")
        } catch {
            CDPrintManager.log("createSafeFileInfo-->error:\(error)", type: .ErrorLog)
        }
    }

    // MARK: SafeFile
    private func getSafeFileInfoFromItem(item: Row) -> CDSafeFileInfo {
        let file = CDSafeFileInfo()
        file.fileId = item[db_fileId]
        file.folderId = item[db_folderId]
        file.fileSize = item[db_fileSize]
        file.fileWidth = item[db_fileWidth]
        file.fileHeight = item[db_fileHeight]
        file.timeLength = item[db_timeLength]
        file.createTime = item[db_createTime]
        file.modifyTime = item[db_modifyTime]
        file.importTime = item[db_importTime]
        file.filePath = item[db_filePath]
        file.fileType = CDSafeFileInfo.NSFileType(rawValue: item[db_fileType])
        file.grade = CDSafeFileInfo.NSFileGrade(rawValue: item[db_grade])
        file.fileName = item[db_fileName]
        file.fileText = item[db_fileText]
        file.thumbImagePath = item[db_thumbImagePath]
        file.userId = item[db_userId]
        file.markInfo = item[db_markInfo]
        file.isSelected = .no
        file.createLocation = item[db_createLocation]
        file.folderType = NSFolderType(rawValue: item[db_folderType])

        return file
    }

    public func addSafeFileInfo(fileInfo: CDSafeFileInfo) {

        let fileId = queryMaxFileId() + 1
        do {
            try db.run(SafeFileInfo.insert(
                        db_fileId <- fileId,
                        db_fileText <- fileInfo.fileText,
                        db_thumbImagePath <- fileInfo.thumbImagePath,
                        db_fileName <- fileInfo.fileName,
                        db_folderId <- fileInfo.folderId,
                        db_fileSize <- fileInfo.fileSize,
                        db_fileWidth <- fileInfo.fileWidth,
                        db_fileHeight <- fileInfo.fileHeight,
                        db_importTime <- fileInfo.importTime,
                        db_timeLength <- fileInfo.timeLength,
                        db_createTime <- fileInfo.createTime,
                        db_modifyTime <- fileInfo.modifyTime,
                        db_importTime <- fileInfo.importTime,
                        db_fileType <- fileInfo.fileType!.rawValue,
                        db_grade <- 1,
                        db_filePath <- fileInfo.filePath,
                        db_userId <- fileInfo.userId,
                        db_markInfo <- fileInfo.markInfo,
                        db_createLocation<-fileInfo.createLocation,
                        db_folderType <- fileInfo.folderType!.rawValue)

            )

            CDPrint(item: "addSafeFileInfo-->success")
        } catch {
            CDPrintManager.log("addSafeFileInfo-->error:\(error)", type: .ErrorLog)
        }
    }
    public func queryMaxFileId() -> Int {

        var maxFileId = 0
        do {
            let sql = SafeFileInfo.filter(db_userId == CDUserId())
            maxFileId = try db.scalar(sql.select(db_fileId.max)) ?? 0
            CDPrint(item: "queryMaxFileId -->success")
        } catch {
            CDPrintManager.log("queryMaxFileId -->error:\(error)", type: .ErrorLog)
        }
        return maxFileId
    }

    public func queryAllFileFromFolder(folderId: Int)-> [CDSafeFileInfo] {
        var fileArr: [CDSafeFileInfo] = []
        do {
            let sql = SafeFileInfo.filter(db_folderId == folderId ).order(db_importTime.desc)
            for item in try db.prepare(sql) {
                let file = getSafeFileInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch {
            CDPrintManager.log("queryAllFileFromFolder -->error:\(error)", type: .ErrorLog)
        }
        return fileArr
    }

    public func queryAllFile(fileType: CDSafeFileInfo.NSFileType)-> [CDSafeFileInfo] {
        var fileArr: [CDSafeFileInfo] = []
        do {
            let sql = SafeFileInfo.filter(db_fileType == fileType.rawValue).order(db_importTime.desc)
            for item in try db.prepare(sql) {
                let file = getSafeFileInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch {
            CDPrintManager.log("queryAllFileFromFolder -->error:\(error)", type: .ErrorLog)
        }
        return fileArr
    }

    public func queryOneSafeFileWithFileId(fileId: Int) -> CDSafeFileInfo {
        var file: CDSafeFileInfo!
        do {
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            for item in try db.prepare(sql) {
                file = getSafeFileInfoFromItem(item: item)

            }
        } catch {
            CDPrintManager.log("queryOneSafeFileWithFileId -->error:\(error)", type: .ErrorLog)
        }
        return file
    }

    func queryOneSafeFileGrade(fileId: Int) ->CDSafeFileInfo.NSFileGrade {
        var grade = CDSafeFileInfo.NSFileGrade(rawValue: 1)
        do {
            let sql = SafeFileInfo.filter(db_fileId == fileId)

            for item in try db.prepare(sql.select(db_grade)) {
                grade = CDSafeFileInfo.NSFileGrade(rawValue: item[db_grade])

            }
        } catch {
            CDPrintManager.log("queryOneSafeFileGrade -->error:\(error)", type: .ErrorLog)
        }
        return grade!
    }

    func queryEveryFileCount()->(imageCount: Int, videoCount: Int, audioCount: Int, otherCount: Int) {
        do {

            let imageCount = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.ImageFolder.rawValue).count)
            let videoCount = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.VideoFolder.rawValue).count)
            let audioCount = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.AudioFolder.rawValue).count)
            let otherCount = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.TextFolder.rawValue).count)

            //            for item in try db.prepare("select count(*) from CDSafeFileInfo where folderType = 0") {
            //                CDPrint(item: item)
            //            }
            return(imageCount, videoCount, audioCount, otherCount)

        } catch {
            CDPrintManager.log("queryEveryFileCount -->error:\(error)", type: .ErrorLog)
        }
        return(0, 0, 0, 0)
    }

    func queryEveryFileTotalSize()->(imageSize: Int, videoSize: Int, audioSize: Int, otherSize: Int) {
        do {

            let imageSize = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.ImageFolder.rawValue).select(db_fileSize.sum)) ?? 0
            let videoSize = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.VideoFolder.rawValue).select(db_fileSize.sum)) ?? 0
            let audioSize = try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.AudioFolder.rawValue).select(db_fileSize.sum)) ?? 0
            let otherSize =  try db.scalar(SafeFileInfo.filter(db_folderType == NSFolderType.TextFolder.rawValue).select(db_fileSize.sum)) ?? 0
            return(imageSize, videoSize, audioSize, otherSize)
        } catch {
            CDPrintManager.log("queryEveryFileTotalSize -->error:\(error)", type: .ErrorLog)
        }
        return(0, 0, 0, 0)
    }

    public func queryAllTextSafeFile() -> [CDSafeFileInfo] {
        var fileArr: [CDSafeFileInfo] = []
        do {
            let sql = SafeFileInfo.filter(db_fileType == CDSafeFileInfo.NSFileType.TxtType.rawValue)
            for item in try db.prepare(sql) {
                let file = getSafeFileInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch {
            CDPrintManager.log("queryAllTextSafeFile -->error:\(error)", type: .ErrorLog)
        }
        return fileArr
    }

    public func updateOneSafeFileName(fileName: String, fileId: Int) {

        do {
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            try db.run(sql.update(db_fileName <- fileName, db_modifyTime <- GetTimestamp(nil)))
        } catch {
            CDPrintManager.log("updateOneSafeFileName-->error:\(error)", type: .ErrorLog)
        }
    }

    public func updateOneSafeFileMarkInfo(markInfo: String, fileId: Int) {

        do {
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            try db.run(sql.update(db_markInfo <- markInfo, db_modifyTime <- GetTimestamp(nil)))
        } catch {
            CDPrintManager.log("updateOneSafeFileMarkInfo-->error:\(error)", type: .ErrorLog)
        }
    }

    func updateOneSafeFileGrade(grade: CDSafeFileInfo.NSFileGrade, fileId: Int) {
        do {
            let sql = SafeFileInfo.filter((db_fileId == fileId)&&(db_userId == CDUserId()))
            try db.run(sql.update(db_grade <- grade.rawValue, db_modifyTime <- GetTimestamp(nil)))
        } catch {
            CDPrintManager.log("updateOneSafeFileGrade-->error:\(error)", type: .ErrorLog)
        }
    }

    /*
     文件移动文件夹，更新文件新的folderID
     */
    func updateOneSafeFileFolder(fileInfo: CDSafeFileInfo) {
        do {
            let sql = SafeFileInfo.filter(db_fileId == fileInfo.fileId)

            try db.run(sql.update(db_folderId <- fileInfo.folderId, db_modifyTime <- GetTimestamp(nil)))
        } catch {
            CDPrintManager.log("updateOneSafeFileForMove-->error:\(error)", type: .ErrorLog)
        }
    }

    func updateOneSafeFileInfo(fileInfo: CDSafeFileInfo) {
        do {
            let sql = SafeFileInfo.filter(db_fileId == fileInfo.fileId)

            try db.run(sql.update(db_fileText <- fileInfo.fileText,
                                  db_thumbImagePath <- fileInfo.thumbImagePath,
                                  db_fileName <- fileInfo.fileName,
                                  db_folderId <- fileInfo.folderId,
                                  db_fileSize <- fileInfo.fileSize,
                                  db_fileWidth <- fileInfo.fileWidth,
                                  db_fileHeight <- fileInfo.fileHeight,
                                  db_importTime <- fileInfo.importTime,
                                  db_timeLength <- fileInfo.timeLength,
                                  db_createTime <- fileInfo.createTime,
                                  db_modifyTime <- fileInfo.modifyTime,
                                  db_importTime <- fileInfo.importTime,
                                  db_fileType <- fileInfo.fileType!.rawValue,
                                  db_grade <- 1,
                                  db_filePath <- fileInfo.filePath,
                                  db_userId <- fileInfo.userId,
                                  db_markInfo <- fileInfo.markInfo,
                                  db_createLocation<-fileInfo.createLocation,
                                  db_folderType <- fileInfo.folderType!.rawValue))
        } catch {
            CDPrintManager.log("updateOneSafeFileForMove-->error:\(error)", type: .ErrorLog)
        }
    }

    public func updateOneSafeFileModifyTime(modifyTime: Int, fileId: Int) {

        do {
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            try db.run(sql.update(db_modifyTime <- modifyTime))
        } catch {
            CDPrintManager.log("updateOneSafeFileModifyTime-->error:\(error)", type: .ErrorLog)
        }
    }

    public func deleteOneSafeFile(fileId: Int) {
        do {
            try db.run(SafeFileInfo.filter(db_fileId == fileId).delete())
            // delete from SafeFile where db_fileId = fileId
        } catch {
            CDPrintManager.log("deleteOneSafeFile-->error:\(error)", type: .ErrorLog)
        }
    }

    public func deleteAllSubSafeFile(folderId: Int) {
        do {
            try db.run(SafeFileInfo.filter(db_folderId == folderId).delete())
            CDPrint(item: "deleteAllSubSafeFile-->success")
        } catch {
            CDPrintManager.log("deleteAllSubSafeFile-->error:\(error)", type: .ErrorLog)
        }
    }

}
