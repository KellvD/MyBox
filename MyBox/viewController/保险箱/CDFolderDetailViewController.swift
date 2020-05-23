//
//  CDFolderDetailViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/11.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDFolderDetailViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {

    public var folderInfo:CDSafeFolder!

    private var tableView:UITableView!
    private var fakeSwitch:UISwitch!
    private var totalSize:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "文件夹简介"
        let folderPath = String.libraryUserdataPath().appendingPathComponent(str: folderInfo.folderPath)
        totalSize = getFolderSizeAtPath(folderPath: folderPath)
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableView.delegate = self;
        tableView.dataSource = self
        self.view.addSubview(tableView)


        if folderInfo.isLock == LockOn {
            let footView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: CDSCREEN_WIDTH, height: 100.0))
            footView.backgroundColor = UIColor.clear

            let button = UIButton(type: .custom)
            button.backgroundColor = .red
            button.setTitle("删除", for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.frame = CGRect(x: 30, y: 30, width: CDSCREEN_WIDTH-60, height: 48)
            button.addTarget(self, action: #selector(delectFolderClick), for: .touchDown)
            footView.addSubview(button)
            tableView.tableFooterView = footView
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return 2
        }else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if CDSignalTon.shareInstance().currentType == CDLoginFake && indexPath.section == 2{
            return 0.01
        }
        return 48
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view

    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identify = "folderDetailCell"

        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identify)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identify)
            cell.selectedBackgroundView = UIView()
            cell.selectedBackgroundView?.backgroundColor = LightBlueColor

            let titleL = UILabel(frame: CGRect(x: 15, y: 9, width: 100, height: 30))
            titleL.font = TextMidFont
            titleL.textColor = TextBlackColor
            titleL.textAlignment = .left
            titleL.tag = 201
            cell.contentView.addSubview(titleL)

            if indexPath.section == 2{
                fakeSwitch = UISwitch(frame: CGRect(x: CDSCREEN_WIDTH - 60, y: 9, width: 45, height: 30))
                fakeSwitch.addTarget(self, action: #selector(chnageFakeModel(swi:)), for: .valueChanged)
                cell.addSubview(fakeSwitch)
            }else{
                let detaileL = UILabel(frame: CGRect(x: titleL.frame.maxX, y: 9, width: CDSCREEN_WIDTH-100-15, height: 30))
                detaileL.font = TextMidFont
                detaileL.textColor = TextLightBlackColor
                detaileL.textAlignment = .left
                detaileL.tag = 202
                cell.contentView.addSubview(detaileL)
            }
        }
        let titleL = cell.viewWithTag(201) as! UILabel
        let detaileL = cell.viewWithTag(202) as? UILabel
        if indexPath.section == 0 {
            titleL.text = "名称"
            detaileL?.text = folderInfo.folderName
        }else if indexPath.section == 1 {
            if indexPath.row == 0{
                titleL.text = "创建时间"
                detaileL?.text = timestampTurnString(timestamp: folderInfo.createTime)
            }else{
                titleL.text = "大小"
                detaileL?.text = returnSize(fileSize: totalSize)
            }
        }else if indexPath.section == 2 {
            titleL.text = "访客不可见"
            let isOn = folderInfo.fakeType == .invisible ? true : false
            fakeSwitch.isOn = isOn

            if CDSignalTon.shareInstance().currentType == CDLoginFake {
                cell.isHidden = true
            }else{
                cell.isHidden = false
            }

        }

        return cell

    }

    @objc func chnageFakeModel(swi:UISwitch){

        if swi.isOn{
            CDHUDManager.shareInstance().showText(text: "已成功修改为访客可见")
            CDSqlManager.instance().updateOneSafeFileFakeType(fakeType: .visible, folderId: folderInfo.folderId)
        }else{
             CDHUDManager.shareInstance().showText(text: "已成功修改为访客不可见")
            CDSqlManager.instance().updateOneSafeFileFakeType(fakeType: .invisible, folderId: folderInfo.folderId)
        }

    }

    @objc func delectFolderClick(){

        CDSqlManager.instance().deleteOneFolder(folderId: folderInfo.folderId)
        let allFileArr = CDSqlManager.instance().queryAllFileFromFolder(folderId: folderInfo.folderId)
        for fileInfo in allFileArr {

            if folderInfo.folderType == .ImageFolder {

                let thumpPath = String.thumpImagePath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                fileManagerDeleteFileWithFilePath(filePath: thumpPath)

                let defaultPath = String.libraryUserdataPath().appendingPathComponent(str: fileInfo.filePath)
                fileManagerDeleteFileWithFilePath(filePath: defaultPath)


            }else if folderInfo.folderType == .AudioFolder {
                let encryPath = String.libraryUserdataPath().appendingPathComponent(str: fileInfo.filePath)
                fileManagerDeleteFileWithFilePath(filePath: encryPath)
            }else if folderInfo.folderType == .VideoFolder {

                let thumpPath = String.thumpVideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                fileManagerDeleteFileWithFilePath(filePath: thumpPath)

                let defaultPath = String.VideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                fileManagerDeleteFileWithFilePath(filePath: defaultPath)
            }else if folderInfo.folderType == .OtherFolder {

                let encryPath = String.libraryUserdataPath().appendingPathComponent(str: fileInfo.filePath)
                fileManagerDeleteFileWithFilePath(filePath: encryPath)
            }
            CDSqlManager.instance().deleteOneSafeFile(fileId: fileInfo.fileId)
        }

        self.navigationController?.popViewController(animated: true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
