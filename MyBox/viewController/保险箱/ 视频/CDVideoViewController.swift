//
//  CDVideoViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import AVFoundation
import CDMediaPicker


class CDVideoViewController: CDBaseAllViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    public var folderInfo:CDSafeFolder!
    
    private var toolbar:CDToolBar!
    private var batchBtn:UIButton!
    private var backBtn:UIButton!
    private var collectionView:UICollectionView!
    @objc dynamic private var fileArr:[CDSafeFileInfo] = []
    private var selectCount:Int = 0 //选择的数量
    private var selectedVideoArr:[CDSafeFileInfo] = [] //存放选中的视频
    private var outputVideoArr:[CDSafeFileInfo] = []   //临时存放需要导出的视频，串行，导出一个删一个
    private var isNeedReloadData:Bool = false
    deinit {
        super.removeObserver(self, forKeyPath: "fileArr")
    }
    override func viewWillAppear(_ animated: Bool) {
        if isNeedReloadData {
            isNeedReloadData = false
            refreshData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNeedReloadData = true
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:(CDSCREEN_WIDTH-10)/4 , height: (CDSCREEN_WIDTH-10)/4)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight-BottomBarHeight), collectionViewLayout: layout)
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
        self.backBtn.setTitle("返回".localize, for: .normal)
        self.backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backBtn!)
        
        self.toolbar = CDToolBar(frame: CGRect(x: 0, y: CDViewHeight - BottomBarHeight, width: CDSCREEN_WIDTH, height: BottomBarHeight),barType: .VideoTools, superVC: self)
        self.view.addSubview(self.toolbar)
        super.addObserver(super.self, forKeyPath: "fileArr", options: [.new,.old], context: nil)


    }
    
    // MARK:批量按钮
    @objc func batchBtnClick(){
        batchHandleFiles(isBatch: !batchBtn.isSelected)
    }
    
    private func batchHandleFiles(isBatch:Bool) -> Void {
        selectCount = 0
        batchBtn.isSelected = isBatch
        if (batchBtn.isSelected) { //点了批量操作
            backBtn.setTitle("全选".localize, for: .normal)
            batchBtn.setImage(UIImage(named: "no_edit"), for: .normal)
            toolbar.hiddenReloadBar(isMulit: true)
        } else {
            backBtn.setTitle("返回".localize, for: .normal)
            batchBtn.setImage(UIImage(named: "edit"), for: .normal)
            toolbar.hiddenReloadBar(isMulit: false)
            fileArr.forEach { (tmpFile) in
                tmpFile.isSelected = .no
            }
            
        }
        collectionView.reloadData()
    }
    
    //返回
    @objc func backBtnClick() -> Void {
        if batchBtn.isSelected { //
            selectedVideoArr.removeAll()
            if (self.backBtn.currentTitle == "全选".localize) { //全选
                fileArr.forEach { (file) in
                    file.isSelected = .yes
                }
                selectCount = fileArr.count
            }else{
                fileArr.forEach { (file) in
                    file.isSelected = .no
                }
                selectCount = 0
            }
            refreshUI()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func refreshUI(){
        toolbar.enableReloadBar(isEnable: selectCount > 0)
        //视频拼接只能2-5个
        toolbar.appendItem.isEnabled = (selectCount >= 2 && selectCount <= 5)
        if selectCount == fileArr.count && fileArr.count > 0{
            backBtn.frame = CGRect(x: 0, y: 0, width: 88, height: 44)
            backBtn.contentHorizontalAlignment = .left
            backBtn.setTitle("全不选".localize, for: .normal)
        }else{
            backBtn.setTitle("全选".localize, for: .normal)
        }
        collectionView.reloadData()
    }
    func refreshData() {
        selectedVideoArr.removeAll()
        toolbar.enableReloadBar(isEnable: false)
        fileArr = CDSqlManager.shared.queryAllFileFromFolder(folderId: folderInfo.folderId)
        collectionView.reloadData()
    }
    
    func handelSelectedArr(){
        selectedVideoArr.removeAll()
        selectedVideoArr = fileArr.filter({ (tmp) -> Bool in
            tmp.isSelected == .yes
        })
    }
    
    //MARK:分享事件
    @objc func shareBarItemClick(){
        handelSelectedArr()
        var shareArr:[NSObject] = []
        for index in 0..<self.selectedVideoArr.count{
            let file:CDSafeFileInfo = self.selectedVideoArr[index]
            let videoPath = String.RootPath().appendingPathComponent(str: file.filePath)
            let url = videoPath.url
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
        let folderList = CDPickerFolderViewController()
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
        let alert = UIAlertController(title: nil, message: "您确定要导出选中的图片到系统相册？".localize, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: { (action) in }))
        alert.addAction(UIAlertAction(title: "确定".localize, style: .default, handler: { (action) in
            DispatchQueue.main.async  {
                CDHUDManager.shared.showWait("正在处理中...".localize)
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
                let videoPath = String.RootPath().appendingPathComponent(str: file.filePath)
                let compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)
                if compatible{
                    UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, #selector(outputVideoComplete(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                }else{
                    let filsC:CDSafeFileInfo = outputVideoArr[0];
                    let thumpVideoPath = String.RootPath().appendingPathComponent(str: filsC.thumbImagePath)
                    thumpVideoPath.delete()
                    outputVideoArr.remove(at: 0)
                    outputVideoToLocal()
                }
                
            }
        }else{
            CDHUDManager.shared.hideWait()
            CDHUDManager.shared.showComplete("导出完成！".localize)
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
        let btnTitle = selectedVideoArr.count > 1 ? String(format: "删除%d条视频".localize, selectedVideoArr.count) : "删除视频".localize
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: btnTitle, style: .destructive, handler: { (action) in
            CDHUDManager.shared.showWait("正在处理中...".localize)
            DispatchQueue.global().async {
                
                self.selectedVideoArr.forEach { (tmpFile) in
                    let thumbPath = String.RootPath().appendingPathComponent(str: tmpFile.thumbImagePath)
                    thumbPath.delete()
                    let defaultPath = String.RootPath().appendingPathComponent(str: tmpFile.filePath)
                    defaultPath.delete()
                    CDSqlManager.shared.deleteOneSafeFile(fileId: tmpFile.fileId)
                
                    //删除元数据数组
                    let index = self.fileArr.firstIndex(of: tmpFile)
                    self.fileArr.remove(at: index!)
                }
                DispatchQueue.main.async {
                    CDHUDManager.shared.hideWait()
                    CDHUDManager.shared.showComplete("删除完成".localize)
                    self.batchHandleFiles(isBatch: false)
                }
            }
            
        }))
        sheet.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }

    //MARK:视频剪辑
    @objc func appendItemClick(){
        handelSelectedArr()
        
        let sheet = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "拼接视频".localize, style: .destructive, handler: { (action) in
            let appendVC = CDComposeGifViewController()
            appendVC.fileArr = self.selectedVideoArr
            appendVC.folderId = self.folderInfo.folderId
            appendVC.composeType = .Video
            appendVC.composeHandle = {[unowned self](success) -> Void in

                //拼接产生新的数据，更新DB数据源
                self.refreshData()
                //取消批量操作，更新DB时，所有本地数据重新从DB中更新，无需重复操作
                self.batchHandleFiles(isBatch: false)
            }
            
            
            self.navigationController?.pushViewController(appendVC, animated: true)
            
        }))
        sheet.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: nil))
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
    @objc func importItemClick() -> Void {
        checkPermission(type: . library) { (isAllow) in
            if isAllow {
                DispatchQueue.main.async {
                    let elcPicker = CDMediaPickerViewController(isVideo: true)
                    elcPicker.pickerDelegate = self
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
        super.docuemntPickerComplete = {[weak self](_ success:Bool) -> Void in
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
        return fileArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCellIdrr", for: indexPath) as! CDImageCell
        let tmpFile:CDSafeFileInfo = fileArr[indexPath.item]
        cell.setVideoData(fileInfo: tmpFile,isMutilEdit: batchBtn.isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell:CDImageCell = collectionView.cellForItem(at: indexPath) as! CDImageCell
        
        if batchBtn.isSelected{
            let tmFile = fileArr[indexPath.item]
            if tmFile.isSelected == .no {
                cell.isSelected = true
                selectCount += 1
                tmFile.isSelected = .yes
            }else{
                cell.isSelected = false
                selectCount -= 1
                tmFile.isSelected = .no
            }
            cell.reloadSelectImageView()
            refreshUI()
            
        }else{
            let scrollerVC = CDVideoScrollerViewController()
            scrollerVC.fileArr = fileArr
            scrollerVC.currentIndex = indexPath.item
            scrollerVC.folderId = folderInfo.folderId
            self.navigationController?.pushViewController(scrollerVC, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


extension CDVideoViewController:CDCameraViewControllerDelegate{
    func onCameraTakeVideoDidFinshed(cameraVC: CDCameraViewController, obj: [String : Any?]) {
        isNeedReloadData = true
        let videoUrl = obj["fileURL"] as! URL
        CDSignalTon.shared.saveFileWithUrl(fileUrl: videoUrl, folderId: folderInfo.folderId, subFolderType: .VideoFolder,isFromDocment: false)
        CDSignalTon.shared.customPickerView = nil
//        cameraVC.dismiss(animated: false, completion: nil)
    }
}

extension CDVideoViewController:CDMediaPickerViewControllerDelegate{
    func onMediaPickerDidCancle(picker: CDMediaPickerViewController) {
        CDSignalTon.shared.customPickerView = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    func onMediaPickerDidFinished(picker: CDMediaPickerViewController, data: [String : Any?], index: Int, totalCount: Int) {
        let tmpUrl = data["fileURL"] as! URL
        
        CDSignalTon.shared.saveFileWithUrl(fileUrl: tmpUrl, folderId: folderInfo
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
                CDHUDManager.shared.showComplete("导入完成！".localize)
            } else {
                if index == 1 { //第一个出现进度条
                    CDHUDManager.shared.showProgress("开始导入...".localize)
                    CDHUDManager.shared.updateProgress(num: Float(index)/Float(totalCount), text: "第\(index)个 共\(totalCount)个")
                } else if index == totalCount {
                    
                    CDHUDManager.shared.updateProgress(num: Float(index)/Float(totalCount), text: "第\(index)个 共\(totalCount)个")
                    CDHUDManager.shared.hideProgress()
                    CDHUDManager.shared.showComplete("导入完成！".localize)
                    pickOver()
                }else{
                    CDHUDManager.shared.updateProgress(num: Float(index)/Float(totalCount), text: "第\(index)个 共\(totalCount)个")
                }
                
            }
        }
    }
    
    
}
