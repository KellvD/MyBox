//
//  CDPickModel.swift
//  MyRule
//
//  Created by changdong on 2018/12/13.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos

/*
 将选中的图片，视频传出到MediaPick中处理
 */
protocol CDAssetSelectedDelagete: NSObjectProtocol{
    func selectedAssetsComplete(phAssets:[CDPHAsset])
}

class CDAlbum:NSObject {
   
    //相簿名称
    var title:String?
    //相簿资源
    var fetchResult:PHFetchResult<PHAsset>!

    var coverImage:UIImage!
    init(title:String?, fetchResult:PHFetchResult<PHAsset>) {
        super.init()
        self.title = title
        self.fetchResult = fetchResult
        let asset = fetchResult.lastObject
        let size = CGSize(width: 60, height: 60)
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: asset!, targetSize: size, contentMode: .aspectFit, options: nil, resultHandler: { (image, nfo) in
            self.coverImage = image
        })
    }
}

class CDPHAsset {
    var asset = PHAsset() //媒体资源
    var isSelected:CDSelected_Status!//是否选中
    var format:PhotoFormat! //资源类型
    var fileName:String!
    var fileSize:Int!
    var fileUrl:URL!
    var videoLength:Double!
}


enum CDMediaType:Int {
    case CDMediaImage
    case CDMediaVideo
    case CDMediaImageAndVideo
}


enum PhotoFormat:String {
    case Gif = "GIF"
    case Live = "LIVE"
    case Normal = "NORMAL"
}
