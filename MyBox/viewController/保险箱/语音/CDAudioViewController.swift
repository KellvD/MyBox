 //
//  CDAudioViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import AVFoundation
class CDAudioViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource,CDAudioPlayDelegate {

    public var gFolderInfo:CDSafeFolder!
    private var tableblew:UITableView!
    private var toolbar:CDToolBar!
    private var batchBtn:UIButton!
    private var backBtn:UIButton!
    private var audioArr:[CDSafeFileInfo] = []
    private var curPlayCellPath:IndexPath?
    private var selectCount:Int = 0
    private var selectedAudioArr:[CDSafeFileInfo] = []
    private var isNeedReloadData:Bool = false //是否刷新数据
    private var playView:CDAudioPlayView!


    deinit {
        removeNotification()
    }
    override func viewWillAppear(_ animated: Bool) {
        tableblew.setEditing(false, animated: false)
        //push,present前设置pop，dismiss后本界面是否刷新数据。原则上离开本界面后对数据有操作的都需要刷新
        if isNeedReloadData {
            isNeedReloadData = false
            refreshData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "语音文件"
        isNeedReloadData = true
        tableblew = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight-48), style: .plain)
        tableblew.delegate = self
        tableblew.dataSource = self
        tableblew.separatorStyle = .none
        view.addSubview(tableblew)
        tableblew.register(CDTableViewCell.self, forCellReuseIdentifier: "audioCellId")
        
        batchBtn = UIButton(type: .custom)
        batchBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        batchBtn.setImage(UIImage(named: "edit"), for: .normal);
        batchBtn.addTarget(self, action: #selector(multisSelectBtnClick), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: batchBtn!)

        backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        backBtn.setTitle("返回", for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backBtn!)

        toolbar = CDToolBar(frame: CGRect(x: 0, y: CDViewHeight-48, width: CDSCREEN_WIDTH, height: 48), foldertype: .AudioFolder, superVC: self)
        view.addSubview(self.toolbar)

        playView = CDAudioPlayView(frame: CGRect(x: 0, y: CDViewHeight, width: CDSCREEN_WIDTH, height: 48))
        playView.Adelegate = self
        view.addSubview(playView)

        registerNotification()

    }
    
    func refreshData() {
        toolbar.enableReloadBar(isSelected: false)
        audioArr = CDSqlManager.instance().queryAllFileFromFolder(folderId: gFolderInfo.folderId)
        tableblew.reloadData()
    }

    func handelSelectedArr(){
        selectedAudioArr.removeAll()
        audioArr.forEach { (tmpFile) in
            if tmpFile.isSelected == .CDTrue{
                selectedAudioArr.append(tmpFile)
            }
        }
    }
    //批量操作
    @objc func multisSelectBtnClick() -> Void {
        banchHandleFiles(isSelected: !(batchBtn.isSelected))
    }

    func banchHandleFiles(isSelected:Bool){
        canclePlay()
        selectCount = 0
        batchBtn.isSelected = isSelected
        if (batchBtn.isSelected) { //点了选择操作
            self.backBtn.setTitle("全选", for: .normal)
            batchBtn.setImage(UIImage(named: "no_edit"), for: .normal)
            toolbar.hiddenReloadBar(isMulit: true)
            audioArr.forEach { (file) in
                file.isSelected = .CDFalse
            }
        }else{
            //1.全选变返回
            self.backBtn.setTitle("返回", for: .normal)
            batchBtn.setImage(UIImage(named: "edit"), for: .normal)
            toolbar.hiddenReloadBar(isMulit: false)
            selectedAudioArr.removeAll()
        }
        tableblew.reloadData()
    }
    //返回
    @objc func backBtnClick() -> Void {
        if batchBtn.isSelected { //
            if (self.backBtn.titleLabel?.text == "全选") { //全选
                audioArr.forEach { (file) in
                    file.isSelected = .CDTrue
                }
                selectCount = audioArr.count
            }else{
                audioArr.forEach { (file) in
                    file.isSelected = .CDFalse
                }
                selectCount = 0
            }
            refreshUI()
            
        }else{
            self.navigationController?.popViewController(animated: true)
        }

    }
    func refreshUI(){
        if selectCount > 0 {
            toolbar.enableReloadBar(isSelected: true)
            if selectCount >= 2{
                toolbar.appendItem.isEnabled = true
            }else{
                toolbar.appendItem.isEnabled = false
            }
        }else{
            toolbar.enableReloadBar(isSelected: false)
        }
        if selectCount == audioArr.count {
            self.backBtn.setTitle("全不选", for: .normal)
            backBtn.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
            backBtn.contentHorizontalAlignment = .left
        }else{
            backBtn.setTitle("全选", for: .normal)
        }
        tableblew.reloadData()
    }
    
