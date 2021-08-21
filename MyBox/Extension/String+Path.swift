//
//  String+Path.swift
//  MyRule
//
//  Created by changdong on 2018/12/10.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation

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
    
    func AsString() -> String{
        return (self as String)
    }
    /**
    移除后缀名
    */
    func removeSuffix()->String {
        let string = self.AsNSString().deletingPathExtension
        return string
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
     获取文件后缀
    */
    var suffix:String {
        get{
            let string = self.AsNSString().pathExtension
            return string
        }
        
    }
    
    var removePercentEncoding:String {
        get{
            let string = self.AsNSString().removingPercentEncoding
            return string!
        }
    }
    
    /**
    根据文件后缀判断文件类型
    */
    var fileType:NSFileType{
        let tmp = self.uppercased()
        if tmp == "PDF" || tmp == "PDFX" {
            return .PdfType
        } else if tmp == "PPT" || tmp == "PPTX" || tmp == "KEY" {
            return .PptType
        } else if tmp == "DOC" || tmp == "DOCX" || tmp == "DOCUMENT" || tmp == "PAGES" {
            return .DocType
        }else if tmp == "TXT" {
            return .TxtType
        } else if tmp == "XLS" || tmp == "XLSX" || tmp == "NUMBERS" {
            return .ExclType
        } else if tmp == "RTF" {
            return .RtfType
        } else if tmp == "GIF" {
            return .GifType
        }else if tmp == "PNG" ||
            tmp == "JPG" || tmp == "TIF" || tmp == "JPEG" ||
            tmp == "BMP" || tmp == "PCD" || tmp == "MAC" ||
            tmp == "PCX" || tmp == "DXF" || tmp == "CDR" {
            return .ImageType
        }else if tmp == "MP3" ||
            tmp == "WAV" || tmp == "CAF" || tmp == "CDA" || tmp == "MID" ||
            tmp == "RAM" || tmp == "RMX" || tmp == "VQF" || tmp == "AIFF" ||
            tmp == "SND" || tmp == "SVX" || tmp == "VOC" || tmp == "AMR" ||
            tmp == "M4A" || tmp == "M4R" || tmp == "M4V" || tmp == "AAC"{
        return .AudioType
        }else if tmp == "MOV" || tmp == "MP4" || tmp == "AVI" ||
            tmp == "MPG" || tmp == "M2V" || tmp == "VOB" ||
            tmp == "ASF" || tmp == "WMF" || tmp == "RMVB" ||
            tmp == "RM" || tmp == "DIVX" || tmp == "MKV" {
            return .VideoType
        }else if tmp == "ZIP" || tmp == "RAR" || tmp == "7-ZIP" ||
            tmp == "ACE" || tmp == "ARJ" || tmp == "BV2" || tmp == "CAD" ||
            tmp == "GZIP" || tmp == "ISO" || tmp == "JAR" || tmp == "LZH" ||
            tmp == "TAR" || tmp == "UUE" || tmp == "XZ" {
            return .ZipType
        } else {
            return .OtherType
        }


    }
}

