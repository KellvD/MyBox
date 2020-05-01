//
//  CDFileDetailViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/20.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDFileDetailViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource,CDMarkFileDelegate {

    var tableView:UITableView!
    var fileInfo:CDSafeFileInfo!
    var fileNameFiled:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableView.delegate = self;
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return 2
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2{
            if fileInfo.fileType == NSFileType.ImageType ||
            fileInfo.fileType == NSFileType.GifType ||
            fileInfo.fileType == NSFileType.AudioType ||
            fileInfo.fileType == NSFileType.VideoType {
                return 48.0
            }else{
                return 0.0
            }
        }
        return 48
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2{
            if fileInfo.fileType == NSFileType.ImageType ||
            fileInfo.fileType == NSFileType.GifType ||
            fileInfo.fileType == NSFileType.AudioType ||
            fileInfo.fileType == NSFileType.VideoType {
                return 15.0
            }else{
                return 0.0
            }
        }
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
        let titleL = cell.contentView.viewWithTag(101) as! UILabel
        let detaileL = cell.contentView.viewWithTag(102) as! UILabel
        if indexPath.section == 0 {
            titleL.text = "名称"
            detaileL.text = fileInfo.fileName
        }else if indexPath.section == 1 {
            if indexPath.row == 0{
                titleL.text = "创建时间"
                detaileL.text = timestampTurnString(timestamp: fileInfo.createTime)
            }else{
                titleL.text = "大小"
                detaileL.text = returnSize(fileSize: fileInfo.fileSize)
            }
        }else if indexPath.section == 2 {
            cell.isHidden = false
            if fileInfo.fileType == NSFileType.ImageType ||
                fileInfo.fileType == NSFileType.GifType {
                titleL.text = "尺寸"
                detaileL.text = "\(fileInfo.fileWidth) x \(fileInfo.fileHeight)"
            }else if fileInfo.fileType == NSFileType.AudioType ||
                    fileInfo.fileType == NSFileType.VideoType{
                titleL.text = "时长"
                let timeLength = getMMSSFromSS(second: fileInfo.timeLength)
                detaileL.text = timeLength
            }else{
                cell.isHidden = true
            }

        }else if indexPath.section == 3 {
            titleL.text = "备注"
            detaileL.text = fileInfo.markInfo
        }
        return cell

    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let markVC = CDMarkFileViewController()
            markVC.title = "重命名"
            markVC.maxTextCount = 60
            markVC.fileId = fileInfo.fileId
            markVC.delegate = self
            markVC.markInfo = fileInfo.fileName
            markVC.markType = .fileName

            self.navigationController?.pushViewController(markVC, animated: true)

        }else if indexPath.section == 3{
            let markVC = CDMarkFileViewController()
            markVC.title = "备注"
            markVC.maxTextCount = 140
            markVC.fileId = fileInfo.fileId
            markVC.delegate = self
            markVC.markInfo = fileInfo.markInfo
            markVC.markType = .fileMark
            self.navigationController?.pushViewController(markVC, animated: true)

        }
    }
    func onMarkFileSuccess() {
        fileInfo = CDSqlManager.instance().queryOneSafeFileWithFileId(fileId: fileInfo.fileId)
        tableView.reloadData()
    }
}