    @objc func documentItemClick(){
        isNeedReloadData = true
        let documentTypes = ["public.audio"]
        super.subFolderId = gFolderInfo.folderId
        super.subFolderType = gFolderInfo.folderType
        super.processHandle = {(_ success:Bool) -> Void in
            if success {
                self.refreshData()
            }
        }
        presentDocumentPicker(documentTypes: documentTypes)
    }
    
    @objc func inputItemClick(){
        isNeedReloadData = true
        let recordVC = CDAudioRecordViewController()
        recordVC.folderId = gFolderInfo.folderId
        self.navigationController?.pushViewController(recordVC, animated: true)
    }

    //MARK:分享事件
    @objc func shareBarItemClick(){
        handelSelectedArr()
        var shareArr:[NSObject] = []
        for index in 0..<self.selectedAudioArr.count{
            let file:CDSafeFileInfo = self.selectedAudioArr[index]
            let videoPath = String.AudioPath().appendingPathComponent(str: file.filePath.lastPathComponent())
            let url = URL(fileURLWithPath: videoPath)
            shareArr.append(url as NSObject)
        }
        presentShareActivityWith(dataArr: shareArr) { (error) in
            self.banchHandleFiles(isSelected: false)
        }
    }

    //删除
    @objc func deleteBarItemClick(){
    
        handelSelectedArr()
        var btnTitle = String()
        if selectedAudioArr.count > 1{
            btnTitle = "删除\(selectedAudioArr.count)条语音"
        }else{
            btnTitle = "删除本条语音"
        }

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: btnTitle, style: .destructive, handler: { (action) in
            CDHUDManager.shared.showWait(text: "删除中...")
            for index in 0..<self.selectedAudioArr.count{
                let fileInfo = self.selectedAudioArr[index]
                    let defaultPath = String.AudioPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                    fileManagerDeleteFileWithFilePath(filePath: defaultPath)
                    CDSqlManager.instance().deleteOneSafeFile(fileId: fileInfo.fileId)
                }
                DispatchQueue.main.async {
                    CDHUDManager.shared.hideWait()
                    CDHUDManager.shared.showComplete(text: "删除完成！")
                    self.refreshData()
                    self.banchHandleFiles(isSelected: false)
                }

        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }

    //拼接
    @objc func appendItemClick(){
        handelSelectedArr()
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "合成选中的\(selectedAudioArr.count)条音频", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                CDHUDManager.shared.showWait(text: "正在处理...")
            }
            
            CDSignalTon.shared.appendAudio(folderId: self.gFolderInfo.folderId, appendFile: self.selectedAudioArr) { (success) in
                DispatchQueue.main.async {
                    CDHUDManager.shared.hideWait()
                    self.refreshData()
                    if success{
                        CDHUDManager.shared.showText(text: "合成成功")
                    }else{
                        CDHUDManager.shared.showText(text: "合成失败")
                    }
                }
            }
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellId = "audioCellId"
        var cell:CDTableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? CDTableViewCell
        if cell == nil {
            cell = CDTableViewCell(style: .default, reuseIdentifier: cellId)
        }

        if batchBtn.isSelected {
            let tmpFile = audioArr[indexPath.row]
            if tmpFile.isSelected == .CDTrue {
                cell.showSelectIcon = .selected
            }else{
               cell.showSelectIcon = .show
            }
        }else{
            cell.showSelectIcon = .hide
        }
        let fileInfo:CDSafeFileInfo = audioArr[indexPath.row]
        cell.setConfigFileData(fileInfo: fileInfo)

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if batchBtn.isSelected{
            let tmpFile = audioArr[indexPath.row]
            if tmpFile.isSelected == .CDTrue {
                selectCount -= 1
                tmpFile.isSelected = .CDFalse
            }else{
                selectCount += 1
                tmpFile.isSelected = .CDTrue
            }

            refreshUI()
        }else{
            curPlayCellPath = indexPath
            let fileInfo:CDSafeFileInfo = audioArr[indexPath.row]
            tableblew.deselectRow(at: indexPath, animated: false)
            selectAudioToPlay(file: fileInfo )

        }

    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if batchBtn.isSelected{
            let tmpFile = audioArr[indexPath.row]
            if tmpFile.isSelected == .CDTrue {
                selectCount -= 1
                tmpFile.isSelected = .CDFalse
            }else{
                selectCount += 1
                tmpFile.isSelected = .CDTrue
            }
            refreshUI()
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !batchBtn.isSelected
    }
    
    @available(iOS, introduced: 8.0, deprecated: 13.0)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let tmpFile:CDSafeFileInfo = audioArr[indexPath.row]
        let detail = UITableViewRowAction(style: .normal, title: "详情") { (action, index) in
            let fileDVC = CDFileDetailViewController()
            fileDVC.fileInfo = tmpFile
            self.navigationController?.pushViewController(fileDVC, animated: true)
        }
        return [detail]
    }
    
