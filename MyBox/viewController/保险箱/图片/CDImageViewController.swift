//
//  CDImageViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import AVFoundation
import MJRefresh
import CDMediaPicker


class CDImageViewController:
    CDBaseAllViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate{
    
    
    public var folderInfo:CDSafeFolder!
    
    private var toolbar:CDToolBar!
    private var batchBtn:UIButton!
    private var backBtn:UIButton!
    private var collectionView:UICollectionView!
    private var mjHeader:MJRefreshNormalHeader!
    private var mjFooter:MJRefreshAutoNormalFooter!
    @objc dynamic private var fileArr:[CDSafeFileInfo] = []
    private var selectedImageArr:[CDSafeFileInfo] = []
    private var outputImageArr:[CDSafeFileInfo] = []
    private var isNeedReloadData:Bool = false
    private var selectCount:Int = 0
    private var selectGifCount:Int = 0
    deinit {
        super.removeObserver(self, forKeyPath: "fileArr")
    }
    override func viewWillAppear(_ animated: Bool) {
        if isNeedReloadData {
            isNeedReloadData = false
            refreshDBData()
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
        self.toolbar = CDToolBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - BottomBarHeight, width: CDSCREEN_WIDTH, height: BottomBarHeight),barType: .ImageTools, superVC: self)
        self.view.addSubview(self.toolbar)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: self.toolbar.minY), collectionViewLayout: layout)
        collectionView.register(CDImageCell.self, forCellWithReuseIdentifier: "imageCellIdrr")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView!)
