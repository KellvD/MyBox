//
//  UIImage+extension.swift
//  MyBox
//
//  Created by changdong  on 2020/7/6.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit

extension UIImage{
    /*
    压缩图片
    */
    func compress(maxWidth:CGFloat) -> UIImage{
        // 宽高比
        let ratio: CGFloat = self.size.width / self.size.height
        // 目标大小
        var targetW: CGFloat = maxWidth
        var targetH: CGFloat = maxWidth

        // 宽高均 <= 1280，图片尺寸大小保持不变
        if self.size.width < maxWidth && self.size.height < maxWidth {
            return self
        }
            // 宽高均 > 1280 && 宽高比 > 2，
        else if self.size.width > maxWidth && self.size.height > maxWidth {

            // 宽大于高 取较小值(高)等于1280，较大值等比例压缩
            if ratio > 1 {
                targetH = maxWidth
                targetW = targetH * ratio
            }
    // 高大于宽 取较小值(宽)等于1280，较大值等比例压缩 (宽高比在0.5到2之间 )
            else {
                targetW = maxWidth
                targetH = targetW / ratio
            }
        }else{// 宽或高 > 1280
            if ratio > 2 { // 宽图 图片尺寸大小保持不变
                targetW = self.size.width
                targetH = self.size.height
            } else if ratio < 0.5 {  // 长图 图片尺寸大小保持不变
                targetW = self.size.width
                targetH = self.size.height
            } else if ratio > 1 { // 宽大于高 取较大值(宽)等于1280，较小值等比例压缩
                targetW = maxWidth
                targetH = targetW / ratio
            } else { // 高大于宽 取较大值(高)等于1280，较小值等比例压缩
                targetH = maxWidth
                targetW = targetH * ratio
            }
        }
        UIGraphicsBeginImageContext(CGSize(width: targetW, height: targetH))
        self.draw(in: CGRect(x: 0, y: 0, width: targetW, height: targetH))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!

    }
    
    /*
    裁剪照片
    */
    func scaleAndCropToMaxSize(newSize:CGSize) ->UIImage {
        let largestSize = newSize.width > newSize.height ? newSize.width : newSize.height
        var imageSize:CGSize = self.size
        var ratio:CGFloat = 0
        if imageSize.width > imageSize.height{
            ratio = largestSize/imageSize.height
        }else{
            ratio = largestSize/imageSize.width
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: ratio * imageSize.width, height: ratio * imageSize.height)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)

        let scaleImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var offSetX:CGFloat = 0
        var offSetY:CGFloat = 0

        imageSize = scaleImage.size
        if imageSize.width < imageSize.height {
            offSetY = (imageSize.height / 2) - (imageSize.width / 2)
        }else{
            offSetX = (imageSize.width / 2) - (imageSize.height / 2)
        }

        let corpRect = CGRect(x: offSetX, y: offSetY, width: imageSize.width - offSetX * 2, height: imageSize.height - offSetY * 2)

        let sourceImageRef:CGImage = scaleImage.cgImage!
        let croppedImageRef:CGImage = sourceImageRef.cropping(to: corpRect)!
        let newImage = UIImage(cgImage: croppedImageRef)
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /**
     获取图片格式
     */
    class func getImageFormat(imageData:NSData) ->SDImageFormat{
        var c: UInt8?
        imageData.getBytes(&c, length: 1)
        let data = imageData as Data
        var byte = [UInt8]()
        let v = data.copyBytes(to: &byte, count: 4)
        switch c {
        case 0xff:
            return SDImageFormat.SDImageFormatJPEG
        case 0x89:
            return SDImageFormat.SDImageFormatPNG;
        case 0x47:
            return SDImageFormat.SDImageFormatGIF;
        case 0x49,0x4D:
            return SDImageFormat.SDImageFormatTIFF;
        case 0x52:
            if imageData.length > 12{
                let string = String(data: imageData.subdata(with: NSRange(location: 0, length: 12)), encoding: String.Encoding.ascii)!
                if (string.hasPrefix("PIFF") &&
                    string.hasSuffix("WEBP")){
                    return SDImageFormat.SDImageFormatWebP;
                }
            }
        case 0x00:
            if imageData.length > 12{
                let string = String(data: imageData.subdata(with: NSRange(location: 4, length: 8)), encoding: String.Encoding.ascii)!
                if (string == "ftypheic" ||
                    string == "WEBP" ||
                    string == "ftyphevc" ||
                    string == "ftyphevx"){
                    return SDImageFormat.SDImageFormatHEIC;
                }
            }
        default:
            return SDImageFormat.SDImageFormatUndefined;
        }
        return SDImageFormat.SDImageFormatUndefined;
    }
    
    class func clipFromView(view:UIView) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image  = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
