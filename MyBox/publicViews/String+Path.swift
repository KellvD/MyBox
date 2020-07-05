//
//  String+Path.swift
//  MyRule
//
//  Created by changdong on 2018/12/10.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation

extension String{

    static func DefualtDocumentPathAppendPath(string:String)->String{
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let path = (docPath as NSString).appendingPathComponent(string)

        return path
    }

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

    static func libraryUserdataPath() -> String{
        let docpath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let userPath = (docpath as NSString).appendingPathComponent("SafeRule")
        ensurePathAt(path: userPath)
        return userPath
    }

    static func deleteLibraryUserdataPath(){
        let docpath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
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
        let path = (libraryUserdataPath() as NSString).appendingPathComponent("Images")
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
        let path = (libraryUserdataPath() as NSString).appendingPathComponent("Audio")
        ensurePathAt(path: path)
        return path
    }


    //MARK:视频
    static func VideoPath()->String{
        let path = (libraryUserdataPath() as NSString).appendingPathComponent("Video")
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
        let path = (libraryUserdataPath() as NSString).appendingPathComponent("Other")
        ensurePathAt(path: path)
        return path
    }
    //MARK:Music
    static func MusicPath()->String{
        let path = (libraryUserdataPath() as NSString).appendingPathComponent("Music")
        ensurePathAt(path: path)
        return path
    }
    static func MusicImagePath()->String{
        let path = (libraryUserdataPath() as NSString).appendingPathComponent("Music/Image")
        ensurePathAt(path: path)
        return path
    }
    static func changeFilePathAbsoluteToRelectivepPath(absolutePath:String) -> String{

        let array:[String] = absolutePath.components(separatedBy: libraryUserdataPath())
        let tempString:String = array.last!
        return tempString
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
    func lastPathComponent() -> String{
        let last = (self as NSString).lastPathComponent
        return last
    }
    func stringByDeletingPathExtension() -> String {
        let string = (self as NSString).deletingPathExtension
        return string
    }
    func removingPercentEncoding() -> String {
        let string = (self as NSString).removingPercentEncoding
        return string!
    }
    func pathExtension() -> String {
        let string = (self as NSString).pathExtension
        return string
    }

    func getFileNameFromPath() -> String{
        let fileLastPath = self.lastPathComponent()
        let fileName = fileLastPath.stringByDeletingPathExtension()
        return fileName
    }
    
}

import CommonCrypto
extension String{
   var md5:String{
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = data(using: .utf8) {
            data.withUnsafeBytes { (bytes:UnsafePointer<UInt8>) -> Void in
                CC_MD5(bytes,CC_LONG(data.count),&digest)
            }
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
}
