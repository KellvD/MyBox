//
//  Data+format.swift
//  MyRule
//
//  Created by changdong on 2019/6/19.
//  Copyright © 2019 changdong. All rights reserved.
//

import Foundation

//enum SDImageFormat:NSInteger {
//    case SDImageFormatUndefined = -1
//    case SDImageFormatJPEG = 0
//    case SDImageFormatPNG = 1
//    case SDImageFormatGIF
//    case SDImageFormatTIFF
//    case SDImageFormatWebP
//    case SDImageFormatHEIC
//}
extension Data{
//
//    func imageFormatForImageData(data:NSData) ->SDImageFormat{
//        var c: UInt8?
//        data.getBytes(&c, length: 1)
//        switch c {
//        case 0xff:
//            return SDImageFormat.SDImageFormatJPEG
//        case 0x89:
//            return SDImageFormat.SDImageFormatPNG;
//        case 0x47:
//            return SDImageFormat.SDImageFormatGIF;
//        case 0x49,0x4D:
//            return SDImageFormat.SDImageFormatTIFF;
//        case 0x52:
//            if data.length > 12{
//                let string = String(data: data.subdata(with: NSRange(location: 0, length: 12)), encoding: String.Encoding.ascii)!
//                if (string.hasPrefix("PIFF") &&
//                    string.hasSuffix("WEBP")){
//                    return SDImageFormat.SDImageFormatWebP;
//                }
//            }
//        case 0x00:
//            if data.length > 12{
//                let string = String(data: data.subdata(with: NSRange(location: 4, length: 8)), encoding: String.Encoding.ascii)!
//                if (string == "ftypheic" ||
//                    string == "WEBP" ||
//                    string == "ftyphevc" ||
//                    string == "ftyphevx"){
//                    return SDImageFormat.SDImageFormatHEIC;
//                }
//            }
//        default:
//            return SDImageFormat.SDImageFormatUndefined;
//        }
//        return SDImageFormat.SDImageFormatUndefined;
//    }
}
