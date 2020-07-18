//
//  CDSafeViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDSafeViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource,CDCreateFolderDelegate,CDPopMenuViewDelegate {

    var tableView:UITableView!
    var folderArr:[Array<CDSafeFolder>] = Array()

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        if JudgeStringIsEmpty(string: CDSignalTon.shared.basePwd){
//
//            let setPwdVC = CDSetPwdViewController()
//            setPwdVC.isFake = false
//            setPwdVC.isModify = !JudgeStringIsEmpty(string: CDSignalTon.shared.basePwd)
//            setPwdVC.title = "设置密码"
//            self.navigationController?.pushViewController(setPwdVC, animated: true)
//        }
        folderArr = CDSqlManager.shared.queryDefaultAllFolder()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        self.title = "保险箱"
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width:CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = SeparatorGrayColor
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        tableView.register(CDSafeFolderCell.self, forCellReuseIdentifier: "safeCellIdentifier")
        
        
//        let setBtn = UIButton(type: .custom)
//        setBtn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
//        setBtn.setImage(UIImage(named: "vault_setting"), for: .normal)
//        setBtn.addTarget(self, action: #selector(setBtnClick), for: .touchUpInside)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:(setBtn))
//        setBtn.isHidden = CDSignalTon.shared.loginType == .fake
        //
        let addFolderBtn = UIButton(type: .custom)
        addFolderBtn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        addFolderBtn.setTitle("新建", for: .normal)
        addFolderBtn.addTarget(self, action: #selector(addfFolderClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addFolderBtn);
  
    }

    lazy var popView: CDPopMenuView = {
        let titleArr = ["新建文件夹","扫一扫","电子书"]
        let popView = CDPopMenuView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), imageArr: titleArr, titleArr: titleArr, orientation: CDOrientation.rightUp)
        popView.popDelegate = self
        self.view.addSubview(popView)
        return popView
    }()
    
    lazy var sideVC: CDSideViewController = {
        let sideVC = CDSideViewController()
        return sideVC
    }()
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
        let cellId = "safeCellIdentifier"
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
        let folderInfo:CDSafeFolder = self.folderArr[indexPath.section][indexPath.row]
        if (folderInfo.folderType == .ImageFolder){
            let imageVC = CDImageViewController()
            imageVC.folderInfo = folderInfo
            imageVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(imageVC, animated: true)

        }else if (folderInfo.folderType == .AudioFolder){
            let audioVC = CDAudioViewController()

            audioVC.gFolderInfo = folderInfo
            audioVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(audioVC, animated: true)
        }else if (folderInfo.folderType == .VideoFolder){
            let videoVC = CDVideoViewController()
            videoVC.folderInfo = folderInfo
            videoVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(videoVC, animated: true)
        }else if (folderInfo.folderType == .TextFolder){
            let textVC = CDTextViewController()
            textVC.gFolderInfo = folderInfo
            textVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(textVC, animated: true)
        }

    }
    @available(iOS, introduced: 8.0, deprecated: 13.0)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let folderInfo:CDSafeFolder = self.folderArr[indexPath.section][indexPath.row]
        let detail = UITableViewRowAction(style: .normal, title: "详情") { (action, index) in
            
            let folderDVC = CDFolderDetailViewController()
            folderDVC.folderInfo = folderInfo
            folderDVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(folderDVC, animated: true)
        }
        detail.backgroundColor = UIColor.blue
        if folderInfo.isLock == LockOn  {
            let delete = UITableViewRowAction(style: .normal, title: "删除") { (action, index) in
                CDSqlManager.shared.deleteOneFolder(folderId: folderInfo.folderId)
                self.folderArr = CDSqlManager.shared.queryDefaultAllFolder()
                tableView.reloadData()
            }
            delete.backgroundColor = UIColor.red
            return [detail,delete]
        }else{
            return [detail]
        }
        
    }
    @available(iOS 11, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let folderInfo:CDSafeFolder = self.folderArr[indexPath.section][indexPath.row]
        let detail = UIContextualAction(style: .normal, title: "详情") { (action, view, handle) in
            let folderDVC = CDFolderDetailViewController()
            folderDVC.folderInfo = folderInfo
            folderDVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(folderDVC, animated: true)
        }
        detail.image = UIImage(named: "fileDetail")
        if folderInfo.isLock == LockOn  {
            let delete = UIContextualAction(style: .normal, title: "删除") { (action, view, handle) in
                CDSqlManager.shared.deleteOneFolder(folderId: folderInfo.folderId)
                self.folderArr = CDSqlManager.shared.queryDefaultAllFolder()
                tableView.reloadData()
            }
            delete.backgroundColor = .red
            let action = UISwipeActionsConfiguration(actions: [delete,detail])
            return action
        }else{
            let action = UISwipeActionsConfiguration(actions: [detail])
            return action
        }
    }
    @objc func setBtnClick()->Void{
        let setVC = CDSettingViewController()
        setVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(setVC, animated: true)

    }
    @objc func addfFolderClick()->Void{
    
        popView.showPopView()
    }

    func createNewFolderSuccess() {
        
    }
    
    //MARK:
    func onSelectedPopMenu(title: String) {
        if title == "新建文件夹" {
            let newVC = CDNewFolderViewController()
            newVC.Cdelete = self
            newVC.hidesBottomBarWhenPushed  = true
            self.navigationController?.pushViewController(newVC, animated: true)
        } else if title == "扫一扫" {
            let camera = CDCameraViewController()
            camera.isVideo = false
            camera.modalPresentationStyle = .fullScreen
            CDSignalTon.shared.customPickerView = camera
            self.present(camera, animated: true, completion: nil)
        } else if title == "电子书" {
           let setVC = CDSettingViewController()
            setVC.hidesBottomBarWhenPushed  = true
           self.navigationController?.pushViewController(setVC, animated: true)
        }
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
