 //
//  CDAudioViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import AVFoundation
class CDAudioViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource,CDRecordSuccessDelegate,CDAudioPlayDelegate {

    var tableblew:UITableView!
    var toolbar:CDToolBar!

    var selectBtn:UIButton!
    var backBtn:UIButton!
    var audioArr:[CDSafeFileInfo] = []
    var curPlayCellPath:IndexPath?

    var isEditSelected = Bool()
    var folderInfo:CDSafeFolder!
    var selectDic:NSMutableDictionary = NSMutableDictionary()
    var selectCount:Int = 0
    var selectedAudioArr:[CDSafeFileInfo] = []
    var isNeedReloadData:Bool = false

    var playView:CDAudioPlayView!


    deinit {
        removeNotification()
    }
    override func viewWillAppear(_ animated: Bool) {
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
        self.view.addSubview(tableblew)

        tableblew.register(CDTableViewCell.self, forCellReuseIdentifier: "audioCellId")
        self.selectBtn = UIButton(type: .custom)
        self.selectBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        self.selectBtn.setImage(UIImage(named: "edit"), for: .normal);
        self.selectBtn.addTarget(self, action: #selector(multisSelectBtnClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.selectBtn!)

        self.backBtn = UIButton(type: .custom)
        self.backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        self.backBtn.setTitle("返回", for: .normal)
        self.backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backBtn!)

        self.toolbar = CDToolBar(frame: CGRect(x: 0, y: CDViewHeight-48, width: CDSCREEN_WIDTH, height: 48), foldertype: .AudioFolder, superVC: self)
        self.view.addSubview(self.toolbar)

        playView = CDAudioPlayView(frame: CGRect(x: 0, y: CDViewHeight-48, width: CDSCREEN_WIDTH, height: 48))
        playView.Adelegate = self
        self.view.addSubview(playView)
        playView.isHidden = true

        registerNotification()

    }
    func refreshData() {
        selectedAudioArr.removeAll()
        selectDic.removeAllObjects()
        toolbar.enableReloadBar(isSelected: false)
        audioArr = CDSqlManager.instance().queryAllFileFromFolder(folderId: folderInfo.folderId)
        for index in 0..<audioArr.count{
            selectDic.setObject("NO", forKey: "\(index)" as NSCopying)
        }
        tableblew.reloadData()
    }

