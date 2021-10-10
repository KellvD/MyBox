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
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)

        if folderInfo.isLock == LockOn {
            let footView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: CDSCREEN_WIDTH, height: 100.0))
            footView.backgroundColor = UIColor.clear

            let button = UIButton(frame: CGRect(x: 30, y: 30, width: CDSCREEN_WIDTH-60, height: 48), text: "删除", textColor: .white, imageNormal: nil, target: self, function: #selector(delectFolderClick), supView: footView)
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
        let fileCount = CDSqlManager.shared.queryOneFolderFileCount(folderId: folderInfo.folderId)
        let folderCount = CDSqlManager.shared.queryOneFolderSubFolderCount(folderId: folderInfo.folderId)
        
       optionValueArr = [
            [folderInfo.folderName],
            [GetTimeFormat(folderInfo.createTime),GetTimeFormat(folderInfo.modifyTime)],
            ["\(fileCount + folderCount)",GetSizeFormat(fileSize: totalSize)]
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
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECTION_SPACE
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "MineSwitchCell"
        var cell:CDSwitchCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as? CDSwitchCell
        if cell == nil {
            cell = CDSwitchCell(style: .default, reuseIdentifier: cellId)
            cell.selectionStyle = .none
        }
        let optionTitle = optionTitleArr[indexPath.section][indexPath.row]
        cell.titleLabel.text = optionTitle
        cell.valueLabel.text = optionValueArr[indexPath.section][indexPath.row]
        cell.valueLabel.isHidden = false
        cell.swi.isHidden = optionTitle != "访客不可见".localize
        cell.accessoryType = (optionTitle == "名称".localize && folderInfo.isLock == LockOn) ? .disclosureIndicator : .none
        cell.selectionStyle = (optionTitle == "名称".localize && folderInfo.isLock == LockOn) ? .default : .none

        if optionTitle == "访客不可见".localize {
            cell.swi.isOn = CDSignalTon.shared.fakeSwitch
            cell.swiBlock = {(swi) in
                self.chnageFakeModel(swi: swi)
            }
        }
        cell.separatorLineIsHidden = indexPath.row == optionTitleArr[indexPath.section].count - 1
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let optionTitle = optionTitleArr[indexPath.section][indexPath.row]
        if optionTitle == "名称" && folderInfo.isLock == LockOn {
            let markVC = CDMarkFileViewController()
            markVC.title = "重命名"
            markVC.maxTextCount = 60
            markVC.oldContent = folderInfo.folderName
            markVC.markType = .folderName
            markVC.markHandle = {[weak self](newContent) in
                CDPrintManager.log("文件夹重命名-原名:\(self!.folderInfo.folderName),新名:\(newContent!),folderId = \(self!.folderInfo.folderId)", type: .InfoLog)
                CDSqlManager.shared.updateOneSafeFolderName(folderName: newContent!, folderId: self!.folderInfo.folderId)
                self!.folderInfo.folderName = newContent!
                self!.initOptionValue()
                self!.tableView.reloadData()
                CDHUDManager.shared.showComplete("备注成功！")
            }
            self.navigationController?.pushViewController(markVC, animated: true)
        }
        
    }
    
    @objc func chnageFakeModel(swi:UISwitch){

        if swi.isOn{
            CDHUDManager.shared.showText("访客可见模式关闭".localize)
            CDSqlManager.shared.updateOneSafeFolderFakeType(fakeType: .invisible, folderId: folderInfo.folderId)
            CDPrintManager.log("访客可见模式关闭", type: .InfoLog)
        }else{
            CDHUDManager.shared.showText("访客可见模式打开".localize)
            CDSqlManager.shared.updateOneSafeFolderFakeType(fakeType: .visible, folderId: folderInfo.folderId)
            CDPrintManager.log("访客可见模式打开", type: .InfoLog)
        }
        CDSignalTon.shared.fakeSwitch = swi.isOn

    }

    @objc func delectFolderClick(){

        CDSqlManager.shared.deleteOneFolder(folderId: folderInfo.folderId)
        let allFileArr = CDSqlManager.shared.queryAllFileFromFolder(folderId: folderInfo.folderId)
        for fileInfo in allFileArr {
            if fileInfo.folderType == .ImageFolder || fileInfo.folderType == .VideoFolder {
                let thumpPath = String.RootPath().appendingPathComponent(str: fileInfo.thumbImagePath)
                thumpPath.delete()
            }
            let defaultPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
            defaultPath.delete()
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
