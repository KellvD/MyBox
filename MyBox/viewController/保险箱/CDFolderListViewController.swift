//
//  CDFolderListViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/11.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDFolderListViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {



    var folderId:Int = 0
    var folderType:NSFolderType!
    var selectedArr:[CDSafeFileInfo]!
    var tableView:UITableView!
    var folderArr:[Array<CDSafeFolder>] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.register(CDSafeFolderCell.self, forCellReuseIdentifier: "folderList")

        folderArr = CDSqlManager.instance().queryAllOtherFolderWith(folderType: folderType, folderId: folderId)


    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return folderArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view

    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderArr[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "folderList"
        var cell:CDSafeFolderCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as?CDSafeFolderCell

        if cell == nil {
            cell = CDSafeFolderCell(style: .value1, reuseIdentifier: cellId)
        }
        let folder:CDSafeFolder = self.folderArr[indexPath.section][indexPath.row]
        cell.configDataWith(folderInfo: folder)

        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folder:CDSafeFolder = self.folderArr[indexPath.section][indexPath.row]
        let alert = UIAlertController(title: "提示", message: "您确定移入该文件夹吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in

        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            CDHUD.showLoading(text: "正在处理")
            DispatchQueue.global().async {
                if folder.folderId > 0 && self.selectedArr.count > 0 {
                    for index in 0..<self.selectedArr.count{
                        let file = self.selectedArr[index]
                        file.folderId = folder.folderId
                        CDSqlManager.instance().updateOneSafeFileForMove(fileInfo: file)


                    }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NeedReloadData, object: nil)
                        CDHUD.hide()
                        CDHUD.showText(text: "移入成功")
                        self.navigationController?.popViewController(animated: true)

                    }
                }else{
                    CDHUD.hide()
                    self.navigationController?.popViewController(animated: true)
                }
            }

        }))

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
