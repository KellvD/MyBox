//
//  CDNewFolderViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/8.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDNewFolderViewController: CDBaseAllViewController {

    private var folderNameField:UITextField!
    private var iconImageV:UIImageView!
    private var selectType:NSFolderType = .ImageFolder
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "创建文件夹".localize
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClick))
        self.navigationItem.rightBarButtonItem?.tintColor = .white
        //
        let firstLine = UIView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 15))
        firstLine.backgroundColor = .separatorColor
        self.view.addSubview(firstLine)
        //
        iconImageV = UIImageView(frame: CGRect(x: 10, y: firstLine.frame.maxY + 12.5, width: 45, height: 45))
        iconImageV.image = "icon_image".image
        self.view.addSubview(iconImageV)

        folderNameField = UITextField(frame: CGRect(x: iconImageV.frame.maxX+5, y: firstLine.frame.maxY + 12.5, width: CDSCREEN_WIDTH - iconImageV.frame.maxX - 5 - 15, height: 45))
        folderNameField.placeholder = "新建文件夹名称".localize
        folderNameField.textColor = .textGray
        folderNameField.clearButtonMode = .whileEditing
        self.view.addSubview(folderNameField)

        let secondLine = UIView(frame: CGRect(x: 0, y: firstLine.frame.maxY+80, width: CDSCREEN_WIDTH, height: 15))
        secondLine.backgroundColor = .separatorColor
        self.view.addSubview(secondLine)

        let thirdLine = UIView(frame: CGRect(x: 0, y: secondLine.frame.maxY+60+30+5, width: CDSCREEN_WIDTH, height: 15))
        thirdLine.backgroundColor = .separatorColor
        self.view.addSubview(thirdLine)

        let space = (CDSCREEN_WIDTH - 15.0 * 2 - 60.0 * 4)/3
        let OY = secondLine.frame.maxY+5

        let imageArr = ["icon_image","icon_audio","icon_media","icon_txt"]
        let titleArr = ["图片文件".localize, "音频文件".localize,"视频文件".localize,"文本文件".localize]

        for i in 0..<imageArr.count {
            let button = UIButton(frame: CGRect(x: 15.0 + (60.0 + space) * CGFloat(i),
                                                      y: OY,
                                                      width: 60,
                                                      height: 60+30),
                                        text: titleArr[i],
                                        textColor: .textGray,
                                        imageNormal: imageArr[i],
                                        target: self,
                                        function: #selector(onTapClick(sender:)),
                                        supView: self.view)
            button.titleLabel?.font = .small
            button.tag = i
            button.setImagePosition(edge: .top, space: 10)
        }
    }

    @objc func onTapClick(sender:UIButton){
        selectType = NSFolderType(rawValue: sender.tag)!
        iconImageV.image = sender.currentImage
    }

    @objc func doneBtnClick(){

        let folderName = folderNameField.text!.isEmpty ? "未命名文件夹".localize : folderNameField.text!
        if(folderName.matches(pattern: symbolExpression) || folderName.isContainsEmoji()){
            let alert = UIAlertController(title: nil, message: "名称中不能包含表情及字符".localize, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "知道了".localize, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let time = GetTimestamp(nil)
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
        CDPrintManager.log("创建新文件夹:\(folderName)", type: .InfoLog)
        self.navigationController?.popViewController(animated: true)
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

