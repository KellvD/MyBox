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
    var fileInfo:CDSafeFileInfo!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initOptionValue()
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableView.delegate = self;
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }

    func initOptionValue(){
        optionValueArr.removeAll()
        if fileInfo.fileType == .ImageType || fileInfo.fileType == .GifType {
            optionValueArr = [
                [fileInfo.fileName,fileInfo.filePath.getSuffix()],
                [GetTimeFormat(fileInfo.createTime),
                 GetTimeFormat(fileInfo.modifyTime)
                ],
                [GetSizeFormat(fileSize: fileInfo.fileSize)],
                ["\(fileInfo.fileWidth) x \(fileInfo.fileHeight)"],
                [fileInfo.markInfo]
            ]
            
        }else if  fileInfo.fileType == .AudioType || fileInfo.fileType == .VideoType {
            optionValueArr = [
                [fileInfo.fileName,fileInfo.filePath.getSuffix()],
                [GetTimeFormat(fileInfo.createTime),
                 GetTimeFormat(fileInfo.modifyTime)
                ],
                [GetSizeFormat(fileSize: fileInfo.fileSize)],
                [GetMMSSFromSS(second: fileInfo.timeLength)],
                [fileInfo.markInfo]
            ]
        }else{
            optionValueArr = [
                [fileInfo.fileName,fileInfo.filePath.getSuffix()],
                [GetTimeFormat(fileInfo.createTime),
                 GetTimeFormat(fileInfo.modifyTime)
                ],
                [GetSizeFormat(fileSize: fileInfo.fileSize)],
                [fileInfo.markInfo]
            ]
        }
    }
    
    lazy var optionTitleArr: [[String]] = {
        var arr = [["名称","格式"],["创建时间","修改时间"],["大小"],["备注"]]
        if fileInfo.fileType == .ImageType || fileInfo.fileType == .GifType {
             arr = [["名称","格式"],["创建时间","修改时间"],["大小"],["尺寸"],["备注"]]
        }else if  fileInfo.fileType == .AudioType || fileInfo.fileType == .VideoType {
            arr = [["名称","格式"],["创建时间","修改时间"],["大小"],["时长"],["备注"]]
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
        return 48
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identify = "fileDetailcell"

        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identify)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identify)
            cell.selectedBackgroundView = UIView()
            cell.selectedBackgroundView?.backgroundColor = LightBlueColor

            let titleL = UILabel(frame: CGRect(x: 15, y: 9, width: 100, height: 30))
            titleL.font = TextMidFont
            titleL.textColor = TextBlackColor
            titleL.textAlignment = .left
            titleL.tag = 101
            cell.contentView.addSubview(titleL)

            let detaileL = UILabel(frame: CGRect(x: titleL.frame.maxX, y: 9, width: CDSCREEN_WIDTH-100-15, height: 30))
            detaileL.font = TextMidFont
            detaileL.textColor = TextLightBlackColor
            detaileL.textAlignment = .left
            detaileL.tag = 102
            cell.contentView.addSubview(detaileL)

        }
        let title = optionTitleArr[indexPath.section][indexPath.row]
        let titleLabel = cell.contentView.viewWithTag(101) as! UILabel
        let detaileL = cell.contentView.viewWithTag(102) as! UILabel

        titleLabel.text = title
        detaileL.text = optionValueArr[indexPath.section][indexPath.row]
        if title == "名称" || title == "备注"{
             cell.accessoryType =  .disclosureIndicator
        } else {
             cell.accessoryType = .none
        }
        return cell

    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = optionTitleArr[indexPath.section][indexPath.row]
        if title == "名称" {
            let markVC = CDMarkFileViewController()
            markVC.title = "重命名"
            markVC.maxTextCount = 60
            markVC.oldContent = fileInfo.fileName
            markVC.markType = .fileName
            markVC.markHandle = {(newContent) in
                CDPrintManager.log("文件重命名-原名:\(self.fileInfo.fileName),新名:\(newContent!),folderId = \(self.fileInfo.fileId)", type: .InfoLog)
                CDSqlManager.shared.updateOneSafeFileName(fileName: newContent!, fileId: self.fileInfo.fileId)
                self.fileInfo.fileName = newContent!
                CDHUDManager.shared.showComplete(text: "重命名成功")
                self.reloadData()
                
            }
            self.navigationController?.pushViewController(markVC, animated: true)

        }else if title == "备注"{
            let markVC = CDMarkFileViewController()
            markVC.title = "备注"
            markVC.maxTextCount = 140
            markVC.markType = .fileMark
            markVC.oldContent = fileInfo.markInfo
            markVC.markHandle = {[](newContent) in
                CDPrintManager.log("文件修改备注-原备注:\(self.fileInfo.markInfo),新备注:\(newContent!),fileId = \(self.fileInfo.fileId)", type: .InfoLog)
                CDSqlManager.shared.updateOneSafeFileMarkInfo(markInfo: newContent!, fileId: self.fileInfo.fileId)
                self.fileInfo.markInfo = newContent!
                CDHUDManager.shared.showComplete(text: "重命名成功")
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
