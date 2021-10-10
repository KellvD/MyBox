//
//  CDCameraConfig.swift
//  MyBox
//
//  Created by changdong on 2021/10/8.
//  Copyright © 2018 changdong. All rights reserved.
//
import UIKit
import CoreLocation
public struct CDCameraPhotoConfig{
    
    public enum ImageType: Int, Codable {
        /// 静态图
        case normal
        /// 动图
        case gif
    }
    ///文件名称
    public var fileName : String
    
    /// 图片
    public var image : UIImage
    
    /// 图片类型
    public var type:ImageType
    
    /// 创建时间
    public var createTime : Int
    
    ///创建图片所在位置
    
    public var location : CLLocation
    
    init(fileName:String,image:UIImage,type:ImageType,createTime:Int,location:CLLocation) {
        
        self.fileName = fileName
        self.image = image
        self.type = type
        self.createTime = createTime
        self.location = location
    }
}

public struct CDCameraVideoConfig{
    ///文件名称
    public var fileUrl : URL
    
    /// 创建时间
    public var createTime : Int
    
    
    init(fileUrl:URL,createTime:Int) {
        
        self.fileUrl = fileUrl
        self.createTime = createTime

    }
}
