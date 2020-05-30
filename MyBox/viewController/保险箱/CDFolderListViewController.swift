//
//  CDFolderListViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/11.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

extension CDFolderListViewController {
    public typealias CDMoveFilesHandle = (_ success:Bool) -> Void
}
class CDFolderListViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {
    public var moveHandle:CDFolderListViewController.CDMoveFilesHandle?
    public var folderId:Int = 0
    public var folderType:NSFolderType!
    public var selectedArr:[CDSafeFileInfo]!
    
    private var tableView:UITableView!
    private var folderArr:[Array<CDSafeFolder>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "文件夹列表"
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
        return 65.0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
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
        view.backgroundColor = UIColor.red
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
        tableView.deselectRow(at: indexPath, animated: true)
        let folder:CDSafeFolder = self.folderArr[indexPath.section][indexPath.row]
        let alert = UIAlertController(title: "提示", message: "您确定移入该文件夹吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in}))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            CDHUDManager.shareInstance().showWait(text: "正在处理")
            DispatchQueue.global().async {
                if folder.folderId > 0 && self.selectedArr.count > 0 {
                    for index in 0..<self.selectedArr.count{
                        let file = self.selectedArr[index]
                        file.folderId = folder.folderId
                        CDSqlManager.instance().updateOneSafeFileForMove(fileInfo: file)
                    }
                    DispatchQueue.main.async {
                        CDHUDManager.shareInstance().hideWait()
                        CDHUDManager.shareInstance().showText(text: "移入成功")
                        self.moveHandle!(true)
                        self.navigationController?.popViewController(animated: true)

                    }
                }else{
                    CDHUDManager.shareInstance().hideWait()
                    self.navigationController?.popViewController(animated: true)
                }
            }

        }))
        present(alert, animated: true, completion: nil)
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
