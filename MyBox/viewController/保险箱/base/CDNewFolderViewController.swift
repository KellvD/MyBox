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
    private var selectView:UIImageView!
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

        folderNameField = UITextField(frame: CGRect(x: iconImageV.frame.maxX+5, y: firstLine.frame.maxY + 12.5, width: CDSCREEN_WIDTH - iconImageV.frame.maxX - 5 - 15, height: 45))
        folderNameField.placeholder = "新建文件夹名称"
        folderNameField.textColor = TextLightGrayColor
        folderNameField.clearButtonMode = .whileEditing
        self.view.addSubview(folderNameField)

        let secondLine = UIView(frame: CGRect(x: 0, y: firstLine.frame.maxY+80, width: CDSCREEN_WIDTH, height: 15))
        secondLine.backgroundColor = SeparatorGrayColor
        self.view.addSubview(secondLine)

        let thirdLine = UIView(frame: CGRect(x: 0, y: secondLine.frame.maxY+60+30+5, width: CDSCREEN_WIDTH, height: 15))
        thirdLine.backgroundColor = SeparatorGrayColor
        self.view.addSubview(thirdLine)

        let space = (CDSCREEN_WIDTH - 15.0 * 2 - 60.0 * 4)/3
        let OY = secondLine.frame.maxY+5

        let arr = ["图片","音频","视频","其他"]

        for i in 0..<arr.count {
            let button = UIButton.creat(frame: CGRect(x: 15.0 + (60.0 + space) * CGFloat(i),
                                                      y: OY,
                                                      width: 60,
                                                      height: 60+30),
                                        text: arr[i],
                                        textColor: TextLightGrayColor,
                                        imageNormal: arr[i],
                                        target: self,
                                        function: #selector(onTapClick(sender:)),
                                        supView: self.view)
            button.tag = i
            button.setImagePosition(edge: .top, space: 10)
        }
        selectView = UIImageView(frame: CGRect(x: space, y: OY, width: 60, height: 60))
//        selectView.image = LoadImage(imageName: "selected", type: "png")
//        self.view.addSubview(selectView)
    }

    @objc func onTapClick(sender:UIButton){
        selectView.frame = sender.bounds
        selectType = NSFolderType(rawValue: sender.tag)!
        iconImageV.image = sender.currentImage
    }

    @objc func doneBtnClick(){

        let folderName = folderNameField.text!
        if(folderName.matches(pattern: symbolExpression) || folderName.isContainsEmoji()){
            let alert = UIAlertController(title: nil, message: "名称中不能包含表情及符号", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
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