//        mjHeader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
//        collectionView.mj_header = mjHeader
//private var mjHeader:MJRefreshNormalHeader!
//        mjFooter = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(footerRefresh))
//        collectionView.mj_footer = mjFooter
        batchBtn = UIButton(type: .custom)
        batchBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        batchBtn.setImage(UIImage(named: "edit"), for: .normal);
        batchBtn.addTarget(self, action: #selector(batchBtnClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: batchBtn)

        self.backBtn = UIButton(type: .custom)
        self.backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        self.backBtn.setTitle("返回".localize, for: .normal)
        self.backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backBtn!)


        super.addObserver(super.self, forKeyPath: "fileArr", options: [.new,.old], context: nil)

    }
    @objc func footerRefresh(){

    }
    @objc func headerRefresh(){

    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    // MARK:批量按钮
    @objc func batchBtnClick(){
        batchHandleFiles(isBatch: !batchBtn.isSelected)
    }
    
    func batchHandleFiles(isBatch:Bool) -> Void {
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

    // MARK:返回
    @objc func backBtnClick() -> Void {
        if batchBtn.isSelected {
            selectedImageArr.removeAll()
            if (self.backBtn.currentTitle == "全选".localize) { //全选
                fileArr.forEach { (file) in
                    file.isSelected = .yes
                    if file.fileType == .GifType {
                        selectGifCount += 1
                    }
                }
                selectCount = fileArr.count
            } else {//全不选
                fileArr.forEach { (file) in
                    file.isSelected = .no
                }
                selectCount = 0
                selectGifCount = 0
            }
            refreshUI()
        } else {
            self.navigationController?.popViewController(animated: true)
        }

    }
    func refreshUI(){
        toolbar.enableReloadBar(isEnable: selectCount > 0)
        toolbar.appendItem.isEnabled = (selectCount <= 16 && selectCount >= 2) && selectGifCount == 0
        if selectCount == fileArr.count && fileArr.count > 0{
            backBtn.frame = CGRect(x: 0, y: 0, width: 88, height: 44)
            backBtn.contentHorizontalAlignment = .left
            backBtn.setTitle("全不选".localize, for: .normal)
        } else {
            backBtn.setTitle("全选".localize, for: .normal)
        }
        collectionView.reloadData()
    }
    
    func refreshDBData() {
        //沙盒导入，拍照，图库，拼接刷新DB数据源
        selectedImageArr.removeAll()
        toolbar.enableReloadBar(isEnable: false)
        fileArr = CDSqlManager.shared.queryAllFileFromFolder(folderId: folderInfo.folderId)
        collectionView.reloadData()
    }
    
    func handelSelectedArr(){
        selectedImageArr.removeAll()
        selectedImageArr = fileArr.filter({ (tmp) -> Bool in
            tmp.isSelected == .yes
        })
        
    }
    //MARK:分享事件
    @objc func shareBarItemClick(){
        handelSelectedArr()
        var shareArr:[NSObject] = []
        for index in 0..<self.selectedImageArr.count{
            let file:CDSafeFileInfo = self.selectedImageArr[index]
            let imagePath = String.RootPath().appendingPathComponent(str: file.filePath)
            
            let image = UIImage(contentsOfFile: imagePath)!
            shareArr.append(image)
        }
        
        presentShareActivityWith(dataArr: shareArr) {[unowned self] (error) in
            
            //分享完成，取消批量操作，恢复数据至未选状态
            self.batchHandleFiles(isBatch: false)
        }
    }
    // MARK:移动
    @objc func moveBarItemClick(){

        handelSelectedArr()
        let folderList = CDPickerFolderViewController()
        folderList.selectedArr = selectedImageArr
        folderList.folderType = .ImageFolder
        folderList.folderId = folderInfo.folderId
        folderList.moveHandle = {(_ success:Bool) -> Void in
            //移动返回后，删除移动数据源，取消批量操作,选中数据源以删除，不用恢复
            self.batchHandleFiles(isBatch: false)
        }
        self.navigationController?.pushViewController(folderList, animated: true)

    }
    
    // MARK:导出
    @objc func outputBarItemClick(){
        handelSelectedArr()
        let outAlert = UIAlertController(title: nil, message:"您确定要导出选中的视频到系统相册？".localize, preferredStyle: .alert)
        outAlert.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: { (action) in }))
        outAlert.addAction(UIAlertAction(title: "确定".localize, style: .default, handler: { (action) in
            DispatchQueue.main.async {
                CDHUDManager.shared.showWait("正在处理中...".localize)
                self.outputImageArr = self.selectedImageArr
                self.outputPhotoToLocal()
            }
        }))
        present(outAlert, animated: false, completion: nil)

    }
    func outputPhotoToLocal() -> Void {
        if self.outputImageArr.count > 0 {
            let file:CDSafeFileInfo = self.outputImageArr[0]
            let imagePath = String.RootPath().appendingPathComponent(str: file.filePath)
            let imageD:UIImage! = UIImage(contentsOfFile: imagePath)
            UIImageWriteToSavedPhotosAlbum(imageD, self, #selector(outputPhotoComplete(image:didFinishSavingWithError:contextInfo:)), nil)

        } else {
            DispatchQueue.main.async {
                CDHUDManager.shared.hideWait()
                CDHUDManager.shared.showComplete("导出完成！".localize)
                //导出完成后，取消批量操作,恢复选中数据源
                self.batchHandleFiles(isBatch: false)
            }

        }
    }
    @objc private func outputPhotoComplete(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        outputImageArr.remove(at: 0)
        outputPhotoToLocal()
    }

    // MARK:删除
    @objc func deleteBarItemClick(){
        handelSelectedArr()
        func deleteTheSelectImage() -> Void {
            selectedImageArr.forEach { (tmpFile) in
                
                let thumbPath = String.RootPath().appendingPathComponent(str: tmpFile.thumbImagePath)
                thumbPath.delete()
                
                let defaultPath = String.RootPath().appendingPathComponent(str: tmpFile.filePath)
                defaultPath.delete()
                CDSqlManager.shared.deleteOneSafeFile(fileId: tmpFile.fileId)
                
                let index = fileArr.firstIndex(of: tmpFile)
                fileArr.remove(at: index!)
            }
            DispatchQueue.main.async {
                 //删除操作后，删除本地数据源中被删除的元素，取消批量操作,选中数据源以删除，不用恢复
                self.batchHandleFiles(isBatch: false)
                CDHUDManager.shared.hideWait()
                CDHUDManager.shared.showComplete("删除完成".localize)
                
            }
        }
        
        
        let btnTitle = selectedImageArr.count > 1 ? String(format: "删除%d张图片", selectedImageArr.count):"删除照片".localize
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: btnTitle, style: .destructive, handler: { (action) in
            CDHUDManager.shared.showWait("正在处理中...".localize)
            DispatchQueue.global().async {
                deleteTheSelectImage()
            }
        }))
        sheet.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)

    }
    
    // MARK:拼接
    @objc func appendItemClick(){
        handelSelectedArr()
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        sheet.addAction(UIAlertAction(title: "拼图", style: .default, handler: { (action) in
//            let puzzleVC = CDPuzzleViewController()
//           self.navigationController?.pushViewController(puzzleVC, animated: true)
//        }))

        sheet.addAction(UIAlertAction(title: "合成GIF".localize, style: .default, handler: { (action) in
            let gifVC = CDComposeGifViewController()
            gifVC.fileArr = self.selectedImageArr
            gifVC.folderId = self.folderInfo.folderId
            gifVC.composeType = .Gif
            gifVC.composeHandle = {(success) -> Void in
                //拼接产生新的数据，更新DB数据源
                self.refreshDBData()
                //取消批量操作，更新DB时，所有本地数据重新从DB中更新，无需重复操作
                self.batchHandleFiles(isBatch: false)
            }
            self.navigationController?.pushViewController(gifVC, animated: true)

        }))
        sheet.addAction(UIAlertAction(title: "合成视频".localize, style: .default, handler: { (action) in
            let videoVC = CDComposeVideoViewController()
            self.navigationController?.pushViewController(videoVC, animated: true)

        }))
        sheet.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    //MARK: document
    @objc func documentItemClick(){
        let documentTypes = ["public.image"]
        super.subFolderId = folderInfo.folderId
        super.subFolderType = folderInfo.folderType
        super.docuemntPickerComplete = {(_ success:Bool) -> Void in
            if success {
                self.refreshDBData()
            }
        }
        presentDocumentPicker(documentTypes: documentTypes)
    }
    //MARK:拍照
    @objc func takePhotoClick() -> Void {
        
        checkPermission(type: .camera) { (isAllow) in
            if isAllow {
                DispatchQueue.main.async {
                    let camera = CDCameraViewController()
                    camera.delegate = self
                    camera.isVideo = false
                    camera.modalPresentationStyle = .fullScreen
                    CDSignalTon.shared.customPickerView = camera
                    self.present(camera, animated: true, completion: nil)
                }
            } else {
                
                
                openPermission(type: .camera, viewController: self)
            }
        }
        
    }
    //MARK:导入
    @objc func importItemClick() -> Void {
        checkPermission(type: .library) { (isAllow) in
             if isAllow {
                DispatchQueue.main.async {
                    //保持屏幕常亮
                    UIApplication.shared.isIdleTimerDisabled = true
                    
                    let cdPicker = CDMediaPickerViewController(isVideo: false)
                    cdPicker.pickerDelegate = self
                    
                    CDSignalTon.shared.customPickerView = cdPicker
                    cdPicker.modalPresentationStyle = .fullScreen
                    self.present(cdPicker, animated: true, completion: nil)
                    
                }
                
             } else {
                openPermission(type: .library, viewController: self)
            }
        }
        
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCellIdrr", for: indexPath) as! CDImageCell
        let tmpFile:CDSafeFileInfo = fileArr[indexPath.item]
        cell.setImageData(fileInfo: tmpFile,isBatchEdit: batchBtn.isSelected)
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:CDImageCell = collectionView.cellForItem(at: indexPath) as! CDImageCell
        if batchBtn.isSelected{
            let tmFile = fileArr[indexPath.item]
            if tmFile.isSelected == .no { //本地点击之前未选中
                cell.isSelected = true
                selectCount += 1
                tmFile.isSelected = .yes
                if tmFile.fileType == .GifType {
                    selectGifCount += 1
                }
            } else {
                cell.isSelected = false
                selectCount -= 1
                tmFile.isSelected = .no
                if tmFile.fileType == .GifType {
                    selectGifCount -= 1
                }
            }
            cell.reloadSelectImageView()
            
            refreshUI()
        } else {
            self.isNeedReloadData = true
            let scrollerVC = CDImageScrollerViewController()
            scrollerVC.currentIndex = indexPath.item
            scrollerVC.inputArr = fileArr
            scrollerVC.folderId = folderInfo.folderId
            self.navigationController?.pushViewController(scrollerVC, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

}


extension CDImageViewController:CDMediaPickerViewControllerDelegate{
    func onMediaPickerDidFinished(picker: CDMediaPickerViewController, data: [String : Any?], index: Int, totalCount: Int) {
        CDSignalTon.shared.saveOrigialImage(obj: data, folderId: folderInfo.folderId)
        if index == 1 { //第一个出现进度条
            DispatchQueue.main.async {
                CDHUDManager.shared.showProgress("开始导入...".localize)
                CDHUDManager.shared.updateProgress(num: Float(index)/Float(totalCount), text: "第\(index)个 共\(totalCount)个")
            }
        }
        if index == totalCount  {
            DispatchQueue.main.async {
                CDSignalTon.shared.customPickerView = nil
                picker.dismiss(animated: true, completion: nil)
                self.refreshDBData()
                CDHUDManager.shared.showComplete("导入完成！".localize)
                CDHUDManager.shared.hideProgress()
            }
        }else{
            DispatchQueue.main.async {
                CDHUDManager.shared.updateProgress(num: Float(index)/Float(totalCount), text: "第\(index)个 共\(totalCount)个")
            }
        }
    }

    
}

extension CDImageViewController:CDCameraViewControllerDelegate{
    func onCameraTakePhotoDidFinshed(cameraVC: CDCameraViewController, obj: [String : Any?]) {
        CDSignalTon.shared.saveOrigialImage(obj: obj, folderId: folderInfo.folderId)
        self.isNeedReloadData = true
        CDSignalTon.shared.customPickerView = nil
//        cameraVC.dismiss(animated: true, completion: nil)
    }
    
    func onMediaPickerDidCancle(picker: CDMediaPickerViewController) {
        CDSignalTon.shared.customPickerView = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

