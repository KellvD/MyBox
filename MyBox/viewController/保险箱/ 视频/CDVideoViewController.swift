//
//  CDVideoViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import AVFoundation
let videoCut = "视频裁剪"
let videoAppend = "视频拼接"
class CDVideoViewController: CDBaseAllViewController,UICollectionViewDelegate,UICollectionViewDataSource,CDMediaPickerDelegate,CDCameraViewControllerDelegate {
    
    public var folderInfo:CDSafeFolder!
    
    private var toolbar:CDToolBar!
    private var batchBtn:UIButton!
    private var backBtn:UIButton!
    private var collectionView:UICollectionView!
    private var videoArr:[CDSafeFileInfo] = []
    private var selectCount:Int = 0 //选择的数量
    private var selectedVideoArr:[CDSafeFileInfo] = [] //存放选中的视频
    private var outputVideoArr:[CDSafeFileInfo] = []   //临时存放需要导出的视频，串行，导出一个删一个
    private var isNeedReloadData:Bool = false
    

    override func viewWillAppear(_ animated: Bool) {
        if isNeedReloadData {
            isNeedReloadData = false
            refreshData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "视频文件"
        isNeedReloadData = true
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:(CDSCREEN_WIDTH-10)/4 , height: (CDSCREEN_WIDTH-10)/4)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight-48), collectionViewLayout: layout)
        collectionView.register(CDImageCell.self, forCellWithReuseIdentifier: "VideoCellIdrr")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView!)
        self.batchBtn = UIButton(type: .custom)
        self.batchBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        self.batchBtn.setImage(UIImage(named: "edit"), for: .normal);
        self.batchBtn.addTarget(self, action: #selector(batchBtnClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.batchBtn!)
        
        self.backBtn = UIButton(type: .custom)
        self.backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        self.backBtn.setTitle("返回", for: .normal)
        self.backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backBtn!)
        
        self.toolbar = CDToolBar(frame: CGRect(x: 0, y: CDViewHeight-48, width: CDSCREEN_WIDTH, height: 48), foldertype: .ImageFolder, superVC: self)
        self.view.addSubview(self.toolbar)
    }
    
    // MARK:批量按钮
    @objc func batchBtnClick(){
        batchHandleFiles(isBatch: !batchBtn.isSelected)
    }
    
    private func batchHandleFiles(isBatch:Bool) -> Void {
        selectCount = 0
        batchBtn.isSelected = isBatch
        if (batchBtn.isSelected) { //点了批量操作
            backBtn.setTitle("全选", for: .normal)
            batchBtn.setImage(UIImage(named: "no_edit"), for: .normal)
            toolbar.hiddenReloadBar(isMulit: true)
        } else {
            backBtn.setTitle("返回", for: .normal)
            batchBtn.setImage(UIImage(named: "edit"), for: .normal)
            toolbar.hiddenReloadBar(isMulit: false)
            videoArr.forEach { (tmpFile) in
                tmpFile.isSelected = .CDFalse
            }
            
        }
        collectionView.reloadData()
    }
    
    //返回
    @objc func backBtnClick() -> Void {
        if batchBtn.isSelected { //
            selectedVideoArr.removeAll()
            if (self.backBtn.currentTitle == "全选") { //全选
                videoArr.forEach { (file) in
                    file.isSelected = .CDTrue
                }
                selectCount = videoArr.count
            }else{
                videoArr.forEach { (file) in
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
        toolbar.enableReloadBar(isSelected: selectCount > 0)
        //视频拼接只能2-5个
        toolbar.appendItem.isEnabled = (selectCount >= 2 && selectCount <= 5)
        if selectCount == videoArr.count && videoArr.count > 0{
            backBtn.frame = CGRect(x: 0, y: 0, width: 88, height: 44)
            backBtn.contentHorizontalAlignment = .left
            backBtn.setTitle("全不选", for: .normal)
        }else{
            backBtn.setTitle("全选", for: .normal)
        }
        collectionView.reloadData()
    }
    func refreshData() {
        selectedVideoArr.removeAll()
        toolbar.enableReloadBar(isSelected: false)
        videoArr = CDSqlManager.shared.queryAllFileFromFolder(folderId: folderInfo.folderId)
        collectionView.reloadData()
    }
    
    func handelSelectedArr(){
        selectedVideoArr.removeAll()
        selectedVideoArr = videoArr.filter({ (tmp) -> Bool in
            tmp.isSelected == .CDTrue
        })
    }
    
    //MARK:分享事件
    @objc func shareBarItemClick(){
        handelSelectedArr()
        var shareArr:[NSObject] = []
        for index in 0..<self.selectedVideoArr.count{
            let file:CDSafeFileInfo = self.selectedVideoArr[index]
            let videoPath = String.VideoPath().appendingPathComponent(str: file.filePath.lastPathComponent())
            let url = URL(fileURLWithPath: videoPath)
            shareArr.append(url as NSObject)
        }
        
        presentShareActivityWith(dataArr: shareArr) { (error) in
            self.batchHandleFiles(isBatch: false)
        }
        
    }
    //MARK:移动
    @objc func moveBarItemClick(){
        isNeedReloadData = false
        handelSelectedArr()
        let folderList = CDFolderListViewController()
        folderList.selectedArr = selectedVideoArr
        folderList.folderType = .VideoFolder
        folderList.folderId = folderInfo.folderId
        folderList.moveHandle = {(success) -> Void in
            //移动返回后，删除移动数据源，取消批量操作,选中数据源以删除，不用恢复
            self.batchHandleFiles(isBatch: false)
        }
        
        self.navigationController?.pushViewController(folderList, animated: true)
        
    }
    //MARK:导出
    @objc func outputBarItemClick(){
        handelSelectedArr()
        let alert = UIAlertController(title: nil, message: "您确定要导入选中的视频到系统相册？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            DispatchQueue.main.async  {
                CDHUDManager.shared.showWait(text: "处理中...")
                self.outputVideoArr = self.selectedVideoArr
                self.outputVideoToLocal()
                
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    //导出操作是串行，outputVideoArr临时存放操作文件，从导出完成一个，从数组删除该文件，继续导出操作
    func outputVideoToLocal() -> Void {
        if self.outputVideoArr.count > 0 {
            for index in 0..<self.outputVideoArr.count{
                let file:CDSafeFileInfo = self.outputVideoArr[index]
                let fileName = file.filePath.lastPathComponent()
                let videoPath = String.VideoPath().appendingPathComponent(str: fileName)
                let compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)
                if compatible{
                    UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, #selector(outputVideoComplete(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                }else{
                    let filsC:CDSafeFileInfo = outputVideoArr[0];
                    let fileName = filsC.filePath.lastPathComponent()
                    let thumpVideoPath = String.thumpVideoPath().appendingPathComponent(str: fileName)
                    DeleteFile(filePath: thumpVideoPath)
                    outputVideoArr.remove(at: 0)
                    outputVideoToLocal()
                }
                
            }
        }else{
            CDHUDManager.shared.hideWait()
            CDHUDManager.shared.showComplete(text: "导出完成！")
            self.refreshData()
            self.batchHandleFiles(isBatch: false)
        }
        
    }
    
    @objc private func outputVideoComplete(videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        //导出成功后删除数组第一个,继续导出操作
        outputVideoArr.remove(at: 0)
        outputVideoToLocal()
    }
    
    //MARK:删除
    @objc func deleteBarItemClick(){
        handelSelectedArr()
        let btnTitle = selectedVideoArr.count > 1 ? "删除\(selectedVideoArr.count)条视频" :"删除视频"
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: btnTitle, style: .destructive, handler: { (action) in
            CDHUDManager.shared.showWait(text: "处理中...")
            DispatchQueue.global().async {
                
                self.selectedVideoArr.forEach { (tmpFile) in
                    //删除加密小题
                    let thumbPath = String.thumpVideoPath().appendingPathComponent(str: tmpFile.filePath.lastPathComponent())
                    DeleteFile(filePath: thumbPath)
                    //删除加密大图
                    let defaultPath = String.VideoPath().appendingPathComponent(str: tmpFile.filePath.lastPathComponent())
                    DeleteFile(filePath: defaultPath)
                    CDSqlManager.shared.deleteOneSafeFile(fileId: tmpFile.fileId)
                
                    //删除元数据数组
                    let index = self.videoArr.firstIndex(of: tmpFile)
                    self.videoArr.remove(at: index!)
                }
                DispatchQueue.main.async {
                    CDHUDManager.shared.hideWait()
                    CDHUDManager.shared.showComplete(text: "删除完成！")
                    self.batchHandleFiles(isBatch: false)
                }
            }
            
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }

    //MARK:视频剪辑
    @objc func appendItemClick(){
        handelSelectedArr()
        
        let sheet = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "拼接视频", style: .destructive, handler: { (action) in
            let appendVC = CDAppendVideoViewController()
            appendVC.fileArr = self.selectedImageArr
            appendVC.folderId = self.folderInfo.folderId
            appendVC.composeType = .Gif
            appendVC.composeHandle = {[unowned self](success) -> Void in
                
                //拼接产生新的数据，更新DB数据源
                self.refreshData()
                //取消批量操作，更新DB时，所有本地数据重新从DB中更新，无需重复操作
                self.batchHandleFiles(isBatch: false)
            }
            self.navigationController?.pushViewController(gifVC, animated: true)
            
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    //MARK:拍照
    @objc func takePhotoClick() -> Void {
        
        checkPermission(type: .camera) { (isAllow) in
            if isAllow {
                DispatchQueue.main.async {
                    let camera = CDCameraViewController()
                    camera.delegate = self
                    camera.isVideo = true
                    camera.modalPresentationStyle = .fullScreen
                    self.present(camera, animated: true, completion: nil)
                }
            } else {
                openPermission(type: .camera, viewController: self)
            }
        }
        
    }
    //MARK:导入
    @objc func inputItemClick() -> Void {
        checkPermission(type: . library) { (isAllow) in
            if isAllow {
                DispatchQueue.main.async {
                    //保持屏幕常亮
                    let elcPicker = CDMediaPickerViewController(isVideo: true)
                    elcPicker.pickerDelegate = self
                    CDAssetTon.shared.mediaType = .CDMediaVideo
                    elcPicker.folderId = self.folderInfo.folderId
                    CDSignalTon.shared.customPickerView = elcPicker
                    elcPicker.modalPresentationStyle = .fullScreen
                    self.present(elcPicker, animated: true, completion: nil)
                }
            } else {
                openPermission(type: .library, viewController: self)
            }
        }
        
    }
    
    //MARK:沙盒导入
    @objc func documentItemClick(){
        let documentTypes = ["public.movie"]
        super.subFolderId = folderInfo.folderId
        super.subFolderType = folderInfo.folderType
        super.processHandle = {[weak self](_ success:Bool) -> Void in
            if success {
                self!.refreshData()
            }
        }
        presentDocumentPicker(documentTypes: documentTypes)
    }
    
    //collectionviewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCellIdrr", for: indexPath) as! CDImageCell
        let tmpFile:CDSafeFileInfo = videoArr[indexPath.item]
        cell.setVideoData(fileInfo: tmpFile,isMutilEdit: batchBtn.isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell:CDImageCell = collectionView.cellForItem(at: indexPath) as! CDImageCell
        
        if batchBtn.isSelected{
            let tmFile = videoArr[indexPath.item]
            if tmFile.isSelected == .CDFalse {
                cell.isSelected = true
                selectCount += 1
                tmFile.isSelected = .CDTrue
            }else{
                cell.isSelected = false
                selectCount -= 1
                tmFile.isSelected = .CDFalse
            }
            cell.reloadSelectImageView()
            refreshUI()
            
        }else{
            let scrollerVC = CDVideoScrollerViewController()
            scrollerVC.currentIndex = indexPath.item
            scrollerVC.fileArr = videoArr
            scrollerVC.currentIndex = indexPath.item
            self.navigationController?.pushViewController(scrollerVC, animated: true)
        }
    }
    
    
    
    //MARK:CDMeidaPickerDelegate
    func onMediaPickerDidFinished(picker: CDMediaPickerViewController, data: Dictionary<String, Any>, index: Int, totalCount: Int) {
        let tmpUrl = data["fileURL"] as! URL
        
        CDSignalTon.shared.saveSafeFileInfo(fileUrl: tmpUrl, folderId: folderInfo
            .folderId, subFolderType: .VideoFolder,isFromDocment: false)
        func pickOver(){
            CDSignalTon.shared.customPickerView = nil
            picker.dismiss(animated: true, completion: nil)
            refreshData()
        }
        DispatchQueue.main.async {
            //只有一个，不加载进度条
            if 1 == totalCount  {
                pickOver()
                CDHUDManager.shared.showComplete(text: "导入完成！")
            } else {
                if index == 1 { //第一个出现进度条
                    CDHUDManager.shared.showProgress(text: "开始导入！")
                    CDHUDManager.shared.updateProgress(num: Float(index)/Float(totalCount), text: "第\(index)个 共\(totalCount)个")
                } else if index == totalCount {
                    
                    CDHUDManager.shared.updateProgress(num: Float(index)/Float(totalCount), text: "第\(index)个 共\(totalCount)个")
                    CDHUDManager.shared.hideProgress()
                    CDHUDManager.shared.showComplete(text: "导入完成！")
                    pickOver()
                }else{
                    CDHUDManager.shared.updateProgress(num: Float(index)/Float(totalCount), text: "第\(index)个 共\(totalCount)个")
                }
                
            }
        }
    }
    
    
    
    func onMediaPickerDidCancle(picker: CDMediaPickerViewController) {
        CDSignalTon.shared.customPickerView = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    func onCameraTakePhotoDidFinshed(cameraVC: CDCameraViewController, obj: Dictionary<String, Any>) {
        isNeedReloadData = true
        let videoUrl = obj["fileURL"] as! URL
        CDSignalTon.shared.saveSafeFileInfo(fileUrl: videoUrl, folderId: folderInfo.folderId, subFolderType: .VideoFolder,isFromDocment: false)
        CDSignalTon.shared.customPickerView = nil
        cameraVC.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
