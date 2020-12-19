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
    
    private var tipLabel:UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)

        selectedView = UIImageView(frame: CGRect(x: frame.width - 30, y: frame.height - 30, width: 30, height: 30))
        self.contentView.addSubview(selectedView)

        scroller = CDImageScrollView(frame:  CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        scroller.isHidden = true
        self.contentView.addSubview(scroller)

        tipLabel = UILabel(frame: CGRect(x: 0, y: frame.height - 20, width: frame.width - 5, height: 20))
        tipLabel.textAlignment = .right
        tipLabel.font = TextSmallFont
        tipLabel.textColor = UIColor.white
        self.contentView.addSubview(tipLabel)
        tipLabel.isHidden = true
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
        selectedView.isHidden = !isBatchEdit
        selectedView.image = LoadImage(imageName: fileInfo.isSelected == .CDTrue ? "selected" : "no_selected", type: "png")

        tipLabel.isHidden = !(fileInfo.fileType == .GifType)
        tipLabel.text = "GIF"

        let tmpPath = String.RootPath().appendingFormat("%@",fileInfo.thumbImagePath)
        var mImgage:UIImage! = UIImage(contentsOfFile: tmpPath)
        if mImgage == nil {
            mImgage = LoadImage(imageName: "小图解密失败", type:"png")
        }
        self.backgroundView = UIImageView(image: mImgage)
    }
    
    
    func setVideoData(fileInfo:CDSafeFileInfo,isMutilEdit:Bool){
        
        selectedView.isHidden = !isMutilEdit
        selectedView.image = LoadImage(imageName: fileInfo.isSelected == .CDTrue ? "selected" : "no_selected", type: "png")
        self.tipLabel.isHidden = false
        self.tipLabel.text = GetMMSSFromSS(second: fileInfo.timeLength)
        
        let tmpPath = String.thumpVideoPath().appendingFormat("/%@",fileInfo.thumbImagePath.lastPathComponent())
        var mImgage:UIImage! = UIImage(contentsOfFile: tmpPath)
        if mImgage == nil {
            mImgage = LoadImage(imageName: "小图解密失败", type:"png")
        }
       
        self.backgroundView = UIImageView(image: mImgage)
    }
    
    func reloadSelectImageView() {
        selectedView.image = LoadImage(imageName: isSelected ? "selected" : "no_selected", type: "png")
        
    }
}
