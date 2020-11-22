//
//  CDClassCell.swift
//  MyRule
//
//  Created by changdong on 2019/4/19.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDClassCell: UICollectionViewCell {

    var titleL:UILabel!
    var imageV:UIImageView!


    override init(frame: CGRect) {
        super.init(frame: frame)

        imageV = UIImageView(frame: CGRect(x: frame.width/5, y: frame.width/5, width: frame.width/5 * 3, height: frame.width/5 * 3))
        self.addSubview(imageV)

        titleL = UILabel(frame: CGRect(x: 0, y: frame.height-30, width: frame.width, height: 30))
        titleL.textColor = TextBlackColor
        titleL.font = TextMidFont
        titleL.textAlignment = .center
        self.addSubview(titleL)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onUpdateClassInfo(classInfo:CDMusicClassInfo) {

        titleL.text = classInfo.className
        imageV.image = LoadImage(imageName: classInfo.classAvatar, type: "png")
    }
}
