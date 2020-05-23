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
class CDVideoViewController: CDBaseAllViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CDMediaPickerDelegate,CDCameraViewControllerDelegate {
    
    
    
    
    
    public var folderInfo:CDSafeFolder!
    
    private var toolbar:CDToolBar!
    private var editBtn:UIButton!
    private var backBtn:UIButton!
    private var collectionView:UICollectionView!
    private var videoArr:[CDSafeFileInfo] = []
    private var selectCount:Int = 0 //选择的数量
    private var selectedVideoArr:[CDSafeFileInfo] = [] //存放选中的视频
    private var outputVideoArr:[CDSafeFileInfo] = []   //临时存放需要导出的视频，串行，导出一个删一个
    private var isNeedReloadData:Bool = false
    
    deinit {
        removeNotification()
    }
    override func viewWillAppear(_ animated: Bool) {
        if isNeedReloadData {
            isNeedReloadData = false
            refreshData()
        }
    }
    
    func handelSelectedArr(){
        selectedVideoArr.removeAll()
        videoArr.forEach { (file) in
            if file.isSelected == .CDTrue {
                selectedVideoArr.append(file)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "视频文件"
        isNeedReloadData = true
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:(CDSCREEN_WIDTH-20)/4 , height: (CDSCREEN_WIDTH-20)/4)
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
        
        self.editBtn = UIButton(type: .custom)
        self.editBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        self.editBtn.setImage(UIImage(named: "edit"), for: .normal);
        self.editBtn.addTarget(self, action: #selector(multisEditBtnClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.editBtn!)
        
        self.backBtn = UIButton(type: .custom)
        self.backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        self.backBtn.setTitle("返回", for: .normal)
        self.backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backBtn!)
        
        self.toolbar = CDToolBar(frame: CGRect(x: 0, y: CDViewHeight-48, width: CDSCREEN_WIDTH, height: 48), foldertype: .ImageFolder, superVC: self)
        self.view.addSubview(self.toolbar)
        
        registerNotification()
    }
    func refreshData() {
        selectedVideoArr.removeAll()
        toolbar.enableReloadBar(isSelected: false)
        videoArr = CDSqlManager.instance().queryAllFileFromFolder(folderId: folderInfo.folderId)
        collectionView.reloadData()
    }
    //多选
    @objc func multisEditBtnClick() -> Void {
        selectCount = 0
        self.editBtn.isSelected = !(self.editBtn.isSelected)
        if (self.editBtn.isSelected) { //点了选择操作
            //1.返回变全选
            self.backBtn.setTitle("全选", for: .normal)
            self.editBtn.setImage(UIImage(named: "no_edit"), for: .normal)
            //2.拍照，导入变成操作按钮
            toolbar.hiddenReloadBar(isMulit: true)
            videoArr.forEach { (file) in
                file.isSelected = .CDFalse
            }
            
        }else{
            //1.返回变全选
            self.backBtn.setTitle("返回", for: .normal)
            self.editBtn.setImage(UIImage(named: "edit"), for: .normal)
            //2.拍照，导入变成操作按钮
            toolbar.hiddenReloadBar(isMulit: false)
            selectedVideoArr.removeAll()
            
        }
        collectionView.reloadData()
    }
    
    //返回
    @objc func backBtnClick() -> Void {
        if editBtn.isSelected { //
            selectedVideoArr.removeAll()
            if (self.backBtn.titleLabel?.text == "全选") { //全选
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
        if selectCount > 0 {
            toolbar.enableReloadBar(isSelected: true)
            if selectCount < 2 || selectCount > 5 { //视频拼接只能2-5个
                toolbar.appendItem.isEnabled = false
            }else{
                toolbar.appendItem.isEnabled = true
            }
        }else{
            toolbar.enableReloadBar(isSelected: false)
        }
        if selectCount == videoArr.count {
            backBtn.frame = CGRect(x: 0, y: 0, width: 88, height: 44)
            backBtn.contentHorizontalAlignment = .left
            backBtn.setTitle("全不选", for: .normal)
        }else{
            backBtn.setTitle("全选", for: .normal)
        }
        collectionView.reloadData()
    }
    //TODO:分享事件
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
            self.multisEditBtnClick()
        }
        
    }
    //TODO:移动
    @objc func moveBarItemClick(){
        isNeedReloadData = false
        handelSelectedArr()
        let folderList = CDFolderListViewController()
        folderList.title = "文件夹列表"
        folderList.selectedArr = selectedVideoArr
        folderList.folderType = .ImageFolder
        folderList.folderId = folderInfo.folderId
        self.navigationController?.pushViewController(folderList, animated: true)
        
    }
    //TODO:导出
    @objc func outputBarItemClick(){
        handelSelectedArr()
        let alert = UIAlertController(title: nil, message: "您确定要导入选中的视频到系统相册？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            DispatchQueue.main.async  {
                CDHUDManager.shareInstance().showWait(text: "处理中...")
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
                    fileManagerDeleteFileWithFilePath(filePath: thumpVideoPath)
                    outputVideoArr.remove(at: 0)
                    outputVideoToLocal()
                }
                
            }
        }else{
            CDHUDManager.shareInstance().hideWait()
            CDHUDManager.shareInstance().showComplete(text: "导出完成！")
            self.refreshData()
            self.multisEditBtnClick()
        }
        
    }

    @objc private func outputVideoComplete(videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        //导出成功后删除数组第一个,继续导出操作
        outputVideoArr.remove(at: 0)
        outputVideoToLocal()
    }
    
    //TODO:删除
    @objc func deleteBarItemClick(){
        handelSelectedArr()
        var btnTitle = String()
        
        if selectedVideoArr.count > 1{
            btnTitle = "删除\(selectedVideoArr.count)条视频"
        }else{
            btnTitle = "删除视频"
        }
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: btnTitle, style: .destructive, handler: { (action) in
            CDHUDManager.shareInstance().showWait(text: "处理中...")
            DispatchQueue.global().async {
                self.deleteTheSelectVideo()
            }
            
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    func deleteTheSelectVideo() -> Void {
        for index in 0..<selectedVideoArr.count{
            let fileInfo = selectedVideoArr[index]
            //删除加密小题
            let thumbPath = String.thumpImagePath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
            fileManagerDeleteFileWithFilePath(filePath: thumbPath)
            //删除加密大图
            let defaultPath = String.ImagePath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
            fileManagerDeleteFileWithFilePath(filePath: defaultPath)
            CDSqlManager.instance().deleteOneSafeFile(fileId: fileInfo.fileId)
        }
        DispatchQueue.main.async {
            CDHUDManager.shareInstance().hideWait()
            CDHUDManager.shareInstance().showComplete(text: "删除完成！")
            self.refreshData()
            self.multisEditBtnClick()
        }
    }
    
    
    //TODO:拍照
    @objc func takePhotoClick() -> Void {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if authStatus == .denied ||
                authStatus == .restricted{
                
                let alert = UIAlertController(title: "相机访问被拒绝", message: "请在”设置-隐私-相机“中，允许相机访问本应用", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                                let camera = CDCameraViewController()
                                camera.delegate = self
                                camera.isVideo = true
                camera.modalPresentationStyle = .fullScreen
                                self.present(camera, animated: true, completion: nil)
//                let pickVC = UIImagePickerController();
//                pickVC.sourceType = .camera;
//                pickVC.mediaTypes = ["public.movie"]
//                pickVC.allowsEditing = true
//                pickVC.delegate = self
//                present(pickVC, animated: true, completion: nil)
                
                
            }
            
        }
        
    }
    //TODO:导入
    @objc func inputItemClick() -> Void {
        //保持屏幕常亮
        let elcPicker = CDMediaPickerViewController(isVideo: true)
        elcPicker.pickerDelegate = self
        CDAssetTon.shareInstance().mediaType = .CDMediaVideo
        elcPicker.folderId = folderInfo.folderId
        CDSignalTon.shareInstance().customPickerView = elcPicker
        elcPicker.modalPresentationStyle = .fullScreen
        self.present(elcPicker, animated: true, completion: nil)
    }
    
    //TODO:视频剪辑
    @objc func appendItemClick(){
        handelSelectedArr()
        
        let sheet = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "拼接视频", style: .destructive, handler: { (action) in
            CDHUDManager.shareInstance().showWait(text: "正在处理...")
            DispatchQueue.global().async {
                self.deleteBarItemClick()
            }
            
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    //TODO:沙盒导入
    @objc func documentItemClick(){
        let documentTypes = ["public.movie"]
        super.subFolderId = folderInfo.folderId
        super.subFolderType = folderInfo.folderType
        super.processHandle = {(_ success:Bool) -> Void in
            if success {
                self.refreshData()
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
        cell.setVideoData(fileInfo: tmpFile,isMutilEdit: editBtn.isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell:CDImageCell = collectionView.cellForItem(at: indexPath) as! CDImageCell
        
        if editBtn.isSelected{
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
    
    
    
    //TODO:CDMeidaPickerDelegate
    func mediaPickerDidFinished(picker: CDMediaPickerViewController, data: NSObject, index: Int, totalCount: Int) {
        CDSignalTon.shareInstance().customPickerView = nil
        picker.dismiss(animated: true, completion: nil)
    }
     
    
     
     func mediaPickerDidCancle(picker: CDMediaPickerViewController) {
         CDSignalTon.shareInstance().customPickerView = nil
         picker.dismiss(animated: true, completion: nil)
     }
    
    
    func onCameraTakePhotoDidFinshed(cameraVC: CDCameraViewController, videoUrl: URL) {
        //        let time = getCurrentTimestamp()
        //        let savePath = String.ImagePath().appendingPathComponent(str: "\(time).jpg")
        //        let thumbPath = String.thumpImagePath().appendingPathComponent(str: "\(time).jpg")
        //        let smallImage = imageCompressForSize(image: image, maxWidth: 1280)
        //        do{
        //            let imageData = UIImageJPEGRepresentation(smallImage, 0.5)
        //            try imageData?.write(to: URL(fileURLWithPath: savePath))
        //        }catch{
        //
        //        }
        //
        //        let thumbImage = scaleImageAndCropToMaxSize(image: image, newSize: CGSize(width: 200, height: 200))
        //        let tmpData:Data = UIImageJPEGRepresentation(thumbImage, 1.0)! as Data
        //
        //        do {
        //            try tmpData.write(to: URL(fileURLWithPath: thumbPath))
        //        } catch  {
        //
        //        }
        //        let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
        //        fileInfo.folderId = folderId
        //        fileInfo.fileName = "未命名"
        //        fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: savePath)
        //        fileInfo.thumbImagePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: thumbPath)
        //        fileInfo.fileSize = getFileSizeAtPath(filePath: savePath)
        //        fileInfo.fileWidth = Double(image.size.width)
        //        fileInfo.fileHeight = Double(image.size.height)
        //        fileInfo.createTime = Int(time)
        //        fileInfo.fileType = .ImageType
        //        fileInfo.userId = CDUserId()
        //        CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)
    }
    func onCameraTakePhotoDidCancle(cameraVC: CDCameraViewController) {
        CDSignalTon.shareInstance().customPickerView = nil
        cameraVC.dismiss(animated: true, completion: nil)
    }
    //TODO:NSNotications
    @objc func needReloadData() {
        isNeedReloadData = true
    }
    
    //TODO:pick-delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        print(info)
        picker.dismiss(animated: true, completion: nil)
        let videoUrl = info[.mediaURL] as! URL
        let videoAsset = AVURLAsset(url: videoUrl);
        let timeLength = Double(videoAsset.duration.value) / Double(videoAsset.duration.timescale)
        let time = getCurrentTimestamp()
        let videoPath = String.VideoPath().appendingPathComponent(str: "/\(time).mp4")
        let fileName = "\(time).mp4"
        
        if !FileManager.default.fileExists(atPath: videoPath) {
            let data:NSData = NSData(contentsOf: videoUrl)!
            FileManager.default.createFile(atPath: videoPath, contents: data as Data, attributes: nil)
        }
        let thump = String.thumpVideoPath().appendingPathComponent(str: "\(time).jpg")
        //第一帧
        let image = CDSignalTon.shareInstance().firstFrmaeWithTheVideo(videoPath: videoPath)
        let data = image.jpegData(compressionQuality: 1.0)
        do {
            try data?.write(to: URL(fileURLWithPath: thump))
        } catch  {
            
        }
        let fileInfo = CDSafeFileInfo()
        fileInfo.folderId = folderInfo.folderId
        fileInfo.userId = CDUserId()
        fileInfo.fileName = fileName
        fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: videoPath)
        fileInfo.thumbImagePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: thump)
        let fileSize = getFileSizeAtPath(filePath: videoPath)
        fileInfo.fileSize = fileSize
        fileInfo.timeLength = timeLength
        fileInfo.createTime = time
        fileInfo.fileType = .VideoType
        CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)
        refreshData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: NeedReloadData, object: nil)
    }
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(needReloadData), name: NeedReloadData, object: nil)
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
