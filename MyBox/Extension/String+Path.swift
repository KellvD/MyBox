//
//  String+Path.swift
//  MyRule
//
//  Created by changdong on 2018/12/10.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import AVFoundation

extension String{
    /**
     获取document路径
     */
    static func documentPath()->String{
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return docPath
    }

    /**
    判断路径是否存在，不存在创建
    */
    static func ensurePathAt(path:String){
        let manager = FileManager.default
        if !manager.fileExists(atPath: path) {
            do{
                try manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("创建路径失败" + error.localizedDescription)
            }
        }
    }

    /**
    创建SafeRule路径
    */
    static func RootPath() -> String{
        let docpath = documentPath()
        let userPath = (docpath as NSString).appendingPathComponent("SafeRule")
        ensurePathAt(path: userPath)
        return userPath
    }

    /**
    删除SafeRulek路径
    */
    static func deleteRootPath(){
        let docpath = documentPath()
        let userPath = (docpath as NSString).appendingPathComponent("SafeRule")
        if FileManager.default.fileExists(atPath: userPath){
            do{
                try FileManager.default.removeItem(atPath: userPath)
            }catch{
            }
        }
    }

    //MARK:图片路径
    static func ImagePath()->String{
        let path = (RootPath() as NSString).appendingPathComponent("Images")
        ensurePathAt(path: path)
        return path
    }
    //图片压缩路径
    static func thumpImagePath()->String{
        let path = (ImagePath() as NSString).appendingPathComponent("ThumbImages")
        ensurePathAt(path: path)
        return path
    }


    //MARK:音频
    static func AudioPath()->String{
        let path = (RootPath() as NSString).appendingPathComponent("Audio")
        ensurePathAt(path: path)
        return path
    }


    //MARK:视频
    static func VideoPath()->String{
        let path = (RootPath() as NSString).appendingPathComponent("Video")
        ensurePathAt(path: path)
        return path
    }
    //视频第一帧缩略图路径
    static func thumpVideoPath()->String{
        let path = (VideoPath() as NSString).appendingPathComponent("ThumpVideo")
        ensurePathAt(path: path)
        return path
    }

    //MARK:Other
    static func OtherPath()->String{
        let path = (RootPath() as NSString).appendingPathComponent("Other")
        ensurePathAt(path: path)
        return path
    }
    //MARK:Music
    static func MusicPath()->String{
        let path = (RootPath() as NSString).appendingPathComponent("Music")
        ensurePathAt(path: path)
        return path
    }
    static func MusicImagePath()->String{
        let path = (RootPath() as NSString).appendingPathComponent("Music/Image")
        ensurePathAt(path: path)
        return path
    }
    
    static func NovelPath()->String{
        let path = (RootPath() as NSString).appendingPathComponent("Novel")
        ensurePathAt(path: path)
        return path
    }
    
    
    func appendingFormat(_ format: NSString, _ args: CVarArg...) -> NSString{
        let appen = self.AsNSString().appendingFormat(format
            , args)
        return appen
    }
    
    func appendingPathComponent(str:String) -> String {
        let appen = self.AsNSString().appendingPathComponent(str)
        return appen
    }
    
    func AsNSString() -> NSString{
        return (self as NSString)
    }
    
    /**
    移除后缀名
    */
    func removeSuffix()->String {
        let string = self.AsNSString().deletingPathExtension
        return string
    }
    
    /**
    删除文件
    */
    func delete(){
        let manager = FileManager.default
        if manager.fileExists(atPath: self) {
            do{
                if self.hasPrefix(String.RootPath()) {
                    try manager.removeItem(atPath: self)
                }else{
                    let path = String.RootPath().appendingPathComponent(str: self)
                    try manager.removeItem(atPath: path)
                }
                
            }catch{
                CDPrintManager.log("文件删除失败" + error.localizedDescription, type: .WarnLog)
            }
        }
    }
    //相对路径
    var relativePath:String{
        get{
            let array:[String] = self.components(separatedBy: String.RootPath())
            let tempString:String = array.last!
            return tempString
        }
    }
    
    /**
     获取完整的文件名
     */
    var lastPathComponent:String{
        get{
            let last = self.AsNSString().lastPathComponent
            return last
        }
    }
    
    /**
    获取不带后缀的文件名
    */
    var fileName:String{
        get{
            let fileLastPath = self.lastPathComponent
            let fileName = fileLastPath.removeSuffix().removePercentEncoding
            return fileName
        }
    }
    
    /**
    拼接文件完整路径
    */
    var rootPath:String{
        get{
            if !self.hasPrefix(String.RootPath()) {
                return String.RootPath().appendingPathComponent(str: self)
            }
            return self
        }
    }
    
    
    /**
    路径转URL
    */
    var url:URL{
        get{
            return URL(fileURLWithPath: self)
        }
    }
    /**
     获取文件后缀
    */
    var suffix:String {
        
        get{
            let string = self.AsNSString().pathExtension
            return string
        }
        
    }
    /**
     文件信息
    */
    var fileAttribute:(fileSize:Int,createTime:Int) {
        get{
            var fileSize:Int = 0
            var createTime:Int = 0
            if FileManager.default.fileExists(atPath: self) {
                do{
                    let attr = try FileManager.default.attributesOfItem(atPath: self)
                    fileSize = attr[FileAttributeKey.size] as! Int
                    let creationDate = attr[FileAttributeKey.creationDate] as!Date
                    createTime = Int(creationDate.timeIntervalSince1970 * 1000)
                    
                }catch{
                    
                }
            }
            return (fileSize,createTime)
        }
        
    }
    
    
    var removePercentEncoding:String {
        get{
            let string = self.AsNSString().removingPercentEncoding
            return string!
        }
    }
    /*
    获取视频的长度
    */
    var duration:Double{
        get{
            if self.fileType == .AudioType || self.fileType == .VideoType {
                let urlAsset = AVURLAsset(url: URL(fileURLWithPath: self), options: nil)
                let second = Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale)
                return second
            }else{
                print("文件非音视频格式")
                return 0
            }
        }
    }
    /**
    根据文件后缀判断文件类型
    */
    var fileType:CDSafeFileInfo.NSFileType{
        let tmp = self.uppercased()
        if ["PDF","PDFX","PPT","PPTX","KEY"].contains(tmp){
            return .PdfType
        }else if ["DOC","DOCX","DOCUMENT","PAGES"].contains(tmp) {
            return .DocType
        }else if tmp == "TXT" {
            return .TxtType
        } else if ["XLS","XLSX","NUMBERS"].contains(tmp) {
            return .ExclType
        } else if tmp == "RTF" {
            return .RtfType
        } else if tmp == "GIF" {
            return .GifType
        }else if ["PNG","JPG","HEIC","JPEG","BMP","TIF","PCD","MAC","PCX","DXF","CDR"].contains(tmp) {
            return .ImageType
        }else if ["MP3","WAV","VOC","M4A","M4R","M4V","AAC","CAF","CDA","MID","RAM","RMX","VQF","AIFF","SND","SVX","AMR"].contains(tmp){
        return .AudioType
        }else if ["MOV","MP4","AVI","MPG","M2V","VOB","ASF","WMF","RMVB","RM","DIVX","MKV"].contains(tmp) {
            return .VideoType
        }else if ["ZIP","RAR","7-ZIP","ACE","ARJ","BV2","CAD","GZIP","ISO","JAR","LZH","TAR","UUE","XZ"].contains(tmp) {
            return .ZipType
        }else if ["HTML"].contains(tmp) {
            return .htmlType
        } else {
            return .OtherType
        }


    }
}

