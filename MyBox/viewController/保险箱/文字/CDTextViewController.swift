//
//  CDTextViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/28.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import AVFoundation
class CDTextViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate,CDDirNavBarDelegate {
    private
    var tableblew:UITableView!
    var selectBtn:UIButton!
    var backBtn:UIButton!
    var toolbar:CDToolBar!
    var dirNavBar:CDDirNavBar!
    var textTD:(foldersArr:[CDSafeFolder],filesArr:[CDSafeFileInfo])!
    var isEditSelected = Bool()
    var selectFileCount:Int = 0
    var selectFolderCount:Int = 0
    var selectedFileArr:[CDSafeFileInfo] = []
    var selectedFolderArr:[CDSafeFolder] = []
    var isNeedReloadData:Bool = false
    var currentFolderId:Int!
    public
    var folderInfo:CDSafeFolder!
    
    deinit {
        removeNotification()
    }
    override func viewWillAppear(_ animated: Bool) {
        if isNeedReloadData {
            isNeedReloadData = false
            refreshData(superId: folderInfo.folderId)
            CDSignalTon.shareInstance().dirNavArr.removeAllObjects()//进入文本文件
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "文本文件"
        isNeedReloadData = true
        
        dirNavBar = CDDirNavBar(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 48))
        dirNavBar.dirDelegate = self
        view.addSubview(dirNavBar)
        
        tableblew = UITableView(frame: CGRect(x: 0, y: dirNavBar.frame.maxY, width: CDSCREEN_WIDTH, height: CDViewHeight - 48 - dirNavBar.frame.height), style: .plain)
        tableblew.delegate = self
        tableblew.dataSource = self
        tableblew.separatorStyle = .none
        self.view.addSubview(tableblew)
        tableblew.register(CDTableViewCell.self, forCellReuseIdentifier: "textCellId")
        
        self.selectBtn = UIButton(type: .custom)
        self.selectBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        self.selectBtn.setImage(UIImage(named: "edit"), for: .normal);
        self.selectBtn.addTarget(self, action: #selector(multisSelectBtnClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.selectBtn!)
        
        self.backBtn = UIButton(type: .custom)
        self.backBtn.frame = CGRect(x: 0, y: 0, width: 80, height: 45)
        self.backBtn.setTitle("返回", for: .normal)
        self.backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backBtn!)
        
        self.toolbar = CDToolBar(frame: CGRect(x: 0, y: CDViewHeight-48, width: CDSCREEN_WIDTH, height: 48), foldertype: .TextFolder, superVC: self)
        self.view.addSubview(self.toolbar)
        hiddenDirNavBar()
        registerNotification()
        
        
        
    }
    
    
    func refreshData(superId:Int) {
        selectedFileArr.removeAll()
        selectedFolderArr.removeAll()
        toolbar.enableReloadBar(isSelected: false)
        textTD = CDSqlManager.instance().queryAllContentFromFolder(folderId: superId)
        currentFolderId = folderInfo.folderId;
        tableblew.reloadData()
    }
    
    func handelSelectedArr(){
        selectedFileArr.removeAll()
        selectedFolderArr.removeAll()
        
        textTD.filesArr.forEach { (tmpFile) in
            if tmpFile.isSelected == .CDTrue {
                selectedFileArr.append(tmpFile)
            }
        }
        textTD.foldersArr.forEach { (tmpFolder) in
            if tmpFolder.isSelected == .CDTrue {
                selectedFolderArr.append(tmpFolder)
            }
        }
    }
    //多选
    @objc func multisSelectBtnClick() -> Void {
        self.selectBtn.isSelected = !(self.selectBtn.isSelected)
        if (self.selectBtn.isSelected) { //点了选择操作
            //1.返回变全选
            self.backBtn.setTitle("全选", for: .normal)
            self.selectBtn.setImage(UIImage(named: "no_edit"), for: .normal)
            //2.拍照，导入变成操作按钮
            toolbar.hiddenReloadBar(isMulit: true)
            isEditSelected = true
            
        }else{
            //1.返回变全选
            self.backBtn.setTitle("返回", for: .normal)
            self.selectBtn.setImage(UIImage(named: "edit"), for: .normal)
            toolbar.hiddenReloadBar(isMulit: false)
            isEditSelected = false
        }
        tableblew.reloadData()
    }
    
