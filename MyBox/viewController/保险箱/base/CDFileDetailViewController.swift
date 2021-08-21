//
//  CDFileDetailViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/20.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDFileDetailViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {

    private var tableView:UITableView!
    private var optionValueArr: [[String]] = [[]]
    public var fileInfo:CDSafeFileInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initOptionValue()
        self.title = fileInfo.fileName
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableView.delegate = self;
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(CDSwitchCell.self, forCellReuseIdentifier: "fileDetailcell")
        self.view.addSubview(tableView)
        
    }

    func initOptionValue(){
        optionValueArr.removeAll()
        if fileInfo.fileType == .ImageType || fileInfo.fileType == .GifType {
            optionValueArr = [
                [fileInfo.fileName,fileInfo.filePath.suffix],
                [GetTimeFormat(fileInfo.createTime),GetTimeFormat(fileInfo.modifyTime) ],
                [GetSizeFormat(fileSize: fileInfo.fileSize)],
                ["\(fileInfo.fileWidth) x \(fileInfo.fileHeight)"],
                [fileInfo.markInfo]
            ]
            
        }else if  fileInfo.fileType == .AudioType || fileInfo.fileType == .VideoType {
            optionValueArr = [
                [fileInfo.fileName,fileInfo.filePath.suffix],
                [GetTimeFormat(fileInfo.createTime), GetTimeFormat(fileInfo.modifyTime)],
                [GetSizeFormat(fileSize: fileInfo.fileSize)],
                [GetMMSSFromSS(second: fileInfo.timeLength)],
                [fileInfo.markInfo]
            ]
        }else{
            optionValueArr = [
                [fileInfo.fileName,fileInfo.filePath.suffix],
                [GetTimeFormat(fileInfo.createTime), GetTimeFormat(fileInfo.modifyTime)],
                [GetSizeFormat(fileSize: fileInfo.fileSize)],
                [fileInfo.markInfo]
            ]
        }
    }
    
    lazy var optionTitleArr: [[String]] = {
        var arr = [[LocalizedString("Name"),LocalizedString("Format")],[LocalizedString("Created time"),LocalizedString("Modified Time")],[LocalizedString("Length")],[LocalizedString("Remarks")]]
        if fileInfo.fileType == .ImageType || fileInfo.fileType == .GifType {
            arr.insert([LocalizedString("Size")], at: 3)
        }else if  fileInfo.fileType == .AudioType || fileInfo.fileType == .VideoType {
            arr.insert([LocalizedString("Duration")], at: 3)
        }
        return arr
    }()
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return optionTitleArr.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionTitleArr[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let optionTitle = optionTitleArr[indexPath.section][indexPath.row]
        return optionTitle == LocalizedString("Remarks") ? 120 : CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECTION_SPACE
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "fileDetailcell"
        var cell:CDSwitchCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as? CDSwitchCell
        if cell == nil {
            cell = CDSwitchCell(style: .default, reuseIdentifier: cellId)
        }
        let optionTitle = optionTitleArr[indexPath.section][indexPath.row]
        cell.titleLabel.text = optionTitle
        cell.valueLabel.text = optionValueArr[indexPath.section][indexPath.row]
        cell.valueLabel.isHidden = false
        cell.accessoryType = (optionTitle == LocalizedString("Name") || optionTitle == LocalizedString("Remarks")) ? .disclosureIndicator : .none
        cell.selectionStyle = (optionTitle == LocalizedString("Name") || optionTitle == LocalizedString("Remarks")) ? .default : .none
        cell.separatorLineIsHidden = indexPath.row == optionTitleArr[indexPath.section].count - 1
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = optionTitleArr[indexPath.section][indexPath.row]
        if title == LocalizedString("Name") {
            let markVC = CDMarkFileViewController()
            markVC.title = LocalizedString("Renamed")
            markVC.maxTextCount = 60
            markVC.oldContent = fileInfo.fileName.removeSuffix()
            markVC.markType = .fileName
            markVC.markHandle = {[unowned self](newContent) in
                CDPrintManager.log("文件重命名-原名:\(self.fileInfo.fileName),新名:\(newContent!),folderId = \(self.fileInfo.fileId)", type: .InfoLog)
                CDSqlManager.shared.updateOneSafeFileName(fileName: newContent!, fileId: self.fileInfo.fileId)
                self.fileInfo.fileName = newContent!
                CDHUDManager.shared.showComplete(LocalizedString("Renamed successfully"))
                self.reloadData()
                
            }
            self.navigationController?.pushViewController(markVC, animated: true)

        }else if title == LocalizedString("Remarks"){
            let markVC = CDMarkFileViewController()
            markVC.title = LocalizedString("Remarks")
            markVC.maxTextCount = 140
            markVC.markType = .fileMark
            markVC.oldContent = fileInfo.markInfo
            markVC.markHandle = {
                let newContent = $0
                CDPrintManager.log("文件修改备注-原备注:\(self.fileInfo.markInfo),新备注:\(newContent!),fileId = \(self.fileInfo.fileId)", type: .InfoLog)
                CDSqlManager.shared.updateOneSafeFileMarkInfo(markInfo: newContent!, fileId: self.fileInfo.fileId)
                self.fileInfo.markInfo = newContent!
                CDHUDManager.shared.showComplete("Remarks successfully")
                self.reloadData()
            }
            self.navigationController?.pushViewController(markVC, animated: true)
        }
    }
    
    func reloadData() {
        initOptionValue()
        tableView.reloadData()
    }
}
