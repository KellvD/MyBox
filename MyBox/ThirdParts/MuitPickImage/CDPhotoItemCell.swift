//
//  CDPhotoItemCell.swift
//  MyRule
//
//  Created by changdong on 2018/12/14.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos
class CDPhotoItemCell: UICollectionViewCell {

    var imageView:UIImageView!
    var selectImageView:UIImageView!
    var itemWidth:CGFloat = 0.0
    var infoL:UILabel?


    override init(frame:CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.itemWidth = self.frame.width
        self.imageView = UIImageView(frame: CGRect(x: 0.5, y: 0.5, width: frame.width-1, height: frame.height-1))
        self.addSubview(self.imageView)

        self.selectImageView = UIImageView(frame: CGRect(x: 0.5, y: 0.5, width: frame.width-2, height: frame.height-2))
        self.selectImageView.image = UIImage(named: "照片选中@2x")
        self.addSubview(self.selectImageView)
        self.selectImageView.isHidden = true
        infoL = UILabel(frame: CGRect(x: 2, y: frame.height - 20, width: frame.width-4, height: 20))
        infoL?.textColor = UIColor.white
        infoL?.textAlignment = .right
        infoL?.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(infoL!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func setImageData(cdAsset:CDPHAsset){
        let asset:PHAsset = cdAsset.asset
        let scale = UIScreen.main.scale
        let cellSize = CGSize(width: itemWidth*scale, height: itemWidth*scale)
        CDAssetTon.shareInstance().getImageFromAsset(asset: asset, targetSize: cellSize) { (image, info) in
            self.imageView.image = image
        }

        if cdAsset.isGif {
            infoL?.isHidden = false
            infoL?.text = "GIF"
            infoL?.font = UIFont.boldSystemFont(ofSize: 12)

        }else{
            infoL?.isHidden = true
        }

        
    }
    public func setVideoData(cdAsset:CDPHAsset){

        let scale = UIScreen.main.scale
        let cellSize = CGSize(width: itemWidth*scale, height: itemWidth*scale)
        CDAssetTon.shareInstance().getImageFromAsset(asset: cdAsset.asset, targetSize: cellSize) { (image, info) in
            self.imageView.image = image
        }
        if cdAsset.videoTime > 0 {
            infoL?.isHidden = false
            self.infoL?.text = getMMSSFromSS(second: cdAsset.videoTime)

        }
    }

    func getMMSSFromSS(second:Int)->String{
        let hour = second / 3600
        let minute = (Int(second) % 3600)/3600
        let second = Int(second) % 60
        var format:String = ""
        if hour > 0 {
            format = String.init(format: "%02ld:%02ld:%02ld", hour,minute,second)
        }else{
            format = String.init(format: "%02ld:%02ld", minute,second)
        }
        return format
    }
    
}