    func handelSelectedArr(){
        selectedAudioArr.removeAll()
        let allkey:[String] = selectDic.allKeys as! [String]
        for key:String in allkey {
            let states:String = selectDic.object(forKey: key) as! String
            if states == "YES" {
                let row:Int = Int(key) ?? 0
                let fileIm = audioArr[row]
                selectedAudioArr.append(fileIm)
            }
        }
    }
    //多选
    @objc func multisSelectBtnClick() -> Void {
        canclePlay()
        self.selectBtn.isSelected = !(self.selectBtn.isSelected)
        if (self.selectBtn.isSelected) { //点了选择操作
            //1.返回变全选
            self.backBtn.setTitle("全选", for: .normal)
            self.selectBtn.setImage(UIImage(named: "no_edit"), for: .normal)
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
    @objc func documentItemClick(){
        let documentTypes = ["public.audio"]
        super.subFolderId = folderInfo.folderId
        super.subFolderType = folderInfo.folderType
        presentDocumentPicker(documentTypes: documentTypes)
    }
    @objc func addItemClick(){
        let recordVC = CDAudioRecordViewController()
        recordVC.audioDelete = self
        recordVC.folderId = folderInfo.folderId
        self.navigationController?.pushViewController(recordVC, animated: true)
    }

    //TODO:分享事件
    @objc func shareBarItemClick(){

        handelSelectedArr()
        if selectedAudioArr.count <= 0{
            return
        }
        presentShareActivityWith(dataArr: selectedAudioArr)
    }

    //删除
    @objc func deleteBarItemClick(){
        handelSelectedArr()
        var btnTitle = String()
        isNeedReloadData = false
        if selectedAudioArr.count <= 0{
            return
        }else if selectedAudioArr.count > 1{
            btnTitle = "删除\(selectedAudioArr.count)条语音"
        }else{
            btnTitle = "删除本条语音"
        }

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: btnTitle, style: .destructive, handler: { (action) in
            CDHUD.showLoading(text: "正在处理...")
            DispatchQueue.global().async {
            }

        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

    }

    @objc func appendItemClick(){
        handelSelectedArr()
        var btnTitle = String()
        isNeedReloadData = false
        if selectedAudioArr.count <= 0{
            return
        }else{
            btnTitle = "拼接选中的\(selectedAudioArr.count)条音频"
        }

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: btnTitle, style: .default, handler: { (action) in
            CDHUD.showLoading(text: "正在处理...")
            DispatchQueue.global().async {

                self.audioMergeClick()
            }

        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    func audioMergeClick(){
        let nowTime = getCurrentTimestamp()

        //导出路径
        let composePath = String.AudioPath().appendingPathComponent(str: "\(nowTime).acc")
        let fileInfo0 = selectedAudioArr[0]
        let fileInfo1 = selectedAudioArr[1]
        let resultTimeLength = fileInfo0.timeLength + fileInfo1.timeLength

        let filePath0 = String.AudioPath().appendingPathComponent(str: fileInfo0.filePath.lastPathComponent())
        let filePath1 = String.AudioPath().appendingPathComponent(str: fileInfo1.filePath.lastPathComponent())

        let audioAsset0 = AVURLAsset(url: URL(fileURLWithPath: filePath0))
        let audioAsset1 = AVURLAsset(url: URL(fileURLWithPath: filePath1))

        let composition = AVMutableComposition()

        let audioTrack0:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)!
        let audioTrack1:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)!

        let audioAssetTrack0 = audioAsset0.tracks(withMediaType: .audio).first
        let audioAssetTrack1 = audioAsset1.tracks(withMediaType: .audio).first

        do{
            try audioTrack0.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAsset0.duration), of: audioAssetTrack0!, at: CMTime.zero)
            try audioTrack1.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAsset1.duration), of: audioAssetTrack1!, at: audioAsset0.duration)

        }catch{

        }
        let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        session?.outputURL = URL(fileURLWithPath: composePath)
        session?.outputFileType = AVFileType.m4a
        session?.shouldOptimizeForNetworkUse = true //优化网络
        session?.exportAsynchronously(completionHandler: {
            if session?.status == AVAssetExportSession.Status.completed{
                DispatchQueue.main.async {
                    CDHUD.hide()
                    let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
                    fileInfo.userId = CDUserId()
                    fileInfo.folderId = self.folderInfo.folderId
                    fileInfo.fileName = "未命名"
                    fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: composePath )
                    fileInfo.fileSize = getFileSizeAtPath(filePath: composePath)
                    fileInfo.createTime = nowTime
                    fileInfo.fileType = .AudioType
                    fileInfo.timeLength = resultTimeLength
                    CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)
                    self.refreshData()
                    self.multisSelectBtnClick()
                    CDHUD.showText(text: "合成成功")
                }
            }
        })

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

        if selectBtn.isSelected {
            cell.showSelectIcon = true
            tableView.isScrollEnabled = true
            let selectState:String = selectDic.object(forKey: "\(indexPath.item)") as! String
            if selectState == "YES" {
                cell.isSelect = true
            }else{
                cell.isSelect = false
            }
        }else{
            cell.showSelectIcon = false
            tableView.isScrollEnabled = true
        }
        let fileInfo:CDSafeFileInfo = audioArr[indexPath.row]
        cell.setConfigFileData(fileInfo: fileInfo)

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectBtn.isSelected{
            var selectState:String = selectDic.object(forKey: "\(indexPath.item)") as! String
            if selectState == "YES" {
                selectCount -= 1
                selectState = "NO"
            }else{

                selectCount += 1
                selectState = "YES"
            }

            selectDic.setObject(selectState, forKey: "\(indexPath.row)" as NSCopying)
            if selectCount > 0 {
                toolbar.deleteItem.tintColor = CustomPinkColor
                toolbar.enableReloadBar(isSelected: true)
                if selectCount == 2{
                    toolbar.appendItem.isEnabled = true
                }else{
                    toolbar.appendItem.isEnabled = false
                }
            }else{
                toolbar.enableReloadBar(isSelected: false)
            }
            if selectCount == audioArr.count {
                backBtn.setTitle("全不选", for: .normal)
            }else{
                backBtn.setTitle("全选", for: .normal)
            }
            tableblew.reloadData()
        }else{
            curPlayCellPath = indexPath
            let fileInfo:CDSafeFileInfo = audioArr[indexPath.row]
            tableblew.deselectRow(at: indexPath, animated: false)

            selectAudioToPlay(file: fileInfo )

        }

    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if selectBtn.isSelected{
            var selectState:String = selectDic.object(forKey: "\(indexPath.item)") as! String
            if selectState == "YES" {
                selectCount -= 1
                selectState = "NO"
            }else{

                selectCount += 1
                selectState = "YES"
            }
            selectDic.setObject(selectState, forKey: "\(indexPath.item)" as NSCopying)
            if selectCount > 0 {
                toolbar.deleteItem.tintColor = CustomPinkColor
                toolbar.enableReloadBar(isSelected: true)
                if selectCount == 2{
                    toolbar.appendItem.isEnabled = true
                }else{
                    toolbar.appendItem.isEnabled = false
                }
            }else{
                toolbar.enableReloadBar(isSelected: false)
            }
            if selectCount == audioArr.count {
                backBtn.setTitle("全不选", for: .normal)
            }else{
                backBtn.setTitle("全选", for: .normal)
            }
        }
    }


    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let fileInfo:CDSafeFileInfo = audioArr[indexPath.row]

        let detail = UITableViewRowAction(style: .normal, title: "详情") { (action, index) in

            let fileDVC = CDFileDetailViewController()
            fileDVC.fileInfo = fileInfo
            self.navigationController?.pushViewController(fileDVC, animated: true)
        }
        detail.backgroundColor = UIColor.blue

        return [detail]

    }


    //TODO: CDRecordSuccessDelegate
    func reloadAudioList() {
        refreshData()
    }


    //TODO:播放
    func selectAudioToPlay(file:CDSafeFileInfo) {
        let decryPath = String.AudioPath().appendingPathComponent(str: file.filePath.lastPathComponent())
        initPlayer(fiePath: decryPath)


    }
    func initPlayer(fiePath:String) {
        toolbar.isHidden = true
        playView.isHidden = false
        playView.createPlayer(audioPath: fiePath)
    }


    func canclePlay() {
        playView.stopPlayer()
    }

    func audioFinishPlay() {

        toolbar.isHidden = false
        playView.isHidden = true
        curPlayCellPath = nil
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
        refreshData()
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
