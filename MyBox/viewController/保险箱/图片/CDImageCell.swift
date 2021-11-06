//
//  CDImageCell.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
typealias CDSingleTapHandle = () -> Void
class CDImageCell: UICollectionViewCell {
    public var longTapHandle:CDLongTapHandle!
    public var singleTapHandle:CDSingleTapHandle!

    override init(frame: CGRect) {
        super.init(frame: frame)        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var selectedView: UIImageView = {
        let imageV = UIImageView(frame: CGRect(x: frame.width - 30, y: frame.height - 30, width: 30, height: 30))
        self.contentView.addSubview(imageV)

        return imageV
    }()
    
    lazy var scroller: CDImageScrollView = {
        let ss = CDImageScrollView(frame:  self.bounds)
        ss.longTapHandle = self.longTapHandle
        self.contentView.addSubview(ss)
        return ss
    }()
    
    private lazy var tipLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: frame.height - 20, width: frame.width - 5, height: 20))
        label.textAlignment = .right
        label.font = .small
        label.textColor = .white
        self.contentView.addSubview(label)
        return label
    }()
    
    func setScrollerImageData(fileInfo:CDSafeFileInfo){
        DispatchQueue.global().async {
            let tmpPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
            let tmpImage = UIImage(contentsOfFile: tmpPath)
            let tmpData = NSData(contentsOfFile: tmpPath)
            DispatchQueue.main.async(execute: {
                self.scroller.loadImageView(image: tmpImage!, gifData: tmpData!)
            })

        }

    }
    
    func setImageData(fileInfo:CDSafeFileInfo,isBatchEdit:Bool){
        self.selectedView.isHidden = !isBatchEdit
        self.selectedView.image = LoadImage(fileInfo.isSelected == .yes ? "selected" : "no_selected")

        self.tipLabel.isHidden = !(fileInfo.fileType == .GifType)
        self.tipLabel.text = "GIF"

        let tmpPath = String.RootPath().appendingFormat("%@",fileInfo.thumbImagePath)
        let mImgage:UIImage! = LoadImage(tmpPath)
        self.backgroundView = UIImageView(image: mImgage)
    }
    
    
    func setVideoData(fileInfo:CDSafeFileInfo,isMutilEdit:Bool){
        
        self.selectedView.isHidden = !isMutilEdit
        self.selectedView.image = LoadImage(fileInfo.isSelected == .yes ? "selected" : "no_selected")
        self.tipLabel.text = GetMMSSFromSS(timeLength: fileInfo.timeLength)
        
        let tmpPath = String.RootPath().appendingPathComponent(str: fileInfo.thumbImagePath)
        let mImgage:UIImage! = LoadImage(tmpPath)
       
        self.backgroundView = UIImageView(image: mImgage)
    }
    
    func reloadSelectImageView() {
        self.selectedView.image = LoadImage(isSelected ? "selected" : "no_selected")
        
    }
}
