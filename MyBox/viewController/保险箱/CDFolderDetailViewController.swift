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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "文件夹简介"
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
    lazy var optionTitleArr: [[String]] = {
        var arr = [["名称"],["创建时间","修改时间"],["大小"],["访客不可见"]]
        if CDSignalTon.shared.loginType == .fake {
            arr = [["名称"],["创建时间","修改时间"],["大小"]]
        }
        return arr
    }()
    
    lazy var optionValueArr: [[String]] = {
        var totalSize = 0
        if folderInfo.folderType == .TextFolder {
            totalSize = GetFolderSize(folderPath: String.RootPath().appendingPathComponent(str: folderInfo.folderPath))
        }else{
            totalSize = CDSqlManager.shared.queryOneFolderSize(folderId: folderInfo.folderId)
        }
        
        var arr = [
            [folderInfo.folderName],
            [GetTimeFormat(timestamp: folderInfo.createTime),GetTimeFormat(timestamp: folderInfo.modifyTime)],
            [GetSizeFormat(fileSize: totalSize)],
            [""]
        ]
        if CDSignalTon.shared.loginType == .fake {
            arr = [
                [folderInfo.folderName],
                [GetTimeFormat(timestamp: folderInfo.createTime),GetTimeFormat(timestamp: folderInfo.modifyTime)],
                [GetSizeFormat(fileSize: totalSize)]
            ]
        }
        return arr
    }()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return optionTitleArr.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        optionTitleArr[section].count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            cell.selectionStyle = .none
            cell.accessoryType = .none
            let titleL = UILabel(frame: CGRect(x: 15, y: 9, width: 100, height: 30))
            titleL.font = TextMidFont
            titleL.textColor = TextBlackColor
            titleL.textAlignment = .left
            titleL.tag = 201
            cell.contentView.addSubview(titleL)
            
            let detaileL = UILabel(frame: CGRect(x: titleL.frame.maxX, y: 9, width: CDSCREEN_WIDTH-100-15, height: 30))
            detaileL.font = TextMidFont
            detaileL.textColor = TextLightBlackColor
            detaileL.textAlignment = .left
            detaileL.tag = 202
            cell.contentView.addSubview(detaileL)
            
            fakeSwitch = UISwitch(frame: CGRect(x: CDSCREEN_WIDTH - 60, y: 9, width: 45, height: 30))
            fakeSwitch.addTarget(self, action: #selector(chnageFakeModel(swi:)), for: .valueChanged)
            cell.addSubview(fakeSwitch)
            
        }
        let titleL = cell.viewWithTag(201) as! UILabel
        let detaileL = cell.viewWithTag(202) as? UILabel
        let title = optionTitleArr[indexPath.section][indexPath.row]
        titleL.text = title
        detaileL?.text = optionValueArr[indexPath.section][indexPath.row]
        detaileL?.isHidden = title == "访客不可见"
        fakeSwitch.isHidden = title != "访客不可见"
        fakeSwitch.isOn = folderInfo.fakeType == .invisible
       
        return cell

    }

    @objc func chnageFakeModel(swi:UISwitch){

        if swi.isOn{
            CDHUDManager.shared.showText(text: "已成功修改为访客可见")
            CDSqlManager.shared.updateOneSafeFolderFakeType(fakeType: .visible, folderId: folderInfo.folderId)
        }else{
             CDHUDManager.shared.showText(text: "已成功修改为访客不可见")
            CDSqlManager.shared.updateOneSafeFolderFakeType(fakeType: .invisible, folderId: folderInfo.folderId)
        }
        

    }

    @objc func delectFolderClick(){

        CDSqlManager.shared.deleteOneFolder(folderId: folderInfo.folderId)
        let allFileArr = CDSqlManager.shared.queryAllFileFromFolder(folderId: folderInfo.folderId)
        for fileInfo in allFileArr {

            if folderInfo.folderType == .ImageFolder {

                let thumpPath = String.thumpImagePath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                fileManagerDeleteFileWithFilePath(filePath: thumpPath)

                let defaultPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
                fileManagerDeleteFileWithFilePath(filePath: defaultPath)


            }else if folderInfo.folderType == .AudioFolder {
                let encryPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
                fileManagerDeleteFileWithFilePath(filePath: encryPath)
            }else if folderInfo.folderType == .VideoFolder {

                let thumpPath = String.thumpVideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                fileManagerDeleteFileWithFilePath(filePath: thumpPath)

                let defaultPath = String.VideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                fileManagerDeleteFileWithFilePath(filePath: defaultPath)
            }else if folderInfo.folderType == .TextFolder {

                let encryPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
                fileManagerDeleteFileWithFilePath(filePath: encryPath)
            }
            CDSqlManager.shared.deleteOneSafeFile(fileId: fileInfo.fileId)
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
