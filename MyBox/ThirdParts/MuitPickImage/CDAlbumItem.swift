//
//  CDAlbumItem.swift
//  MyRule
//
//  Created by changdong on 2018/12/13.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos

class CDAlbumItem {
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
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: { (image, nfo) in

            self.firstImage = image
        })
    }
}

class CDPHAsset {
    var asset = PHAsset()
    var isSelected = Bool()
    var isGif = Bool()
    var videoSize = Int()
    var filePath = String()
    var videoTime = Int()
    var timeStr = String()
    var modifyDate = Int()
    var fileName = String()

}


enum CDMediaType:Int {
    case CDMediaImage
    case CDMediaVideo
    case CDMediaImageAndVideo
}
