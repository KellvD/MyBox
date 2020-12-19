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
    private var optionValueArr: [[String]] = [[]]
    private var tableView:UITableView!
    private var fakeSwitch:UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        initOptionValue()
        self.title = "文件夹简介"
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableView.delegate = self;
        tableView.dataSource = self
        self.view.addSubview(tableView)

        if folderInfo.isLock == LockOn {
            let footView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: CDSCREEN_WIDTH, height: 100.0))
            footView.backgroundColor = UIColor.clear

            let button = UIButton.creat(frame: CGRect(x: 30, y: 30, width: CDSCREEN_WIDTH-60, height: 48), text: "删除", textColor: .white, imageNormal: nil, target: self, function: #selector(delectFolderClick), supView: footView)
            button.backgroundColor = .red
            button.layer.cornerRadius = 4.0
            footView.addSubview(button)
            tableView.tableFooterView = footView
        }
        
        
        
    }
    lazy var optionTitleArr: [[String]] = {
        var arr = [["名称"],["创建时间","修改时间"],["文件数量","大小"],["访客不可见"]]
        if CDSignalTon.shared.loginType == .fake {
            arr = [["名称"],["创建时间","修改时间"],["文件数量","大小"]]
        }
        return arr
    }()
    func initOptionValue(){
        optionValueArr.removeAll()
        var totalSize = 0
        if folderInfo.folderType == .TextFolder {
            totalSize = GetFolderSize(folderPath: String.RootPath().appendingPathComponent(str: folderInfo.folderPath))
        }else{
            totalSize = CDSqlManager.shared.queryOneFolderSize(folderId: folderInfo.folderId)
        }
        let totalCount = CDSqlManager.shared.queryOneFolderFileCount(folderId: folderInfo.folderId)
       optionValueArr = [
            [folderInfo.folderName],
            [GetTimeFormat(folderInfo.createTime),GetTimeFormat(folderInfo.modifyTime)],
            ["\(totalCount)",GetSizeFormat(fileSize: totalSize)]
        ]
        if CDSignalTon.shared.loginType != .fake {
            optionValueArr.append([""]) //访客开关
        }
    }
        
    
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
       let cellId = "MineSwitchCell"
        var cell:CDSwitchTableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as? CDSwitchTableViewCell
        if cell == nil {
            cell = CDSwitchTableViewCell(style: .default, reuseIdentifier: cellId)
            cell.selectionStyle = .none
        }
        let title = optionTitleArr[indexPath.section][indexPath.row]
        cell.titleLabel.text = title
        cell.valueLabel.isHidden = title == "访客不可见"
        cell.valueLabel.text = optionValueArr[indexPath.section][indexPath.row]
        cell.swi.isHidden = title != "访客不可见"
        cell.accessoryType = title == "名称" ? .disclosureIndicator : .none
       if title == "访客不可见" {
           cell.swi.isOn = CDSignalTon.shared.fakeSwitch
           cell.swiBlock = {(swi) in
               self.chnageFakeModel(swi: swi)
           }
       }
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && folderInfo.isLock == LockOn {
            let markVC = CDMarkFileViewController()
            markVC.title = "重命名"
            markVC.maxTextCount = 60
            markVC.oldContent = folderInfo.folderName
            markVC.markType = .folderName
            markVC.markHandle = {[unowned self](newContent) in
                CDPrintManager.log("文件夹重命名-原名:\(self.folderInfo.folderName),新名:\(newContent!),folderId = \(self.folderInfo.folderId)", type: .InfoLog)
                CDSqlManager.shared.updateOneSafeFolderName(folderName: newContent!, folderId: self.folderInfo.folderId)
                self.folderInfo.folderName = newContent!
                self.initOptionValue()
                self.tableView.reloadData()
                CDHUDManager.shared.showComplete(text: "重命名成功")
            }
            self.navigationController?.pushViewController(markVC, animated: true)
        }
        
    }
    @objc func chnageFakeModel(swi:UISwitch){

        if swi.isOn{
            CDHUDManager.shared.showText(text: "访客可见模式打开")
            CDSqlManager.shared.updateOneSafeFolderFakeType(fakeType: .visible, folderId: folderInfo.folderId)
            CDPrintManager.log("访客可见模式打开", type: .InfoLog)
        }else{
             CDHUDManager.shared.showText(text: "访客可见模式关闭")
            CDSqlManager.shared.updateOneSafeFolderFakeType(fakeType: .invisible, folderId: folderInfo.folderId)
            CDPrintManager.log("访客可见模式关闭", type: .InfoLog)
        }
        CDSignalTon.shared.fakeSwitch = swi.isOn

    }

    @objc func delectFolderClick(){

        CDSqlManager.shared.deleteOneFolder(folderId: folderInfo.folderId)
        let allFileArr = CDSqlManager.shared.queryAllFileFromFolder(folderId: folderInfo.folderId)
        for fileInfo in allFileArr {

            if folderInfo.folderType == .ImageFolder {

                let thumpPath = String.thumpImagePath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                DeleteFile(filePath: thumpPath)

                let defaultPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
                DeleteFile(filePath: defaultPath)


            }else if folderInfo.folderType == .AudioFolder {
                let encryPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
                DeleteFile(filePath: encryPath)
            }else if folderInfo.folderType == .VideoFolder {

                let thumpPath = String.thumpVideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                DeleteFile(filePath: thumpPath)

                let defaultPath = String.VideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                DeleteFile(filePath: defaultPath)
            }else if folderInfo.folderType == .TextFolder {

                let encryPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
                DeleteFile(filePath: encryPath)
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