    //返回
    @objc func backBtnClick() -> Void {
        if isEditSelected { //
            if (self.backBtn.isSelected) { //全选
                self.backBtn.setTitle("全不选", for: .normal)
            }else{
                self.backBtn.setTitle("全选", for: .normal)
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    //选择文件夹目录
    func onSelectedDirWithFolderId(folderId: Int) {
        if folderId == folderInfo.folderId { //根目录
            hiddenDirNavBar()
        }
        refreshData(superId: folderId)
    }
    
    func hiddenDirNavBar(){
        UIView.animate(withDuration: 0.5, animations: {
            var frame = self.tableblew.frame
            if frame.origin.y > 0.0{
                frame.origin.y = 0.0
                frame.size.height += 48.0
                self.tableblew.frame = frame
            }
        }) { (flag) in
            self.dirNavBar.isHidden = true
            CDSignalTon.shareInstance().dirNavArr.removeAllObjects()
        }
    }
    func showDirNavBar(){
        UIView.animate(withDuration: 0.25) {
            self.dirNavBar.isHidden = false
            var frame = self.tableblew.frame
            if frame.origin.y == CGFloat(0.0){
                frame.origin.y = 48.0
                frame.size.height -= 48.0
                self.tableblew.frame = frame
            }
        }
    }
    //TODO:分享事件
    @objc func shareBarItemClick(){
        handelSelectedArr()
        if selectedFolderArr.count > 0 {
            CDHUDManager.shareInstance().showText(text: "文件夹不支持分享")
            return
        }
        if selectedFileArr.count <= 0 {
            return
        }
        
    }
    @objc func moveBarItemClick(){
        isNeedReloadData = false
        handelSelectedArr()
        if selectedFolderArr.count > 0 {
            CDHUDManager.shareInstance().showText(text: "文件夹不支持移动")
            return
        }
        if selectedFileArr.count <= 0 {
            return
        }
        let folderList = CDFolderListViewController()
        folderList.title = "文件夹列表"
        folderList.selectedArr = selectedFileArr
        folderList.folderType = .TextFolder
        folderList.folderId = folderInfo.folderId
        self.navigationController?.pushViewController(folderList, animated: true)
    }
    @objc func outputBarItemClick(){
        handelSelectedArr()
        let fileInfo = self.selectedFileArr[0]
        let filePath = String.libraryUserdataPath().appendingPathComponent(str: fileInfo.filePath)
        let vc = UIDocumentInteractionController(url: URL(fileURLWithPath: filePath))
        //       vc.delegate = self
        //        vc.presentPreview(animated: true)
        vc.presentOpenInMenu(from: CGRect(x: 0, y: 100, width: 300, height: 130), in: self.view, animated: true)
    }
    //删除
    @objc func deleteBarItemClick(){
        handelSelectedArr()
        var btnTitle = String()
        isNeedReloadData = false
        let total = selectedFileArr.count + selectedFolderArr.count
        if total <= 0{
            return
        }else if total > 1{
            btnTitle = "删除\(total)个文件"
        }else{
            btnTitle = "删除文件"
        }
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: btnTitle, style: .destructive, handler: { (action) in
            DispatchQueue.main.async {
                CDHUDManager.shareInstance().showWait(text: "删除中...")
            }
            
            DispatchQueue.global().async {
                for index in 0..<self.selectedFileArr.count{
                    let fileInfo = self.selectedFileArr[index]
                    let filePath = String.libraryUserdataPath().appendingPathComponent(str: fileInfo.filePath)
                    
                    try! FileManager.default.removeItem(atPath: filePath)
                    CDSqlManager.instance().deleteOneSafeFile(fileId: fileInfo.fileId)
                    
                }
                for index in 0..<self.selectedFolderArr.count{
                    let folderInfo = self.selectedFolderArr[index]
                    /*
                     文件夹中文件filePath：other/xxx/xxx/xxx，不能取最后部分拼接在other上
                     */
                    let folderPath = String.libraryUserdataPath().appendingPathComponent(str: folderInfo.folderPath)
                    try! FileManager.default.removeItem(atPath: folderPath)
                    //删除数据库中数据，逐级删除文件
                    func deleteAllSubContent(subFolderId:Int){
                        //删除一级目录
                        CDSqlManager.instance().deleteOneFolder(folderId: subFolderId)
                        //删除目录下子文件
                        CDSqlManager.instance().deleteAllSubSafeFile(folderId: subFolderId)
                        
                        let subAllFolders = CDSqlManager.instance().querySubAllFolderId(folderId: subFolderId)
                        for folderId in subAllFolders {
                            deleteAllSubContent(subFolderId: folderId)
                        }
                    }
                    deleteAllSubContent(subFolderId: folderInfo.folderId)
                }
                DispatchQueue.main.async {
                    self.refreshData(superId: self.currentFolderId)
                    self.multisSelectBtnClick()
                    CDHUDManager.shareInstance().hideWait()
                    CDHUDManager.shareInstance().showText(text: "文件删除完成")
                }
            }
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(sheet, animated: true, completion: nil)
    }
    
    
    
    //TODO:
    @objc func documentItemClick(){
        //查询地址：https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259
        let documentTypes = ["public.text","com.adobe.pdf","com.microsoft.word.doc","com.microsoft.excel.xls","com.microsoft.powerpoint.ppt","public.archive"]
        super.subFolderId = folderInfo.folderId
        super.subFolderType = folderInfo.folderType
        self.isNeedReloadData = true
//        super.processHandle
        presentDocumentPicker(documentTypes: documentTypes)
    }
    @objc func addItemClick(){
        let textVC = CDNewTextViewController()
        textVC.folderId = folderInfo.folderId
        self.navigationController?.pushViewController(textVC, animated: true)
        
    }
    //TODO:UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        }else{
            if textTD.filesArr.count == 0 || textTD.foldersArr.count == 0 {
                return 0.01
            }else{
                return 15
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = SeparatorGrayColor
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return textTD.foldersArr.count
        }else{
            return textTD.filesArr.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "textCellId"
        var cell:CDTableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? CDTableViewCell
        if cell == nil {
            cell = CDTableViewCell(style: .default, reuseIdentifier: cellId)
        }
        
        if selectBtn.isSelected {
            cell.showSelectIcon = true
            tableView.isScrollEnabled = true
            var selectState:CDSelectedStatus!
            if indexPath.section == 0 {
                let folder:CDSafeFolder = textTD.foldersArr[indexPath.row]
                selectState = folder.isSelected
            }else{
                let fileInfo:CDSafeFileInfo = textTD.filesArr[indexPath.row]
                selectState = fileInfo.isSelected
            }
            
            if selectState == .CDTrue {
                cell.isSelect = true
            }else{
                cell.isSelect = false
            }
        }else{
            cell.showSelectIcon = false
            tableView.isScrollEnabled = true
        }
        if indexPath.section == 0 {
            let folder:CDSafeFolder = textTD.foldersArr[indexPath.row]
            cell.setConfigFolderData(folder: folder)
        }else{
            let fileInfo:CDSafeFileInfo = textTD.filesArr[indexPath.row]
            cell.setConfigFileData(fileInfo: fileInfo)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectBtn.isSelected{
            if indexPath.section == 0 {
                let folder:CDSafeFolder = textTD.foldersArr[indexPath.row]
                if folder.isSelected == .CDTrue {
                    selectFolderCount -= 1
                    folder.isSelected = .CDFalse
                }else{
                    selectFolderCount += 1
                    folder.isSelected = .CDTrue
                }
            }else{
                let fileInfo:CDSafeFileInfo = textTD.filesArr[indexPath.row]
                if fileInfo.isSelected == .CDTrue {
                    selectFolderCount -= 1
                    fileInfo.isSelected = .CDFalse
                }else{
                    selectFileCount += 1
                    fileInfo.isSelected = .CDTrue
                }
            }
            
            if selectFileCount + selectFolderCount > 0 {
                //                toolbar.deleteItem.tintColor = CustomPinkColor
                toolbar.enableReloadBar(isSelected: true)
                if selectFolderCount >= 1 {
                    toolbar.moveItem.isEnabled = false
                    toolbar.outputItem.isEnabled = false
                }else{
                    toolbar.moveItem.isEnabled = true
                    toolbar.outputItem.isEnabled = true
                }
            }else{
                toolbar.enableReloadBar(isSelected: false)
            }
            if selectFileCount == textTD.filesArr.count &&
                selectFolderCount == textTD.foldersArr.count {
                backBtn.setTitle("全不选", for: .normal)
            }else{
                backBtn.setTitle("全选", for: .normal)
            }
            tableblew.reloadData()
        }else{
            if indexPath.section == 0 {
                if CDSignalTon.shareInstance().dirNavArr.count == 0 {
                    CDSignalTon.shareInstance().dirNavArr.add(folderInfo!)
                }
                let folder:CDSafeFolder = textTD.foldersArr[indexPath.row]
                CDSignalTon.shareInstance().dirNavArr.add(folder)
                dirNavBar.reloadBarData()
                showDirNavBar()
                refreshData(superId: folder.folderId)
                currentFolderId = folder.folderId
            }else{
                let fileInfo:CDSafeFileInfo = textTD.filesArr[indexPath.row]
                if fileInfo.fileType == .PlainTextType{
                    let messageWindow = CDTextMessageViewController()
                    messageWindow.fileInfo = fileInfo
                    self.navigationController?.pushViewController(messageWindow, animated: true)
                } else if (fileInfo.fileType == .ZipType){
                    unArchiveZip(fileInfo: fileInfo)
                    
                } else{
                    let filePath = String.libraryUserdataPath().appendingPathComponent(str: fileInfo.filePath)
                    let url = URL(fileURLWithPath: filePath)
                    let documentVC = UIDocumentInteractionController(url: url)
                    documentVC.name = fileInfo.fileName
                    documentVC.delegate = self
                    documentVC.presentPreview(animated: true)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if selectBtn.isSelected{
            if indexPath.section == 0 {
                let folder:CDSafeFolder = textTD.foldersArr[indexPath.row]
                if folder.isSelected == .CDTrue {
                    selectFolderCount -= 1
                    folder.isSelected = .CDFalse
                }else{
                    selectFolderCount += 1
                    folder.isSelected = .CDTrue
                }
            }else{
                let fileInfo:CDSafeFileInfo = textTD.filesArr[indexPath.row]
                if fileInfo.isSelected == .CDTrue {
                    selectFolderCount -= 1
                    fileInfo.isSelected = .CDFalse
                }else{
                    selectFileCount += 1
                    fileInfo.isSelected = .CDTrue
                }
            }
            if selectFileCount + selectFolderCount > 0 {
                toolbar.enableReloadBar(isSelected: true)
                if selectFolderCount >= 1 {
                    toolbar.moveItem.isEnabled = false
                    toolbar.shareItem.isEnabled = false
                }else{
                    toolbar.moveItem.isEnabled = true
                    toolbar.shareItem.isEnabled = true
                }
            }else{
                toolbar.enableReloadBar(isSelected: false)
            }
            if selectFileCount == textTD.filesArr.count &&
                selectFolderCount == textTD.foldersArr.count {
                backBtn.setTitle("全不选", for: .normal)
            }else{
                backBtn.setTitle("全选", for: .normal)
            }
        }
    }
    
    
    internal func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //        if indexPath.section == 0 {
        //            let folder:CDSafeFolder = textTD.foldersArr[indexPath.row]
        //            let detail = UIContextualAction(style: .normal, title: "详情") { (action, view, nil) in
        //                let folderDVC = CDFolderDetailViewController()
        //                folderDVC.folderInfo = folder
        //                self.navigationController?.pushViewController(folderDVC, animated: true)
        //            }
        //            detail.image = UIImage(named: "menu_delete")
        //            detail.backgroundColor = UIColor.blue
        //            return [detail]
        //        }else{
        //            let fileInfo:CDSafeFileInfo = textTD.filesArr[indexPath.row]
        //            let detail = UIContextualAction(style: .destructive, title: "") { (action, view, nil) in
        //                let fileDVC = CDFileDetailViewController()
        //                fileDVC.fileInfo = fileInfo
        //                self.navigationController?.pushViewController(fileDVC, animated: true)
        //            }
        //            detail.image = UIImage(named: "menu_delete")
        //
        //            return [detail]
        //        }
        return []
    }
    
    func unArchiveZip(fileInfo:CDSafeFileInfo){
        let zipPath = String.libraryUserdataPath().appendingPathComponent(str: fileInfo.filePath)
        //取压缩文件的目录
        var desDirPath = String.libraryUserdataPath().appendingPathComponent(str: fileInfo.filePath.stringByDeletingPathExtension())
        var isDir:ObjCBool = true
        if FileManager.default.fileExists(atPath: desDirPath, isDirectory: &isDir) {
            if isDir.boolValue {
                desDirPath = desDirPath + timestampTurnString(timestamp: getCurrentTimestamp())
            }
        }
        //获取解压文件夹中所有子文件，文件夹保存
        func getAllContentsOfDirectory(dirPath:String,superId:Int){
            //先保存文件夹，再取子文件保存，子文件夹重复操作
            saveSubFolders(path: dirPath, superId: superId) { (folderId) in
                let T = CDGeneralTool.getAllContentsOfDirectory(dirPath: dirPath)
                for fileName in T.filesArr {
                    self.saveSubFiles(path: fileName, superId: folderId)
                }
                if T.directoiesArr.count > 0 {
                    for dirName in T.directoiesArr {
                        getAllContentsOfDirectory(dirPath: dirName, superId: folderId)
                    }
                }else{
                    CDHUDManager.shareInstance().hideWait()
                    CDHUDManager.shareInstance().showText(text: "解压完成")
                    self.refreshData(superId: self.folderInfo.folderId)
                }
            }
        }
        
        //加压
        func unArchiveZipToDirectory(password:String?){
            CDHUDManager.shareInstance().showWait(text: "解压中...")
            let error = CDGeneralTool.unArchiveZipToDirectory(zip: zipPath, desDirectory: desDirPath, paaword: password)
            if error == nil {
                getAllContentsOfDirectory(dirPath: desDirPath, superId: self.currentFolderId)
            }else{
                CDHUDManager.shareInstance().hideWait()
                CDHUDManager.shareInstance().showText(text: "解压失败:" + error!.localizedDescription)
            }
        }
        
        //判断压缩包是否加密
        if  CDGeneralTool.checkPasswordIsProtectedZip(zipFile: zipPath){
            let alert = UIAlertController(title: "本压缩包为加密加锁", message: "请输入解压密码", preferredStyle: .alert)
            var tmpTextFiled:UITextField!
            alert.addTextField { (textFiled) in tmpTextFiled = textFiled }
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                let password = tmpTextFiled.text ?? fileInfo.fileName
                unArchiveZipToDirectory(password: password)
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in }))
            present(alert, animated: true, completion: nil)
        }else{
            unArchiveZipToDirectory(password: nil)
        }
    }
    
    //保存文件夹,并返回该文件夹的FolderId,作为保存子文件的folderId、文件夹的superId
    func saveSubFolders(path:String,superId:Int,Return:@escaping(_ folderId:Int) -> Void) {
        let nowTime = getCurrentTimestamp()
        let createtime:Int = nowTime;
        let folderInfo = CDSafeFolder()
        folderInfo.folderName = path.getFileNameFromPath().removingPercentEncoding()
        folderInfo.folderType = .TextFolder
        folderInfo.isLock = LockOn
        folderInfo.identify  = 1
        folderInfo.createTime = Int(createtime)
        folderInfo.userId = CDUserId()
        folderInfo.superId = superId;
        folderInfo.folderPath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: path)
        let folderId = CDSqlManager.instance().addSafeFoldeInfo(folder: folderInfo)
        Return(folderId)
    }
    func saveSubFiles(path:String,superId:Int) {
        let fileInfo = CDSafeFileInfo()
        var fileName = path.getFileNameFromPath()
        fileName = fileName.removingPercentEncoding()
        let suffix = path.pathExtension()
        fileInfo.fileType = checkFileTypeWithExternString(externStr: suffix)
        fileInfo.fileSize = getFileSizeAtPath(filePath: path)
        
        let currentTime = getCurrentTimestamp()
        fileInfo.folderId = superId
        fileInfo.userId = CDUserId()
        fileInfo.fileName = fileName
        fileInfo.createTime = currentTime
        fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: path)
        CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)
    }
    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: NeedReloadData, object: nil)
        NotificationCenter.default.removeObserver(self, name: DocumentInputFile, object: nil)
        
    }
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNeedReloadData), name: NeedReloadData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDocumentInputFileSuccess), name: DocumentInputFile, object: nil)
        
        
    }
    //TODO:NSNotications
    @objc func onNeedReloadData() {
        isNeedReloadData = true
        
    }
    @objc func onDocumentInputFileSuccess(){
        refreshData(superId: folderInfo.folderId)
    }
    //TODO:UIDocumentInteractionControllerDelegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
    
}
