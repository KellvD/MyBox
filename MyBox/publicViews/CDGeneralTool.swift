//
//  CDGeneralTool.swift
//  
//
//  Created by changdong on 2020/4/22.
//

import UIKit
import ZipArchive
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
        do {
            try SSZipArchive.unzipFile(atPath: zip, toDestination: desDirectory, overwrite: false, password: paaword)
            return nil
        } catch let error as NSError {
            return error
        }

    }
    class func checkPasswordIsProtectedZip(zipFile:String) -> Bool {
        return SSZipArchive.isFilePasswordProtected(atPath: zipFile)
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
    
    class func getStringWidth(string:String,height:CGFloat,font:UIFont) -> CGFloat {
        let size:CGSize = CGSize(width: 0, height: height)
        let frame = string.boundingRect(with: size, options:
            NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.truncatesLastVisibleLine.rawValue |
                NSStringDrawingOptions.usesFontLeading.rawValue), attributes: [NSAttributedString.Key.font:font], context: nil)
        return frame.size.width
    }
    
    class func getStringHeight(string:String,width:CGFloat,font:UIFont) -> CGFloat {
        let size:CGSize = CGSize(width: width, height: 0)
        let frame = string.boundingRect(with: size, options:
            NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.truncatesLastVisibleLine.rawValue |
                NSStringDrawingOptions.usesFontLeading.rawValue), attributes: [NSAttributedString.Key.font:font], context: nil)
        return frame.size.height
    }
}
