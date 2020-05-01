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
    var selectFileDic:NSMutableDictionary = NSMutableDictionary()
    var selectFolderDic:NSMutableDictionary = NSMutableDictionary()
    var selectCount:Int = 0
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
        selectFileDic.removeAllObjects()
        selectFolderDic.removeAllObjects()
        toolbar.enableReloadBar(isSelected: false)
        textTD = CDSqlManager.instance().queryAllContentFromFolder(folderId: superId)
        for index in 0..<textTD.filesArr.count{
            selectFileDic.setObject("NO", forKey: "\(index)" as NSCopying)
        }
        for index in 0..<textTD.foldersArr.count{
            selectFolderDic.setObject("NO", forKey: "\(index)" as NSCopying)
        }
        currentFolderId = folderInfo.folderId;
        tableblew.reloadData()
    }

    func handelSelectedArr(){
        selectedFileArr.removeAll()
        selectedFolderArr.removeAll()
        let fileAllkey:[String] = selectFileDic.allKeys as! [String]
        for key:String in fileAllkey {
            let states:String = selectFileDic.object(forKey: key) as! String
            if states == "YES" {
                let row:Int = Int(key) ?? 0
                let fileIm = textTD.filesArr[row]
                selectedFileArr.append(fileIm)
            }
        }
        let folderAllkey:[String] = selectFolderDic.allKeys as! [String]
        for key:String in folderAllkey {
            let states:String = selectFolderDic.object(forKey: key) as! String
            if states == "YES" {
                let row:Int = Int(key) ?? 0
                let folderIm = textTD.foldersArr[row]
                selectedFolderArr.append(folderIm)
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
            //2.拍照，导入变成操作按钮
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
    @objc func addItemClick(){
        let textVC = CDNewTextViewController()
        textVC.folderId = folderInfo.folderId
        self.navigationController?.pushViewController(textVC, animated: true)

    }

    func onSelectedDirWithFolderId(folderId: Int) {
        if folderId == folderInfo.folderId { //根目录
            hiddenDirNavBar()
            
        }
        refreshData(superId: folderId)
    }

    func hiddenDirNavBar(){
        CDSignalTon.shareInstance().dirNavArr.removeAllObjects()
        UIView.animate(withDuration: 0.25) {
            self.dirNavBar.isHidden = true
            var frame = self.tableblew.frame
            if frame.origin.y > 0.0{
                frame.origin.y = 0.0
                frame.size.height += 48.0
                self.tableblew.frame = frame
            }
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
        if selectedFileArr.count <= 0{
            return
        }

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
            CDHUD.showLoading(text: "正在处理...")
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
                    CDSqlManager.instance().deleteAllSubSafeFile(folderId: folderInfo.folderId)
                    CDSqlManager.instance().deleteAllSubSafeFolder(superId: folderInfo.folderId)
                    
                    
                }
                
                
                DispatchQueue.main.async {
                    self.refreshData(superId: self.currentFolderId)
                    self.multisSelectBtnClick()
                    CDHUD.hide()
                    CDHUD.showInfo(text: "删除成功")
                }
            }

        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(sheet, animated: true, completion: nil)
    }

    func outputBarItemClick(){
        
    }
    @objc func documentItemClick(){
        //查询地址：https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259
        let documentTypes = ["public.text","com.adobe.pdf","com.microsoft.word.doc","com.microsoft.excel.xls","com.microsoft.powerpoint.ppt","public.archive"]
        super.subFolderId = folderInfo.folderId
        super.subFolderType = folderInfo.folderType
        presentDocumentPicker(documentTypes: documentTypes)
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
            var selectState = String()
            if indexPath.section == 0 {
                selectState = selectFolderDic.object(forKey: "\(indexPath.item)") as! String
            }else{
                selectState = selectFileDic.object(forKey: "\(indexPath.item)") as! String
            }
            
            if selectState == "YES" {
                cell.isSelect = true
            }else{
                cell.isSelect = false
            }
        }else{
            cell.showSelectIcon = false
            tableView.isScrollEnabled = true
        }
        if indexPath.section == 0 {
            let folder:CDSafeFolder = textTD.foldersArr[indexPath.item]
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
            var selectState = String()
            if indexPath.section == 0 {
                selectState = selectFolderDic.object(forKey: "\(indexPath.item)") as! String
            }else{
                selectState = selectFileDic.object(forKey: "\(indexPath.item)") as! String
            }
            if selectState == "YES" {
                selectCount -= 1
                selectState = "NO"
            }else{
                
                selectCount += 1
                selectState = "YES"
            }
            if indexPath.section == 0 {
                selectFolderDic.setObject(selectState, forKey: "\(indexPath.row)" as NSCopying)
            }else{
                selectFileDic.setObject(selectState, forKey: "\(indexPath.row)" as NSCopying)
            }
            
            if selectCount > 0 {
                toolbar.deleteItem.tintColor = CustomPinkColor
                toolbar.enableReloadBar(isSelected: true)
            }else{
                toolbar.enableReloadBar(isSelected: false)
            }
            if selectCount == textTD.filesArr.count + textTD.foldersArr.count {
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
            var selectState = String()
            if indexPath.section == 0 {
                selectState = selectFolderDic.object(forKey: "\(indexPath.item)") as! String
            }else{
                selectState = selectFileDic.object(forKey: "\(indexPath.item)") as! String
            }
            if selectState == "YES" {
                selectCount -= 1
                selectState = "NO"
            }else{

                selectCount += 1
                selectState = "YES"
            }
            if indexPath.section == 0 {
                selectFolderDic.setObject(selectState, forKey: "\(indexPath.row)" as NSCopying)
            }else{
                selectFileDic.setObject(selectState, forKey: "\(indexPath.row)" as NSCopying)
            }
            if selectCount > 0 {
                toolbar.deleteItem.tintColor = CustomPinkColor
                toolbar.enableReloadBar(isSelected: true)
            }else{
                toolbar.enableReloadBar(isSelected: false)
            }
            if selectCount == textTD.filesArr.count + textTD.foldersArr.count {
                backBtn.setTitle("全不选", for: .normal)
            }else{
                backBtn.setTitle("全选", for: .normal)
            }
        }
    }
    

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
        let folder:CDSafeFolder = textTD.foldersArr[indexPath.row]
            let detail = UITableViewRowAction(style: .normal, title: "详情") { (action, index) in
                let folderDVC = CDFolderDetailViewController()
                folderDVC.folderInfo = folder
                self.navigationController?.pushViewController(folderDVC, animated: true)
            }
            detail.backgroundColor = UIColor.blue
            return [detail]
        }else{
            let fileInfo:CDSafeFileInfo = textTD.filesArr[indexPath.row]
            let detail = UITableViewRowAction(style: .normal, title: "详情") { (action, index) in
                let fileDVC = CDFileDetailViewController()
                fileDVC.fileInfo = fileInfo
                self.navigationController?.pushViewController(fileDVC, animated: true)
            }
            detail.backgroundColor = UIColor.blue
            return [detail]
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
        if  CDGeneralTool.checkPasswordIsProtectedZip(zipFile: zipPath){
            let alert = UIAlertController(title: "本压缩包为加密加锁", message: "请输入解压密码", preferredStyle: .alert)
            var tmpTextFiled:UITextField!

            alert.addTextField { (textFiled) in
                tmpTextFiled = textFiled
            }
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                let password = tmpTextFiled.text ?? fileInfo.fileName
                let error = CDGeneralTool.unArchiveZipToDirectory(zip: zipPath, desDirectory: desDirPath, paaword: password)
                if error == nil {
                    CDHUD.showLoading()
                    self.getAllContentsOfDirectory(dirPath: desDirPath, superId: self.currentFolderId)
                }else{
                    CDHUD.showText(text: "解压失败:" + error!.localizedDescription)
                }
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in

            }))
            present(alert, animated: true, completion: nil)
        }else{
            let error = CDGeneralTool.unArchiveZipToDirectory(zip: zipPath, desDirectory: desDirPath, paaword: nil)
            if error == nil {
//                CDHUD.showLoading()
                getAllContentsOfDirectory(dirPath: desDirPath, superId: folderInfo.folderId)
            }else{
                CDHUD.showText(text: "解压失败:" + error!.localizedDescription)
            }
        }
    }
    func getAllContentsOfDirectory(dirPath:String,superId:Int){
        //先保存文件夹，再取子文件保存，子文件夹重复操作
        saveSubFolders(path: dirPath, superId: superId) { (folderId) in
            let T = CDGeneralTool.getAllContentsOfDirectory(dirPath: dirPath)
            for fileName in T.filesArr {
                self.saveSubFiles(path: fileName, superId: folderId)
            }
            if T.directoiesArr.count > 0 {
                for dirName in T.directoiesArr {
                    self.getAllContentsOfDirectory(dirPath: dirName, superId: folderId)
                }
            }else{
                CDHUD.showText(text: "解压成功")
                self.refreshData(superId: self.folderInfo.folderId)
            }
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
