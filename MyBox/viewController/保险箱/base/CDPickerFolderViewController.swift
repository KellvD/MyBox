//
//  CDPickerFolderViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/11.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

extension CDPickerFolderViewController {
    public typealias CDMoveFilesHandle = (_ success:Bool) -> Void
}
class CDPickerFolderViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {
    public var moveHandle:CDPickerFolderViewController.CDMoveFilesHandle?
    public var folderId:Int = 0
    public var folderType:NSFolderType!
    public var selectedArr:[CDSafeFileInfo]!
    public var isShare = false
    private var tableView:UITableView!
    private var folderArr:[Array<CDSafeFolder>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "文件夹列表".localize
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.register(CDFolderTableViewCell.self, forCellReuseIdentifier: "folderList")
        
        let cancleBtn = UIButton(type: .custom)
        cancleBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        cancleBtn.setTitle("取消".localize, for: .normal)
        cancleBtn.addTarget(self, action: #selector(cancleShareClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancleBtn)
        cancleBtn.isHidden = !isShare
        
        if isShare {
            hiddBackbutton()
            folderArr = CDSqlManager.shared.queryAllOtherFolderWith(folderType: folderType)
        }else{
            folderArr = CDSqlManager.shared.queryAllOtherFolderWith(folderType: folderType, folderId: folderId)
        }
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
        return nil

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderArr[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "folderList"
        var cell:CDFolderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as?CDFolderTableViewCell

        if cell == nil {
            cell = CDFolderTableViewCell(style: .value1, reuseIdentifier: cellId)
        }
        let folder:CDSafeFolder = self.folderArr[indexPath.section][indexPath.row]
        cell.configDataWith(folderInfo: folder)

        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let folder:CDSafeFolder = self.folderArr[indexPath.section][indexPath.row]
        if isShare {
            onDoneShare(folder: folder)
        }else{
            onDoneMove(folder: folder)
        }
    }
    
    private func onDoneShare(folder:CDSafeFolder){
        let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.boxdemo")
        let fileUrl = groupUrl!.appendingPathComponent("shareContent.txt")
        let content = try? String(contentsOf: fileUrl,encoding: .utf8)
        if CDSignalTon.shared.shareType == "public.movie" {
            let moveName = content!
            let desPath = "\(groupUrl!.path)/\(moveName)"
            CDSignalTon.shared.saveFileWithUrl(fileUrl: URL(fileURLWithPath: desPath), folderId: folder.folderId, subFolderType: folder.folderType, isFromDocment: false)
        }else if CDSignalTon.shared.shareType == "public.image" {
            DispatchQueue.main.async {
                CDHUDManager.shared.showProgress("开始导入".localize)
                let imageNameStr = content!
                let imageNameArr = imageNameStr.components(separatedBy: ",")
                for index in 0..<imageNameArr.count {
                    let iamgeName = imageNameArr[index]
                    let desPath = "\(groupUrl!.path)/\(iamgeName)"
                    CDHUDManager.shared.updateProgress(num: Float(index)/Float(imageNameArr.count), text: "\(index)/\(imageNameArr.count)")
                    CDSignalTon.shared.saveFileWithUrl(fileUrl: URL(fileURLWithPath: desPath), folderId: folder.folderId, subFolderType: folder.folderType, isFromDocment: false)
                    print(index)
                }
                
                CDHUDManager.shared.hideProgress()
            }
            
            
        }else if CDSignalTon.shared.shareType == "public.url" {
            var urlTile = content!
            var urlStr = content!
            if content!.contains("|--myBox--|") {
                let urArr = content!.components(separatedBy: "|--myBox--|")
                urlTile = urArr.last!
                urlStr = urArr.first!
            }
            CDSignalTon.shared.saveUrl(url: urlStr, title: urlTile, folderId: folder.folderId)
        }else if CDSignalTon.shared.shareType == "public.file-url" {
            let fileName = content!
            let desPath = "\(groupUrl!.path)/\(fileName)"
            CDSignalTon.shared.saveFileWithUrl(fileUrl: URL(fileURLWithPath: desPath), folderId: folder.folderId, subFolderType: folder.folderType, isFromDocment: false)
        }else if CDSignalTon.shared.shareType == "public.plain-text" {
            let plainText = content!
            CDSignalTon.shared.savePlainText(content: plainText, folderId: folder.folderId)

        }
        
        shareDonePushViewController(folder: folder)
        
        
    }
    
    private func shareDonePushViewController(folder:CDSafeFolder){
        let appDelegate = UIApplication.shared.delegate as! CDAppDelegate
        let rootVC = CDTabBarViewController()
        appDelegate.window?.rootViewController = rootVC
        let navVC = rootVC.viewControllers?.first as! CDNavigationController
        
        if CDSignalTon.shared.shareType == "public.movie" {
            let videoVC = CDVideoViewController()
            videoVC.folderInfo = folder
            videoVC.title = "视频文件".localize
            videoVC.hidesBottomBarWhenPushed = true
            navVC.pushViewController(videoVC, animated: true)
            
        }else if CDSignalTon.shared.shareType == "public.image" {
            let imageVC = CDImageViewController()
            imageVC.folderInfo = folder
            imageVC.title = "图片文件".localize
            imageVC.hidesBottomBarWhenPushed = true
            navVC.pushViewController(imageVC, animated: true)
        }else if CDSignalTon.shared.shareType == "public.url" ||
                    CDSignalTon.shared.shareType == "public.file-url" ||
                    CDSignalTon.shared.shareType == "public.plain-text"{
            
            let vc =  CDTextViewController()
            vc.title = "文本文件".localize
            vc.folderInfo = folder
            vc.hidesBottomBarWhenPushed = true
            navVC.pushViewController(vc, animated: true)
        }
        
        CDHUDManager.shared.showComplete("分享完成".localize)
    }
    
    @objc private func cancleShareClick(){
        let appDelegate = UIApplication.shared.delegate as! CDAppDelegate
        let rootVC = CDTabBarViewController()
        appDelegate.window?.rootViewController = rootVC
    }
    
    private func onDoneMove(folder:CDSafeFolder){
        let alert = UIAlertController(title: "提示", message: "您确定移入该文件夹吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: { (action) in}))
        alert.addAction(UIAlertAction(title: "确定".localize, style: .default, handler: { (action) in
            CDHUDManager.shared.showWait("正在处理中...".localize)
            DispatchQueue.global().async {
                if folder.folderId > 0 && self.selectedArr.count > 0 {
                    for index in 0..<self.selectedArr.count{
                        let file = self.selectedArr[index]
                        file.folderId = folder.folderId
                        CDSqlManager.shared.updateOneSafeFileFolder(fileInfo: file)
                    }
                    DispatchQueue.main.async {
                        CDHUDManager.shared.hideWait()
                        CDHUDManager.shared.showText("移入完成".localize)
                        self.moveHandle!(true)
                        self.navigationController?.popViewController(animated: true)
                    }
                }else{
                    CDHUDManager.shared.hideWait()
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
