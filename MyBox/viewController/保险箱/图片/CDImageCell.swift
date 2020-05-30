//
//  CDImageCell.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDImageCell: UICollectionViewCell {

    var selectedView:UIImageView!   //选择标志
    var scroller:CDImageScrollView! //滚动展示是可缩放
    var tapQRHandle:CDTapRQHandle!
    
    private var videoSizeL:UILabel!
    private var gifL:UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)

        selectedView = UIImageView(frame: CGRect(x: frame.width - 30, y: frame.height - 30, width: 30, height: 30))
        self.contentView.addSubview(selectedView)

        scroller = CDImageScrollView(frame:  CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        scroller.isHidden = true
        self.contentView.addSubview(scroller)

        videoSizeL = UILabel(frame: CGRect(x: 0, y: frame.height - 20, width: frame.width - 5, height: 20))
        videoSizeL.textAlignment = .right
        videoSizeL.font = TextSmallFont
        videoSizeL.textColor = UIColor.white
        self.contentView.addSubview(videoSizeL)
        videoSizeL.isHidden = true

        gifL = UILabel(frame: CGRect(x: 2, y: frame.height - 20, width: frame.width-4, height: 20))
        gifL.textColor = UIColor.white
        gifL.textAlignment = .right
        gifL.text = "GIF"
        gifL.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(gifL)
        gifL.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setScrollerImageData(fileInfo:CDSafeFileInfo){
        self.scroller.isHidden = false
        DispatchQueue.global().async {
            let tmpPath = String.ImagePath().appendingFormat("/%@",fileInfo.filePath.lastPathComponent())
            let tmpImage = UIImage(contentsOfFile: tmpPath)
            let tmpData = NSData(contentsOfFile: tmpPath)
            let imageSize = tmpImage!.size
            var isWidthLonger = false
            if Int(imageSize.width) > Int(imageSize.height){
                isWidthLonger = false
            }
            var newSize = CGSize()
            if isWidthLonger{
                let tempWidth = CGFloat(5500)

                if Int(imageSize.width) > Int(tempWidth) {
                    newSize = CGSize(width: tempWidth, height: tempWidth * imageSize.height / imageSize.width)
                } else {
                    newSize = imageSize
                }
            }else{
                let tempHeight = CGFloat(5500)
                if imageSize.height > tempHeight {
                    newSize = CGSize(width: tempHeight * imageSize.width / imageSize.height, height: tempHeight)
                } else {
                    newSize = imageSize
                }
            }
            var new = UIImage()
            UIGraphicsBeginImageContext(newSize)
            let context = UIGraphicsGetCurrentContext()
            if context != nil {
                tmpImage?.draw(in: CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height))
                new = UIGraphicsGetImageFromCurrentImageContext()!
            }
            UIGraphicsEndImageContext()
            DispatchQueue.main.async(execute: {
                self.scroller.loadImageView(image: new, gifData: tmpData!)
                self.scroller.tapQRHandle = self.tapQRHandle
            })

        }

    }
    func setImageData(fileInfo:CDSafeFileInfo,isBatchEdit:Bool){
        if isBatchEdit {
            selectedView.isHidden = false
            if fileInfo.isSelected == .CDTrue {
                selectedView.image = LoadImageByName(imageName: "selected", type: "png")
            }else{
                selectedView.image = LoadImageByName(imageName: "no_selected", type: "png")
            }

        }else{
            selectedView.isHidden = true
        }
        if fileInfo.fileType == .GifType{
            gifL.isHidden = false
        }else{
            gifL.isHidden = true
        }

        let tmpPath = String.libraryUserdataPath().appendingFormat("%@",fileInfo.thumbImagePath)
        var mImgage:UIImage! = UIImage(contentsOfFile: tmpPath)
        if mImgage == nil {
            mImgage = LoadImageByName(imageName: "小图解密失败", type:"png")
        }
        self.backgroundView = UIImageView(image: mImgage)
    }
    
    
    func setVideoData(fileInfo:CDSafeFileInfo,isMutilEdit:Bool){
        if isMutilEdit {
            selectedView.isHidden = false
            if fileInfo.isSelected == .CDTrue {
                selectedView.image = LoadImageByName(imageName: "selected", type: "png")
            }else{
                selectedView.image = LoadImageByName(imageName: "no_selected", type: "png")
            }

        }else{
            selectedView.isHidden = true
        }

        let tmpPath = String.thumpVideoPath().appendingFormat("/%@",fileInfo.thumbImagePath.lastPathComponent())
        var mImgage:UIImage! = UIImage(contentsOfFile: tmpPath)
        if mImgage == nil {
            mImgage = LoadImageByName(imageName: "小图解密失败", type:"png")
        }
        self.videoSizeL.isHidden = false
        self.videoSizeL.text = getMMSSFromSS(second: fileInfo.timeLength)
        self.backgroundView = UIImageView(image: mImgage)
    }
    
    func reloadSelectImageView() {
        if isSelected {
            selectedView.image = LoadImageByName(imageName: "selected", type: "png")
        }else{
            selectedView.image = LoadImageByName(imageName: "no_selected", type: "png")
        }
    }
}
