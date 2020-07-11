//
//  CDAudioCell.swift
//  MyRule
//
//  Created by changdong on 2018/12/23.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

enum CDSelectIconState:Int  {
    case hide = 1 //隐藏
    case show = 2 //显示
    case selected = 3 //选中
}
class CDTableViewCell: UITableViewCell {

    var fileNameL:UILabel!
    var fileCreateTimeL:UILabel!
    var audioLengthL:UILabel!
    var headImage:UIImageView!
    var selectImage:UIImageView!
    var isSelect:Bool = false
    var showSelectIcon:CDSelectIconState!



    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let view = UIView()
        self.selectedBackgroundView = view
        self.selectedBackgroundView?.backgroundColor = LightBlueColor

        headImage = UIImageView(frame: CGRect(x: 10, y: 10, width: 45, height: 45))
        self.contentView.addSubview(headImage)

        fileNameL = UILabel(frame:CGRect(x: headImage.frame.maxX+10, y: 10, width: CDSCREEN_WIDTH-75, height: 25))
        fileNameL.textColor = TextBlackColor
        fileNameL.font = TextMidFont
        fileNameL.lineBreakMode = .byTruncatingMiddle
        fileNameL.textAlignment = .left
        self.contentView.addSubview(fileNameL)

        fileCreateTimeL = UILabel(frame:CGRect(x: headImage.frame.maxX+10, y: fileNameL.frame.maxY, width: 150, height: 25))
        fileCreateTimeL.textColor = TextGrayColor
        fileCreateTimeL.textAlignment = .left
        fileCreateTimeL.font = TextSmallFont
        self.contentView.addSubview(fileCreateTimeL)

        audioLengthL = UILabel(frame:CGRect(x: CDSCREEN_WIDTH-95, y: fileNameL.frame.maxY, width: 80, height: 30))
        audioLengthL.textAlignment = .center
        audioLengthL.textColor = TextGrayColor
        audioLengthL.font = TextSmallFont
        audioLengthL.textAlignment = .right
        self.contentView.addSubview(audioLengthL)
        audioLengthL.isHidden = true

        selectImage = UIImageView(frame: CGRect(x: CDSCREEN_WIDTH-15.0-30, y: 65.0/2-15.0, width: 30, height: 30))
        selectImage.image = LoadImageByName(imageName:"no_selected", type: "png")
        self.contentView.addSubview(selectImage)
        isSelect = false

        let line = UIView(frame: CGRect(x: 5, y: 64, width: CDSCREEN_WIDTH-10, height: 1))
        line.backgroundColor = SeparatorGrayColor
        self.contentView.addSubview(line)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func setConfigFileData(fileInfo:CDSafeFileInfo) {
        fileNameL.text = fileInfo.fileName
        fileCreateTimeL.text = timestampTurnString(timestamp: fileInfo.createTime)

        let imageName = getFileHeadImage(type: fileInfo.fileType)
//        var rect = audioLengthL.frame
        headImage.image = UIImage(named: imageName!)
        selectImage.isHidden = showSelectIcon == .hide
        if showSelectIcon == .show {
            selectImage.image = LoadImageByName(imageName: "no_selected", type: "png")
//            rect.origin.x -= 30
        } else if showSelectIcon == .selected {
            selectImage.image = LoadImageByName(imageName: "selected", type: "png")
//            rect.origin.x -= 30
        }
        
        
        if fileInfo.fileType == .AudioType {
//            audioLengthL.frame = frame
            audioLengthL.isHidden = false
            audioLengthL.text = getMMSSFromSS(second: fileInfo.timeLength)
        }
    }
    
    func setConfigFolderData(folder:CDSafeFolder) {
        fileNameL.text = folder.folderName
        fileCreateTimeL.text = timestampTurnString(timestamp: folder.createTime)
        headImage.image = UIImage(named: "file_dir_big")
        
        selectImage.isHidden = showSelectIcon == .hide
        if showSelectIcon == .show {
            selectImage.image = LoadImageByName(imageName: "no_selected", type: "png")
        } else if showSelectIcon == .selected {
            selectImage.image = LoadImageByName(imageName: "selected", type: "png")
        }
    }
    
}