    @available(iOS 11, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let tmpFile:CDSafeFileInfo = audioArr[indexPath.row]
        let detail = UIContextualAction(style: .normal, title: "👁‍🗨") { (action, view, handle) in
            let fileDVC = CDFileDetailViewController()
            fileDVC.fileInfo = tmpFile
            self.navigationController?.pushViewController(fileDVC, animated: true)
        }
        detail.image = UIImage(named: "fileDetail")
        //
        let delete = UIContextualAction(style: .normal, title: "删除") { (action, view, handle) in
            tmpFile.isSelected = .CDTrue
            self.deleteBarItemClick()
        }
        delete.backgroundColor = .red
        let action = UISwipeActionsConfiguration(actions: [delete,detail])
        return action
    }


    //MARK:播放
    func selectAudioToPlay(file:CDSafeFileInfo) {
        let decryPath = String.AudioPath().appendingPathComponent(str: file.filePath.lastPathComponent())
        initPlayer(fiePath: decryPath)


    }
    func initPlayer(fiePath:String) {
        UIView.animate(withDuration: 0.25, animations: {
            var rect = self.toolbar.frame
            rect.origin.y = CDViewHeight
            self.toolbar.frame = rect

        }) { (flag) in
            
            UIView.animate(withDuration: 0.25, animations: {
                var rect = self.playView.frame
                rect.origin.y = CDViewHeight - 48
                self.playView.frame = rect
            }, completion: { (flag) in
                self.playView.createPlayer(audioPath: fiePath)
            })
        }
    }


    func canclePlay() {
        playView.stopPlayer()
    }

    func audioFinishPlay() {
        UIView.animate(withDuration: 0.25, animations: {
            var rect = self.playView.frame
            rect.origin.y = CDViewHeight
            self.playView.frame = rect

        }) { (flag) in
            
            UIView.animate(withDuration: 0.25, animations: {
                var rect = self.toolbar.frame
                rect.origin.y = CDViewHeight - 48
                self.toolbar.frame = rect
            }, completion: { (flag) in
                self.curPlayCellPath = nil
            })
        }
        
    }

    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: NeedReloadData, object: nil)
    }
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNeedReloadData), name: NeedReloadData, object: nil)

    }
    //MARK:NSNotications
    @objc func onNeedReloadData() {
        isNeedReloadData = true

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
