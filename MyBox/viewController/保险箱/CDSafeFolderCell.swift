//
//  CDSafeFolderCell.swift
//  MyRule
//
//  Created by changdong on 2018/12/8.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit


class CDSafeFolderCell: UITableViewCell {


    var headImageView:UIImageView!
    var titleLabel:UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.init(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        let view = UIView()
        self.selectedBackgroundView = view
        self.selectedBackgroundView?.backgroundColor = LightBlueColor

        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 65))
        bgView.backgroundColor = UIColor.white
        self.contentView.addSubview(bgView)


        self.headImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 45, height: 45))
        self.headImageView.backgroundColor = UIColor.clear
        bgView.addSubview(self.headImageView)

        self.titleLabel = UILabel(frame: CGRect(x: 70, y: 20, width: CDSCREEN_WIDTH-100, height: 25))
        self.titleLabel.textColor = TextBlackColor
        bgView.addSubview(self.titleLabel)

        let separatorLine = UIView(frame: CGRect(x: 15, y: 64, width: CDSCREEN_WIDTH-15, height: 1))
        separatorLine.backgroundColor = SeparatorGrayColor
        bgView.addSubview(separatorLine)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func configDataWith(folderInfo:CDSafeFolder) -> Void {

        
        if (folderInfo.folderType == .ImageFolder){
            self.headImageView.image = UIImage(named: "图片")

        }else if (folderInfo.folderType == .AudioFolder){
            self.headImageView.image = UIImage(named: "音频")

        }else if (folderInfo.folderType == .VideoFolder){
            self.headImageView.image = UIImage(named: "视频")

        }else if (folderInfo.folderType == .TextFolder){
            self.headImageView.image = UIImage(named: "其他")

        }
        self.titleLabel.text = folderInfo.folderName
    }


}
