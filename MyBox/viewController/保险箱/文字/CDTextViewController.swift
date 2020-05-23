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
    var batchBtn:UIButton!
    var backBtn:UIButton!
    var toolbar:CDToolBar!
    var dirNavBar:CDDirNavBar!
    var textTD:(foldersArr:[CDSafeFolder],filesArr:[CDSafeFileInfo])!
    var selectFileCount:Int = 0
    var selectFolderCount:Int = 0
    var selectedFileArr:[CDSafeFileInfo] = []
    var selectedFolderArr:[CDSafeFolder] = []
    var isNeedReloadData:Bool = false
    var currentFolderId:Int!
    public
    var gFolderInfo:CDSafeFolder!
    
    deinit {
        removeNotification()
    }
    override func viewWillAppear(_ animated: Bool) {
        if isNeedReloadData {
            isNeedReloadData = false
            refreshData(superId: gFolderInfo.folderId)
            CDSignalTon.shareInstance().dirNavArr.removeAllObjects()//进入文本文件
        }
        tableblew.setEditing(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "文本文件"
        isNeedReloadData = true
        currentFolderId = gFolderInfo.folderId;

        dirNavBar = CDDirNavBar(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 48))
        dirNavBar.dirDelegate = self
        view.addSubview(dirNavBar)
        
        tableblew = UITableView(frame: CGRect(x: 0, y: dirNavBar.frame.maxY, width: CDSCREEN_WIDTH, height: CDViewHeight - 48 - dirNavBar.frame.height), style: .plain)
        tableblew.delegate = self
        tableblew.dataSource = self
        tableblew.separatorStyle = .none
        self.view.addSubview(tableblew)
        tableblew.register(CDTableViewCell.self, forCellReuseIdentifier: "textCellId")
        
        batchBtn = UIButton(type: .custom)
        batchBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        batchBtn.setImage(UIImage(named: "edit"), for: .normal);
        batchBtn.addTarget(self, action: #selector(batchBtnClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: batchBtn!)
        
        self.backBtn = UIButton(type: .custom)
        self.backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        self.backBtn.setTitle("返回", for: .normal)
        self.backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backBtn!)
        
        self.toolbar = CDToolBar(frame: CGRect(x: 0, y: CDViewHeight-48, width: CDSCREEN_WIDTH, height: 48), foldertype: .TextFolder, superVC: self)
        self.view.addSubview(self.toolbar)
        hiddenDirNavBar()
        registerNotification()
    }
    
    func refreshData(superId:Int) {
        toolbar.enableReloadBar(isSelected: false)
        textTD = CDSqlManager.instance().queryAllContentFromFolder(folderId: superId)
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
    @objc func batchBtnClick(){
        batchHandleFiles(isSelected: !batchBtn.isSelected)
    }
    
    func batchHandleFiles(isSelected:Bool) -> Void {
        selectFileCount = 0
        selectFolderCount = 0
        batchBtn.isSelected = isSelected
        if (batchBtn.isSelected) { //点了批量操作
            //1.返回按钮变全选
            self.backBtn.setTitle("全选", for: .normal)
            batchBtn.setImage(UIImage(named: "no_edit"), for: .normal)
            //所有文件，文件夹设置未选状态
            textTD.filesArr.forEach { (tmpFile) in
                tmpFile.isSelected = .CDFalse
            }
            textTD.foldersArr.forEach { (tmpFolder) in
                tmpFolder.isSelected = .CDFalse
            }
            toolbar.hiddenReloadBar(isMulit: true)
        }else{
            //1.返回变全选
            self.backBtn.setTitle("返回", for: .normal)
            batchBtn.setImage(UIImage(named: "edit"), for: .normal)
            toolbar.hiddenReloadBar(isMulit: false)
        }
        tableblew.reloadData()
    }
    
    
    //返回
    @objc func backBtnClick() -> Void {
        if batchBtn.isSelected {
            if (self.backBtn.titleLabel?.text == "全选") { //全选
                textTD.filesArr.forEach { (tmpFile) in
                     tmpFile.isSelected = .CDTrue
                 }
                 textTD.foldersArr.forEach { (tmpFolder) in
                     tmpFolder.isSelected = .CDTrue
                 }
                 selectFileCount = textTD.filesArr.count
                 selectFolderCount = textTD.foldersArr.count
            }else{
                textTD.filesArr.forEach { (tmpFile) in
                    tmpFile.isSelected = .CDFalse
                }
                textTD.foldersArr.forEach { (tmpFolder) in
                    tmpFolder.isSelected = .CDFalse
                }
                selectFileCount = 0
                selectFolderCount = 0
            }
            refreshUI()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    func refreshUI(){
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
            self.backBtn.setTitle("全不选", for: .normal)
            backBtn.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
            backBtn.contentHorizontalAlignment = .left
        }else{
            backBtn.setTitle("全选", for: .normal)
        }
        tableblew.reloadData()
    }
    
    //选择文件夹目录
    func onSelectedDirWithFolderId(folderId: Int) {
        if folderId == gFolderInfo.folderId { //根目录
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
        var shareArr:[NSObject] = []
        for index in 0..<self.selectedFileArr.count{
            let file:CDSafeFileInfo = self.selectedFileArr[index]
            let filePath = String.libraryUserdataPath().appendingPathComponent(str: file.filePath)
            let url = URL(fileURLWithPath: filePath)
            shareArr.append(url as NSObject)
        }
        presentShareActivityWith(dataArr: shareArr) { (error) in
            self.batchHandleFiles(isSelected: false)
        }
        
        
    }
    //移动
    @objc func moveBarItemClick(){
        isNeedReloadData = true
        handelSelectedArr()
        let folderList = CDFolderListViewController()
        folderList.title = "文件夹列表"
        folderList.selectedArr = selectedFileArr
        folderList.folderType = .TextFolder
        folderList.folderId = gFolderInfo.folderId
        self.navigationController?.pushViewController(folderList, animated: true)
    }
    
    //删除
    @objc func deleteBarItemClick(){
        handelSelectedArr()
        let total = selectedFileArr.count + selectedFolderArr.count
        let btnTitle = total > 1 ? "删除\(total)个文件" : "删除文件"
        
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
                    self.batchHandleFiles(isSelected: false)
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
        super.subFolderId = gFolderInfo.folderId
        super.subFolderType = gFolderInfo.folderType
        
        super.processHandle = {(_ success:Bool) -> Void in
            if success {
                self.refreshData(superId: self.gFolderInfo.folderId)
            }
        }
        presentDocumentPicker(documentTypes: documentTypes)
    }
    @objc func inputItemClick(){
        self.isNeedReloadData = true
        let textVC = CDNewTextViewController()
        textVC.folderId = gFolderInfo.folderId
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
        
        if batchBtn.isSelected {
            
            var selectState:CDSelectedStatus!
            if indexPath.section == 0 {
                let folder:CDSafeFolder = textTD.foldersArr[indexPath.row]
                selectState = folder.isSelected
            }else{
                let fileInfo:CDSafeFileInfo = textTD.filesArr[indexPath.row]
                selectState = fileInfo.isSelected
            }
            
            if selectState == .CDTrue {
                cell.showSelectIcon = .selected
            }else{
               cell.showSelectIcon = .show
            }
        }else{
            cell.showSelectIcon = .hide
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
        if batchBtn.isSelected{
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
                    selectFileCount -= 1
                    fileInfo.isSelected = .CDFalse
                }else{
                    selectFileCount += 1
                    fileInfo.isSelected = .CDTrue
                }
            }
            
           refreshUI()
        }else{
            if indexPath.section == 0 {
                if CDSignalTon.shareInstance().dirNavArr.count == 0 {
                    CDSignalTon.shareInstance().dirNavArr.add(gFolderInfo!)
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
        if batchBtn.isSelected{
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
                    selectFileCount -= 1
                    fileInfo.isSelected = .CDFalse
                }else{
                    selectFileCount += 1
                    fileInfo.isSelected = .CDTrue
                }
            }
            refreshUI()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !batchBtn.isSelected
    }
    
    @available(iOS, introduced: 8.0, deprecated: 13.0)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            let folder:CDSafeFolder = textTD.foldersArr[indexPath.row]
            let detail = UITableViewRowAction(style: .normal, title: "详情") { (action, index) in
                let folderDVC = CDFolderDetailViewController()
                folderDVC.folderInfo = folder
                self.navigationController?.pushViewController(folderDVC, animated: true)
            }
            return [detail]
        }else{
            let fileInfo:CDSafeFileInfo = textTD.filesArr[indexPath.row]
            let detail = UITableViewRowAction(style: .normal, title: "详情") { (action, index) in
                let fileDVC = CDFileDetailViewController()
                fileDVC.fileInfo = fileInfo
                self.navigationController?.pushViewController(fileDVC, animated: true)
            }
            return [detail]
        }
    }
    
    @available(iOS 11, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 {
            let folder:CDSafeFolder = textTD.foldersArr[indexPath.row]
            let detail = UIContextualAction(style: .normal, title: "👁‍🗨") { (action, view, handle) in
                let folderDVC = CDFolderDetailViewController()
                folderDVC.folderInfo = folder
                self.navigationController?.pushViewController(folderDVC, animated: true)
            }
            
            detail.image = UIImage(named: "fileDetail")
            
            let delete = UIContextualAction(style: .normal, title: "删除") { (action, view, handle) in
                folder.isSelected = .CDTrue
                self.deleteBarItemClick()
            }
            delete.backgroundColor = .red
            let action = UISwipeActionsConfiguration(actions: [delete,detail])
            return action
        }else{
            let fileInfo:CDSafeFileInfo = textTD.filesArr[indexPath.row]
            let detail = UIContextualAction(style: .normal, title: "👁‍🗨") { (action, view, handle) in
                let fileDVC = CDFileDetailViewController()
                fileDVC.fileInfo = fileInfo
                self.navigationController?.pushViewController(fileDVC, animated: true)
            }
            detail.image = UIImage(named: "fileDetail")
            
            let delete = UIContextualAction(style: .normal, title: "删除") { (action, view, handle) in
                fileInfo.isSelected = .CDTrue
                self.deleteBarItemClick()
            }
            delete.backgroundColor = .red
            let action = UISwipeActionsConfiguration(actions: [delete,detail])
            return action
        }
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
                    self.refreshData(superId: self.gFolderInfo.folderId)
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
        folderInfo.fakeType = .visible
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
        
        
    }
    //TODO:NSNotications
    @objc func onNeedReloadData() {
        isNeedReloadData = true
        
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
