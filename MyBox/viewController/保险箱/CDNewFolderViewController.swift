//
//  CDNewFolderViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/8.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

@objc protocol CDCreateFolderDelegate{
    @objc func createNewFolderSuccess()
}
class CDNewFolderViewController: CDBaseAllViewController {

    var folderNameField:UITextField!
    var iconImageV:UIImageView!

    var ImageFV:UIView!
    var AudioFV:UIView!
    var VideoFV:UIView!
    var TextFV:UIView!

    var selectType:NSFolderType!
    var selectView:UIImageView!
    weak var Cdelete:CDCreateFolderDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "创建文件夹"
        let doneBtn = UIButton(type: .custom)
        doneBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
        doneBtn.setTitle("完成", for: .normal)
        doneBtn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        doneBtn.setTitleColor(UIColor.white, for: .normal)
        doneBtn.contentHorizontalAlignment = .right
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneBtn)

        //
        let firstLine = UIView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 15))
        firstLine.backgroundColor = SeparatorGrayColor
        self.view.addSubview(firstLine)
        //
        iconImageV = UIImageView(frame: CGRect(x: 5, y: firstLine.frame.maxY + 12.5, width: 45, height: 45))
        iconImageV.image = LoadImage(imageName: "图片", type: "png")
        self.view.addSubview(iconImageV)

        folderNameField = UITextField(frame: CGRect(x: iconImageV.frame.maxX+5, y: firstLine.frame.maxY + 12.5, width: CDSCREEN_WIDTH-100, height: 45))
        folderNameField.text = "新建文件夹名称"
        folderNameField.textColor = TextLightGrayColor
        folderNameField.clearButtonMode = .whileEditing
        self.view.addSubview(folderNameField)

        let secondLine = UIView(frame: CGRect(x: 0, y: firstLine.frame.maxY+80, width: CDSCREEN_WIDTH, height: 15))
        secondLine.backgroundColor = SeparatorGrayColor
        self.view.addSubview(secondLine)

        let thirdLine = UIView(frame: CGRect(x: 0, y: secondLine.frame.maxY+60+30+5, width: CDSCREEN_WIDTH, height: 15))
        thirdLine.backgroundColor = SeparatorGrayColor
        self.view.addSubview(thirdLine)

        let space = (CDSCREEN_WIDTH - 5*2 - 60 * 4)/3
        let OY = secondLine.frame.maxY+5


        ImageFV = createFolderV(x: 5, y: OY, imageName: "图片", title: "图片")
        ImageFV.isUserInteractionEnabled = true;
        self.view.addSubview(ImageFV)
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageSelectTap))
        ImageFV.addGestureRecognizer(imageTap)

        AudioFV = createFolderV(x: ImageFV.frame.maxX + space, y: OY, imageName: "音频", title: "音频")
        AudioFV.isUserInteractionEnabled = true;
        self.view.addSubview(AudioFV)
        let audioTap = UITapGestureRecognizer(target: self, action: #selector(audioSelectTap))
        AudioFV.addGestureRecognizer(audioTap)

        VideoFV = createFolderV(x: AudioFV.frame.maxX + space, y: OY, imageName: "视频", title: "视频")
        VideoFV.isUserInteractionEnabled = true;
        self.view.addSubview(VideoFV)
        let videoTap = UITapGestureRecognizer(target: self, action: #selector(videoSelectTap))
        VideoFV.addGestureRecognizer(videoTap)

        TextFV = createFolderV(x: VideoFV.frame.maxX + space, y: OY, imageName: "其他", title: "文字")
        TextFV.isUserInteractionEnabled = true;
        self.view.addSubview(TextFV)
        let textTap = UITapGestureRecognizer(target: self, action: #selector(textSelectTap))
        TextFV.addGestureRecognizer(textTap)

        selectView = UIImageView(frame: CGRect(x: ImageFV.frame.minX, y: ImageFV.frame.minY, width: ImageFV.frame.width, height: ImageFV.frame.width))
        selectView.image = LoadImage(imageName: "照片选中", type: "png")
        self.view.addSubview(selectView)
        selectType = .ImageFolder

    }


    @objc func imageSelectTap(){

        if selectType != .ImageFolder {
            selectView.frame = CGRect(x: ImageFV.frame.minX, y: ImageFV.frame.minY, width: ImageFV.frame.width, height: ImageFV.frame.width)
            selectType = .ImageFolder
            iconImageV.image = LoadImage(imageName: "图片", type: "png")
        }
    }
    @objc func audioSelectTap(){

        if selectType != .AudioFolder {
            selectView.frame = CGRect(x: AudioFV.frame.minX, y: AudioFV.frame.minY, width: AudioFV.frame.width, height: AudioFV.frame.width)
            selectType = .AudioFolder
            iconImageV.image = LoadImage(imageName: "音频", type: "png")
        }
    }
    @objc func videoSelectTap(){

        if selectType != .VideoFolder {
            selectView.frame = CGRect(x: VideoFV.frame.minX, y: VideoFV.frame.minY, width: VideoFV.frame.width, height: VideoFV.frame.width)
            selectType = .VideoFolder
            iconImageV.image = LoadImage(imageName: "视频", type: "png")
        }
    }
    @objc func textSelectTap(){
        if selectType != .TextFolder {
            selectView.frame = CGRect(x: TextFV.frame.minX, y: TextFV.frame.minY, width: TextFV.frame.width, height: TextFV.frame.width)
            selectType = .TextFolder
            iconImageV.image = LoadImage(imageName: "其他", type: "png")
        }
    }

    @objc func doneBtnClick(){

        let folderName:String = folderNameField.text!
        let time = GetTimestamp()

        let folderInfo = CDSafeFolder()
        folderInfo.folderName = folderName
        folderInfo.folderType = selectType
        folderInfo.isLock = LockOn
        folderInfo.fakeType = .visible
        folderInfo.userId = CDUserId()
        folderInfo.createTime = Int(time)
        folderInfo.modifyTime = Int(time)
        folderInfo.accessTime = Int(time)
        folderInfo.superId = ROOTSUPERID
        _ = CDSqlManager.shared.addSafeFoldeInfo(folder: folderInfo)
        Cdelete?.createNewFolderSuccess()
        self.navigationController?.popViewController(animated: true)
    }

    func createFolderV(x:CGFloat,y:CGFloat,imageName:String,title:String) -> UIView {
        let bgView = UIView(frame: CGRect(x: x, y: y, width: 60, height: 60+30))
        let imageV = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        imageV.image = LoadImage(imageName: imageName, type: "png")
        bgView.addSubview(imageV)
        let titleL = UILabel(frame: CGRect(x: 0, y: 60, width: 60, height: 30))
        titleL.text = title
        titleL.textColor = TextLightGrayColor
        titleL.textAlignment =  .center
        bgView.addSubview(titleL)
        return bgView
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

