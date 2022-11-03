//
//  CDGeneralTool.swift
//  
//
//  Created by changdong on 2020/4/22.
//

import UIKit
import SSZipArchive
import UnrarKit
class CDGeneralTool: NSObject {
    class func attributedTextWith(textArr:Array<String>,fontArr:Array<UIFont>,colorArr:Array<UIColor>) ->NSAttributedString?{
       
        if textArr.count == 0 {
            return nil
        }
        let resultAttrite = NSMutableAttributedString()
        for i in 0..<textArr.count {
            let text = textArr[i]
            let mattrite = NSMutableAttributedString(string: text)
            mattrite.addAttribute(NSAttributedString.Key.foregroundColor, value: colorArr[i], range: NSRange(location: 0, length: text.count))
            mattrite.addAttribute(NSAttributedString.Key.font, value: fontArr[i], range: NSRange(location: 0, length: text.count))
            resultAttrite.append(mattrite)
        }
        return resultAttrite
    }

    class func archiveFileToZip(originFiles:[String],password:String,desZipPath:String) -> Bool{
        
        return SSZipArchive.createZipFile(atPath: desZipPath, withFilesAtPaths: originFiles, withPassword: password)
    }
    
    class func unArchiveZipToDirectory(zip:String,desDirectory:String,paaword:String?) -> NSError?{
        if zip.hasSuffix(".rar") {
            do {
                let archive = try URKArchive(path: zip, password: (paaword ?? nil)!)
//                let fileArr = try archive.listFileInfo()
//                archive.extractData(fromFile: fileArr[0])
                try archive.extractFiles(to: desDirectory, overwrite: false)
            } catch  {
                return error as NSError
            }
        } else if zip.hasSuffix(".zip") {
            do {
                try SSZipArchive.unzipFile(atPath: zip, toDestination: desDirectory, overwrite: false, password: paaword)
                return nil
            } catch let error as NSError {
                return error
            }
        } else if zip.hasSuffix(".7z") {
            
        }
        return nil

    }
    
    
    class func checkPasswordIsProtectedZip(zipFile:String) -> Bool {
        if zipFile.hasSuffix(".rar") {
            do {
                let archiv = try URKArchive(path: zipFile)
                return archiv.isPasswordProtected()
            } catch {
                return true
            }
            
        } else if zipFile.hasSuffix(".zip") {
            return SSZipArchive.isFilePasswordProtected(atPath: zipFile)
        } else if zipFile.hasSuffix(".7z") {
            
        }
        return false
    }
    //获取文件夹下所有目录
    class func getAllContentsOfDirectory(dirPath:String) ->(filesArr:[String],directoiesArr:[String]){
        var filePaths = [String]()
         var subDirPaths = [String]()

        do {
            let array = try FileManager.default.contentsOfDirectory(atPath: dirPath)
            for fileName in array {
                var isDir:ObjCBool = true
                let fullPath = "\(dirPath)/\(fileName)"
                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                    if !isDir.boolValue {//文件
                        filePaths.append(fullPath)
                    }else{//文件夹
                        subDirPaths.append(fullPath)
                    }
                }
            }
            return (filePaths,subDirPaths)
        } catch let error as NSError {
            print(error.localizedDescription)
            return([],[])
        }
    }
    
    
    
    
    
}
