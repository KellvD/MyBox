//
//  CDSafeViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDSafeViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource,CDPopMenuViewDelegate {
    

    var tableView:UITableView!
    var folderArr:[Array<CDSafeFolder>] = Array()

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        folderArr = CDSqlManager.shared.queryDefaultAllFolder()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hiddBackbutton()
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width:CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        tableView.register(CDFolderTableViewCell.self, forCellReuseIdentifier: "safeCellIdentifier")

        let addFolderBtn = UIButton(type: .contactAdd)
        addFolderBtn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        addFolderBtn.addTarget(self, action: #selector(addfFolderClick), for: .touchUpInside)
        addFolderBtn.tintColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addFolderBtn);
  
//        let pwdFlag = CDConfigFile.getIntValueFromConfigWith(key: .initPwd);
//        if pwdFlag == NotInitPwd{
//
//            let alert = UIAlertController(title: LocalizedString("prompt"), message: LocalizedString("To protect the security of the files in the app, please set a password to open the app"), preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: LocalizedString("Set up now"), style: .default, handler: {[unowned self] (action) in
//                let setPwdVC = CDSetPwdViewController()
//                setPwdVC.isFake = false
//                setPwdVC.isModify = !CDSignalTon.shared.basePwd.isEmpty
//                setPwdVC.title = LocalizedString("Set password")
//                setPwdVC.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(setPwdVC, animated: true)
//                CDConfigFile.setIntValueToConfigWith(key: .initPwd, intValue: DelayInitPwd);
//            }))
//            alert.addAction(UIAlertAction(title: LocalizedString("Set Up Later"), style: .cancel, handler: { (action) in
//                CDConfigFile.setIntValueToConfigWith(key: .initPwd, intValue: DelayInitPwd);
//            }))
//            
//            self.present(alert, animated: true, completion: nil)
//        }
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
        return SECTION_SPACE
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
        let cellId = "safeCellIdentifier"
        var cell:CDFolderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as?CDFolderTableViewCell

        if cell == nil {
            cell = CDFolderTableViewCell(style: .value1, reuseIdentifier: cellId)
        }
        let folder:CDSafeFolder = folderArr[indexPath.section][indexPath.row]
        cell.configDataWith(folderInfo: folder)

        cell.separatorLineIsHidden = indexPath.row == folderArr[indexPath.section].count - 1
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let folderInfo:CDSafeFolder = self.folderArr[indexPath.section][indexPath.row]
        if (folderInfo.folderType == .ImageFolder){
            let imageVC = CDImageViewController()
            imageVC.folderInfo = folderInfo
            imageVC.title = LocalizedString("Photo")
            imageVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(imageVC, animated: true)

        }else if (folderInfo.folderType == .AudioFolder){
            let audioVC = CDAudioViewController()
            audioVC.title = LocalizedString("Audio")
            audioVC.gFolderInfo = folderInfo
            audioVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(audioVC, animated: true)
        }else if (folderInfo.folderType == .VideoFolder){
            let videoVC = CDVideoViewController()
            videoVC.folderInfo = folderInfo
            videoVC.title = LocalizedString("Video")
            videoVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(videoVC, animated: true)
        }else if (folderInfo.folderType == .TextFolder){
            let textVC = CDTextViewController()
            textVC.gFolderInfo = folderInfo
            textVC.title = LocalizedString("Text")
            textVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(textVC, animated: true)
        }

    }
    
    @available(iOS, introduced: 8.0, deprecated: 13.0)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let folderInfo:CDSafeFolder = self.folderArr[indexPath.section][indexPath.row]
        let detail = UITableViewRowAction(style: .normal, title: LocalizedString("Details")) { (action, index) in
            let folderDVC = CDFolderDetailViewController()
            folderDVC.folderInfo = folderInfo
            folderDVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(folderDVC, animated: true)
        }
        detail.backgroundColor = UIColor.blue
        if folderInfo.isLock == LockOn  {
            let delete = UITableViewRowAction(style: .normal, title: LocalizedString(LocalizedString("delete"))) { (action, index) in
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
        let detail = UIContextualAction(style: .normal, title: LocalizedString("Details")) { (action, view, handle) in
            let folderDVC = CDFolderDetailViewController()
            folderDVC.folderInfo = folderInfo
            folderDVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(folderDVC, animated: true)
        }
        detail.image = UIImage(named: "fileDetail")
        if folderInfo.isLock == LockOn  {
            let delete = UIContextualAction(style: .normal, title: LocalizedString(LocalizedString("delete"))) { (action, view, handle) in
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
        let setVC = CDMineViewController()
        setVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(setVC, animated: true)
    }
    
    @objc func addfFolderClick()->Void{
        let newVC = CDNewFolderViewController()
        newVC.hidesBottomBarWhenPushed  = true
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    //MARK:
    func onSelectedPopMenu(title: String) {
        if title == "新建文件夹" {
            let newVC = CDNewFolderViewController()
            newVC.hidesBottomBarWhenPushed  = true
            self.navigationController?.pushViewController(newVC, animated: true)
        } else if title == "扫一扫" {
            let camera = CDCameraViewController()
            camera.isVideo = false
            camera.modalPresentationStyle = .fullScreen
            CDSignalTon.shared.customPickerView = camera
            self.present(camera, animated: true, completion: nil)
        } else if title == "电子书" {
           let setVC = CDMineViewController()
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
