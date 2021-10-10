//
//  UIImage+extension.swift
//  MyBox
//
//  Created by changdong  on 2020/7/6.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreServices
import AVFoundation
//MARK: 便利构造
public extension UIImage{
    //图片的二维码信息
    var qrMessage:String?{
        get{
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
            let deatureArr = detector?.features(in: CIImage(cgImage: self.cgImage!))
            if deatureArr!.count == 0 {
                return nil
            }
            let feature = deatureArr?.first as! CIQRCodeFeature //二维码图像特征
            let message = feature.messageString
            return message!
        }
    }
    
    
    /// 用纯色填充图片
    /// - Parameters:
    ///   - color: 纯色
    ///   - size: 填充尺寸
    convenience init?(color:UIColor,size:CGSize) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    
    /// UIVIew 剪裁成图片
    /// - Parameter clipView: 待剪裁的view
    convenience init?(clipView:UIView){
        UIGraphicsBeginImageContextWithOptions(clipView.frame.size, true, 0.0)
        clipView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image  = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    /// 生成二维码图片
    /// - Parameters:
    ///   - qrText: 二维码信息
    ///   - qrSize: 二维码尺寸
    convenience init?(qrText:String,qrSize:CGSize){
        let filter = CIFilter(name: "CIQRCodeGenerator") //二维码滤镜
        filter?.setDefaults()
        let data = qrText.data(using: .utf8)
        filter?.setValue(data, forKey: "inputMessage")
        // 设置二维码的纠错率
        filter?.setValue("M", forKey: "inputCorrectionLevel")
        // 从二维码滤镜里面, 获取结果图片
        var outputImage = filter?.outputImage
        let transform = CGAffineTransform.init(scaleX: 20, y: 20)
        outputImage = outputImage?.transformed(by: transform)
        let resultImage = UIImage(ciImage: outputImage!)
        UIGraphicsBeginImageContext(qrSize)
        resultImage.draw(in: CGRect(x: 0, y: 0, width: qrSize.width, height: qrSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
}

//MARK: 实例方法
extension UIImage{
    //MARK: 压缩图片
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
    
    //MARK: 裁剪照片
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
    
    /// 剪裁图片的指定部分
    /// - Parameter rect: 裁剪的指定位置
    /// - Returns: 剪裁后的图片
    func cut(rect:CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0.0, y: rect.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(.copy) //设置绘制模式
        context?.draw(self.cgImage!, in: rect)
        let image  = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }
    
    func addTextMark(_ content:String,_ frame:CGRect,_ color:UIColor)->UIImage{
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        var textAttributes:[NSAttributedString.Key:Any] = [:]
        textAttributes[.foregroundColor] = color
        textAttributes[.font] = UIFont.large
        
        content.AsNSString().draw(in: frame, withAttributes: textAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
        
    }
}

//类方法
extension UIImage{
    
    /// 图片合成GIF
    /// - Parameters:
    ///   - imageArr: 图片数组
    ///   - gifPath: GIF路径
    static func composeGif(imageArr:Array<UIImage>, delay:Double, gifPath: inout String){
//        let url:CFURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, gifPath as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
        let destination = CGImageDestinationCreateWithURL(gifPath.url as CFURL, kUTTypeGIF, imageArr.count, nil)


        
        let gifProperty = [
            kCGImagePropertyGIFDictionary : [
                kCGImagePropertyGIFHasGlobalColorMap: true,
                kCGImagePropertyColorModel: kCGImagePropertyColorModelRGB,
                kCGImagePropertyDepth: 8,
                kCGImagePropertyGIFLoopCount: 0
            ]
        ]
        CGImageDestinationSetProperties(destination!, gifProperty as CFDictionary)
        for image in imageArr {
            //每帧之间播放的时间间隔
            let frameDic = [
                kCGImagePropertyGIFDictionary : [
                    kCGImagePropertyGIFDelayTime : delay
                ]
            ]
            CGImageDestinationAddImage(destination!, image.cgImage!, frameDic as CFDictionary)
        }
        CGImageDestinationFinalize(destination!)
    }
    
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
            return LoadImage("file_video_big")!
        }
        
    }
    
    /// 生成马赛克图片
    func mosaicImage(level: CGFloat) -> UIImage? {
        let screenScale = level / max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let scale = self.size.width * screenScale
        guard let image = self.cgImage else {
            return nil
        }
        // 输入
        let input = CIImage(cgImage: image)
        // 输出
        let output = input.applyingFilter("CIPixellate", parameters: [kCIInputScaleKey: scale])

        // 渲染图片
        guard let cgimage = CIContext(options: nil).createCGImage(output, from: input.extent) else {
            return nil
        }
        return UIImage(cgImage: cgimage)

    }


}
