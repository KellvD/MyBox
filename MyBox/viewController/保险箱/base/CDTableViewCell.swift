//
//  CDAudioCell.swift
//  MyRule
//
//  Created by changdong on 2018/12/23.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import SnapKit
enum CDSelectIconState:Int  {
    case hide = 1 //隐藏
    case show = 2 //显示
    case selected = 3 //选中
}
class CDFileTableViewCell: UITableViewCell {

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
        self.selectedBackgroundView?.backgroundColor = .cellSelectColor

        headImage = UIImageView(frame: CGRect(x: 10, y: 10, width: 45, height: 45))
        self.contentView.addSubview(headImage)

        fileNameL = UILabel(frame:CGRect(x: headImage.frame.maxX+10, y: 10, width: CDSCREEN_WIDTH-75, height: 25))
        fileNameL.textColor = .textBlack
        fileNameL.font = .mid
        fileNameL.lineBreakMode = .byTruncatingMiddle
        fileNameL.textAlignment = .left
        self.contentView.addSubview(fileNameL)

        fileCreateTimeL = UILabel(frame:CGRect(x: headImage.frame.maxX+10, y: fileNameL.frame.maxY, width: 150, height: 25))
        fileCreateTimeL.textColor = .textGray
        fileCreateTimeL.textAlignment = .left
        fileCreateTimeL.font = .small
        self.contentView.addSubview(fileCreateTimeL)

        audioLengthL = UILabel(frame:CGRect(x: CDSCREEN_WIDTH-95, y: fileNameL.frame.maxY, width: 80, height: 30))
        audioLengthL.textAlignment = .center
        audioLengthL.textColor = .textGray
        audioLengthL.font = .small
        audioLengthL.textAlignment = .right
        self.contentView.addSubview(audioLengthL)
        audioLengthL.isHidden = true

        selectImage = UIImageView(frame: CGRect(x: CDSCREEN_WIDTH-15.0-30, y: 65.0/2-15.0, width: 30, height: 30))
        selectImage.image = LoadImage("no_selected")
        self.contentView.addSubview(selectImage)
        isSelect = false

        let line = UIView(frame: CGRect(x: 5, y: 64, width: CDSCREEN_WIDTH-10, height: 1))
        line.backgroundColor = .separatorColor
        self.contentView.addSubview(line)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func setConfigFileData(fileInfo:CDSafeFileInfo) {
        fileNameL.text = fileInfo.fileName
        fileCreateTimeL.text = GetTimeFormat(fileInfo.createTime)

        let imageName = GetFileHeadImage(type: fileInfo.fileType)
//        var rect = audioLengthL.frame
        headImage.image = UIImage(named: imageName!)
        selectImage.isHidden = showSelectIcon == .hide
        if showSelectIcon == .show {
            selectImage.image = LoadImage("no_selected")
//            rect.origin.x -= 30
        } else if showSelectIcon == .selected {
            selectImage.image = LoadImage("selected")
//            rect.origin.x -= 30
        }
        
        if fileInfo.fileType == .AudioType {
//            audioLengthL.frame = frame
            audioLengthL.isHidden = false
            audioLengthL.text = GetMMSSFromSS(timeLength: fileInfo.timeLength)
        }
    }
    
    func setConfigFolderData(folder:CDSafeFolder) {
        fileNameL.text = folder.folderName
        fileCreateTimeL.text = GetTimeFormat(folder.createTime)
        headImage.image = UIImage(named: "file_dir_big")
        
        selectImage.isHidden = showSelectIcon == .hide
        if showSelectIcon == .show {
            selectImage.image = LoadImage("no_selected")
        } else if showSelectIcon == .selected {
            selectImage.image = LoadImage("selected")
        }
    }
    
}


class CDFolderTableViewCell: UITableViewCell {

    private var headImageView:UIImageView!
    private var titleLabel:UILabel!
    private var separatorLine:UIView!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let view = UIView()
        self.selectedBackgroundView = view
        self.selectedBackgroundView?.backgroundColor = .cellSelectColor

        headImageView = UIImageView()
        headImageView.backgroundColor = UIColor.clear
        contentView.addSubview(headImageView)
        headImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10.0)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(45.0)
        }

        titleLabel = UILabel()
        titleLabel.textColor = .textBlack
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headImageView.snp.right).offset(15.0)
            make.centerY.equalToSuperview()
            make.height.equalTo(25.0)
        }
        
        separatorLine = UIView()
        separatorLine.backgroundColor = .separatorColor
        self.contentView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalToSuperview().offset(15.0)
            make.right.equalToSuperview().offset(-15.0)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configDataWith(folderInfo:CDSafeFolder) -> Void {
        switch folderInfo.folderType {
        case .ImageFolder:
            self.headImageView.image = UIImage(named: "icon_image")
        case .AudioFolder:
            self.headImageView.image = UIImage(named: "icon_audio")
        case .VideoFolder:
            self.headImageView.image = UIImage(named: "icon_media")
        case .TextFolder:
            self.headImageView.image = UIImage(named: "icon_txt")
        case .none:
            break
        }
        
        self.titleLabel.text = folderInfo.folderName
    }
    
    var separatorLineIsHidden:Bool{
        set{
            separatorLine.isHidden = newValue
        }
        get{
            return false
        }
    }
    
}
