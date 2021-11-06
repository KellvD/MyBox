//
//  CDExtension.swift
//  Share
//
//  Created by cwx889303 on 2021/10/11.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import Foundation
import UIKit

extension String{
    var suffix:String {
        get{
            let string = (self as NSString).pathExtension
            return string
        }
        
    }
    
    /**
    获取不带后缀的文件名
    */
    var fileName:String{
        get{
            let fileLastPath = (self as NSString).lastPathComponent.removingPercentEncoding
            return fileLastPath!
        }
    }
    /*
    获取32位随机数
    */
    static var random:String {
        get{
            let NUMBER_OF_CHARS: Int = 32
            let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            var ranStr = ""
            for _ in 0..<NUMBER_OF_CHARS {
                let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
                ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
            }
            return ranStr
        }
    }
}

import AVFoundation
extension UIImage{
    class func previewImage(videoUrl:URL) -> UIImage {
        let avAsset = AVAsset(url: videoUrl)
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        var actualTime:CMTime = CMTimeMake(value: 0, timescale: 0)
        do {
            let imageRef:CGImage = try generator.copyCGImage(at: time, actualTime: &actualTime)
            let image = UIImage(cgImage: imageRef)

            return image
        } catch  {
            print(error)
            return UIImage()
        }
        
    }
}


/*
获取视频的长度
*/
@inline(__always)func GetVideoLength(path:String)->Double{
    let urlAsset = AVURLAsset(url: URL(fileURLWithPath: path), options: nil)
    let second = Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale)
    return second
}

/*
格式化文件size
*/
@inline(__always)func GetSizeFormat(fileSize:Int)->String{
    var sizef = Float(fileSize)
    var i = 0
    while sizef >= 1024 {
        sizef = sizef / 1024.0
        i += 1
    }
    let fortmates = ["%.2ldB","%.2lfKB","%.2lfM","%.2lfG","%.2lfT"]
    return String(format: fortmates[i], sizef)
}

/*
格式化时间戳
*/
@inline(__always)func GetMMSSFromSS(timeLength:Double)->String{
    let hour = Int(timeLength / 3600)
    let minute = Int(timeLength) / 60
    let second = Int(timeLength) % 60
    var format:String = ""
    if hour > 0 {
        format = String.init(format: "%02ld:%02ld:%02ld", hour,minute,second)
    }else{
        format = String.init(format: "%02ld:%02ld", minute,second)
    }
    return format
}

