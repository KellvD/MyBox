//
//  CDImageCell.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDImageCell: UICollectionViewCell {

    var selectedView:UIImageView!
    var scroller:CDImageScrollView!
    var videoSizeL:UILabel!
    var gifL:UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        selectedView = UIImageView(image: LoadImageByName(imageName: "照片选中", type: "png"))
        selectedView.frame = self.bounds
        selectedView.isHidden = true
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

}
