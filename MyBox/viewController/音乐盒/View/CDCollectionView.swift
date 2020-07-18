//
//  CDCollectionView.swift
//  MyRule
//
//  Created by changdong on 2019/4/19.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDCollectionView: UIView,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {


    var classArr:[CDMusicClassInfo]!
    var selectedRow:Int!
    var selectedMusicName:String?
    weak var menuDelete:CDMusicMenuDelegate!
    var tableView:UITableView!
    var bgView:UIView!
    var collectionBG:UIView!
    var createClassBG:UIView!
    var limitL:UILabel!
    var textField:UITextField!
    override init(frame:CGRect) {
        super.init(frame: frame)

        bgView = UIView(frame: frame)
        bgView.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCollectionView))
        bgView.addGestureRecognizer(tap)
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.4
        self.addSubview(bgView)

        classArr = CDSqlManager.shared.queryAllMusicClass()
        var height = CGFloat(64 * classArr.count + 48)
        if height >= CDViewHeight / 3 * 2 {
            height = CDViewHeight / 3 * 2
        }else if(height <= 48){
            height = 48 + 64
        }
        collectionBG = UIView(frame: CGRect(x: 15, y: (CDViewHeight - height)/2, width: CDSCREEN_WIDTH-30, height: height))
        collectionBG.layer.cornerRadius = 4.0
        collectionBG.backgroundColor = TextLightBlackColor
        self.addSubview(collectionBG)
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionBG.frame.width, height: 48))
        titleLabel.text = "收藏到歌单"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textColor = TextBlackColor
        collectionBG.addSubview(titleLabel)


        tableView = UITableView(frame: CGRect(x: 0, y: titleLabel.frame.maxY, width: collectionBG.frame.width, height: height - 48), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        collectionBG.layer.cornerRadius = 4.0
        collectionBG.addSubview(tableView)

        //
        let createH = CDViewHeight / 3 * 2
        createClassBG = UIView(frame: CGRect(x: 30, y: (CDViewHeight - createH)/2, width: CDSCREEN_WIDTH-60, height: createH))
        createClassBG.layer.cornerRadius = 4.0
        createClassBG.backgroundColor = BaseBackGroundColor
        self.addSubview(createClassBG)

        let titleL = UILabel(frame: CGRect(x: 15, y: 15, width: createClassBG.frame.width-30, height: 30))
        titleL.font = UIFont.boldSystemFont(ofSize: 25)
        titleL.text = "创建歌单"
        titleL.textColor = TextBlackColor
        createClassBG.addSubview(titleL)

        textField = UITextField(frame: CGRect(x: 15, y: titleL.frame.maxY + 10, width: createClassBG.frame.width-30, height: 48))
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "请输入歌单名称"
        textField.text = selectedMusicName
        textField.delegate = self
        createClassBG.addSubview(textField)

        let sperateLine = UIView(frame: CGRect(x: 15, y: textField.frame.maxY, width: textField.frame.width, height: 1))
        sperateLine.backgroundColor = SeparatorLightGrayColor
        createClassBG.addSubview(sperateLine)

        limitL = UILabel(frame: CGRect(x: createClassBG.frame.width-15-60, y: sperateLine.frame.maxY+5, width: 60, height: 30))
        limitL.font = TextMidSmallFont
        limitL.text = "\(0)/40"
        limitL.textAlignment = .right
        limitL.textColor = TextBlackColor
        createClassBG.addSubview(limitL)

        let Width = (createClassBG.frame.width / 2 - 15) / 2
        let cancleBtn = UIButton(type: .custom)
        cancleBtn.frame = CGRect(x: createClassBG.frame.width/2 + 5, y: createClassBG.frame.height-45, width: Width, height: 30)
        cancleBtn.setTitle("取消", for: .normal)
        cancleBtn.setTitleColor(UIColor.black, for: .normal)
        cancleBtn.addTarget(self, action: #selector(cancleCreateView), for: .touchUpInside)
        createClassBG.addSubview(cancleBtn)

        let sureBtn = UIButton(type: .custom)
        sureBtn.frame = CGRect(x: cancleBtn.frame.maxX + 5, y: cancleBtn.frame.minY, width: Width, height: 30)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(UIColor.black, for: .normal)
        sureBtn.addTarget(self, action: #selector(sureCreateView), for: .touchUpInside)
        createClassBG.addSubview(sureBtn)
        createClassBG.isHidden = true

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classArr.count + 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "collectionView_id")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "collectionView_id")
            let view = UIView()
            cell.selectedBackgroundView = view
            cell.selectedBackgroundView?.backgroundColor = LightBlueColor

            let imageV = UIImageView(frame: CGRect(x: 15, y: 5, width: 54, height: 54))
            imageV.tag = 101
            cell.addSubview(imageV)

            let titleL = UILabel(frame: CGRect(x: imageV.frame.maxX+15, y: 5, width: 200, height: 30))
            titleL.textColor = TextBlackColor
            titleL.font = TextMidFont
            titleL.tag = 102
            cell.addSubview(titleL)

            let countL = UILabel(frame: CGRect(x: imageV.frame.maxX+15, y: titleL.frame.maxY, width: 200, height: 24))
            countL.textColor = TextBlackColor
            countL.font = TextMidFont
            countL.tag = 103
            cell.addSubview(countL)


            let sperateLine = UILabel(frame: CGRect(x: imageV.frame.maxX+15, y: 63, width: CDSCREEN_WIDTH - imageV.frame.maxX-15, height: 1))
            sperateLine.backgroundColor = SeparatorLightGrayColor
            sperateLine.tag = 104
            cell.addSubview(sperateLine)
        }

        let titleV = cell.viewWithTag(102) as! UILabel
        let imageV = cell.viewWithTag(101) as! UIImageView
        let countL = cell.viewWithTag(103) as! UILabel
        let sperateLine = cell.viewWithTag(104) as! UILabel
        if indexPath.row == 0{

            countL.isHidden = true
            titleV.frame = CGRect(x: imageV.frame.maxX+15, y: 17, width: CDSCREEN_WIDTH - imageV.frame.maxX, height: 30)
            titleV.text = "创建歌单"
            imageV.image = LoadImageByName(imageName: "创建歌单", type: "png")
        }else{
            countL.isHidden = false
            titleV.frame = CGRect(x: imageV.frame.maxX+15, y: 5, width: 200, height: 30)
            let classInfo = classArr[indexPath.row-1]
            titleV.text = classInfo.className
            imageV.image = LoadImageByName(imageName: classInfo.classAvatar, type: "png")
            countL.text = "\(classArr.count) 首"

        }
        if indexPath.row == classArr.count {
            sperateLine.isHidden = true
        }else{
            sperateLine.isHidden = false
        }
        if indexPath.row == selectedRow{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: false)
            createClassBG.isHidden = false
            self.bringSubviewToFront(createClassBG)
            textField.text = selectedMusicName
            limitL.text = "\(selectedMusicName!.count)/40"
            bgView.isUserInteractionEnabled = false
        }else{
            selectedRow = indexPath.row
            tableView.reloadData()
        }
    }

    @objc func dismissCollectionView(){

        self.removeFromSuperview()
    }
    @objc func cancleCreateView(){

        createClassBG.isHidden = true

        bgView.isUserInteractionEnabled = true
    }

    @objc func sureCreateView(){
        let className = textField.text!

        if className.isEmpty {
            CDHUDManager.shared.showText(text: "请输入歌单名")
            return
        }
        let classInfo = CDMusicClassInfo()
        classInfo.className = className
        classInfo.classCreateTime = getCurrentTimestamp()
        CDSqlManager.shared.addOneMusicClassInfoWith(classInfo: classInfo)
        CDHUDManager.shared.showText(text: "创建成功")

        classArr = CDSqlManager.shared.queryAllMusicClass()
        tableView.reloadData()
        cancleCreateView()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let className:String = textField.text!

        limitL.text = "\(className.count)/40"
        if textField.text?.count ?? 0 > 40 {
            return false
        }
        return true
    }
}


