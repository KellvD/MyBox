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
protocol CDAssetSelectedDelagete{
    func selectedAssetsComplete(assets:[CDPHAsset])
}


class CDAlbum {
    //相簿名称
    var title:String?
    //相簿资源
    var fetchResult:PHFetchResult<PHAsset>

    var firstImage:UIImage?
    init(title:String?, fetchResult:PHFetchResult<PHAsset>) {
        self.title = title
        self.fetchResult = fetchResult
        let asset = fetchResult[0]
        let size = CGSize(width: 60, height: 60)
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil, resultHandler: { (image, nfo) in
            self.firstImage = image
        })
    }
}

class CDPHAsset {
    var asset = PHAsset() //媒体资源
    var isSelected:String!//是否选中 "YES","NO"
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


enum PhotoFormat {
    case Gif
    case Live
    case Normal
}
