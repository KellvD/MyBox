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
enum CDHandleType {
    case discover
    case delete
    case nothing
}
class CDImageViewController:
    CDBaseAllViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    CDMediaPickerDelegate,
    CDCameraViewControllerDelegate {
    
    public var folderInfo:CDSafeFolder!
    
    private var toolbar:CDToolBar!
    private var batchBtn:UIButton!
    private var backBtn:UIButton!
    private var collectionView:UICollectionView!
    private var mjHeader:MJRefreshNormalHeader!
    private var mjFooter:MJRefreshAutoNormalFooter!
    private var imageArr:[CDSafeFileInfo] = []
    private var selectedImageArr:[CDSafeFileInfo] = []
    private var outputImageArr:[CDSafeFileInfo] = []
    private var isNeedReloadData:Bool = false
    private var selectCount:Int = 0
    deinit {
        removeNotification()
    }
    override func viewWillAppear(_ animated: Bool) {
        if isNeedReloadData {
            isNeedReloadData = false
            refreshDBData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "图片文件"
        isNeedReloadData = true
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:(CDSCREEN_WIDTH-20)/4 , height: (CDSCREEN_WIDTH-20)/4)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical

        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight - 48), collectionViewLayout: layout)
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
        self.backBtn.setTitle("返回", for: .normal)
        self.backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backBtn!)

        self.toolbar = CDToolBar(frame: CGRect(x: 0, y: CDViewHeight-48, width: CDSCREEN_WIDTH, height: 48), foldertype: .ImageFolder, superVC: self)
        self.view.addSubview(self.toolbar)
        registerNotification()

    }
    @objc func footerRefresh(){

    }
    @objc func headerRefresh(){

    }
    // MARK:批量按钮
    @objc func batchBtnClick(){
        batchHandleFiles(isBatch: !batchBtn.isSelected,type: .nothing)
    }
    
    func batchHandleFiles(isBatch:Bool,type:CDHandleType) -> Void {
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
            selectedImageArr.forEach { (tmpFile) in
                let index = imageArr.firstIndex(of: tmpFile)
                if type == .discover {
                    tmpFile.isSelected = .CDFalse
                }else if type == .delete{
                    imageArr.remove(at: index!)
                }
            }
        }
        collectionView.reloadData()
    }

    // MARK:返回
    @objc func backBtnClick() -> Void {
        if batchBtn.isSelected { //
            selectedImageArr.removeAll()
            var hasGif = false
            if (self.backBtn.titleLabel?.text == "全选") { //全选
                imageArr.forEach { (file) in
                    file.isSelected = .CDTrue
                    if file.fileType == .GifType {
                        hasGif = true
                    }
                }
                selectCount = imageArr.count
            } else {
                imageArr.forEach { (file) in
                    file.isSelected = .CDFalse
                }
                selectCount = 0
            }
            refreshUI(hasGif: hasGif)
        } else {
            self.navigationController?.popViewController(animated: true)
        }

    }
    func refreshUI(hasGif:Bool){
        if selectCount > 0 {
            toolbar.enableReloadBar(isSelected: true)
            //拼图：2-16张，GIF不能拼
            if selectCount > 16 ||
                selectCount < 2 ||
                hasGif{
                toolbar.appendItem.isEnabled = false
            } else {
                toolbar.appendItem.isEnabled = true
            }
        } else {
            toolbar.enableReloadBar(isSelected: false)
        }
        if selectCount == imageArr.count {
            backBtn.frame = CGRect(x: 0, y: 0, width: 88, height: 44)
            backBtn.contentHorizontalAlignment = .left
            backBtn.setTitle("全不选", for: .normal)
        } else {
            backBtn.setTitle("全选", for: .normal)
        }
        collectionView.reloadData()
    }
    
    func refreshDBData() {
        //沙盒导入，拍照，图库，拼接刷新DB数据源
        selectedImageArr.removeAll()
        toolbar.enableReloadBar(isSelected: false)
        imageArr = CDSqlManager.instance().queryAllFileFromFolder(folderId: folderInfo.folderId)
        collectionView.reloadData()
    }
    
    func handelSelectedArr(){
        selectedImageArr.removeAll()
        imageArr.forEach { (file) in
            if file.isSelected == .CDTrue {
                selectedImageArr.append(file)
            }
        }
    }
    //MARK:分享事件
    @objc func shareBarItemClick(){
        handelSelectedArr()
        var shareArr:[NSObject] = []
        for index in 0..<self.selectedImageArr.count{
            let file:CDSafeFileInfo = self.selectedImageArr[index]
            let imagePath = String.ImagePath().appendingPathComponent(str: file.filePath.lastPathComponent())
            
            let image = UIImage(contentsOfFile: imagePath)!
            shareArr.append(image)
        }
        
        presentShareActivityWith(dataArr: shareArr) { (error) in
            //分享完成，取消批量操作，恢复数据至未选状态
            self.batchHandleFiles(isBatch: false, type: .discover)
        }
    }
    // MARK:移动
    @objc func moveBarItemClick(){

        handelSelectedArr()
        let folderList = CDFolderListViewController()
        folderList.title = "文件夹列表"
        folderList.selectedArr = selectedImageArr
        folderList.folderType = .ImageFolder
        folderList.folderId = folderInfo.folderId
        folderList.moveHandle = {(_ success:Bool) -> Void in
            //移动返回后，删除移动数据源，取消批量操作,选中数据源以删除，不用恢复
            self.batchHandleFiles(isBatch: false, type: .delete)
        }
        self.navigationController?.pushViewController(folderList, animated: true)

    }
    
    // MARK:导出
    @objc func outputBarItemClick(){
        handelSelectedArr()
        let outAlert = UIAlertController(title: nil, message: "您确定要导入选中的图片到系统相册？", preferredStyle: .alert)
        outAlert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in }))
        outAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                CDHUDManager.shared.showWait(text: "正在处理...")
                self.outputImageArr = self.selectedImageArr
                self.outputPhotoToLocal()
            }
        }))
        present(outAlert, animated: false, completion: nil)

    }
    func outputPhotoToLocal() -> Void {
        if self.outputImageArr.count > 0 {
            let file:CDSafeFileInfo = self.outputImageArr[0]
            let fileName = file.filePath.lastPathComponent()
            let imagePath = String.ImagePath().appendingPathComponent(str: fileName)
            let imageD:UIImage! = UIImage(contentsOfFile: imagePath)
            UIImageWriteToSavedPhotosAlbum(imageD, self, #selector(outputPhotoComplete(image:didFinishSavingWithError:contextInfo:)), nil)

        } else {
            DispatchQueue.main.async {
                CDHUDManager.shared.hideWait()
                CDHUDManager.shared.showComplete(text: "导出成功!")
                //导出完成后，取消批量操作,恢复选中数据源
                self.batchHandleFiles(isBatch: false, type: .discover)
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
            for index in 0..<selectedImageArr.count{
                let fileInfo = selectedImageArr[index]
                //删除加密小题
                let thumbPath = String.thumpImagePath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                fileManagerDeleteFileWithFilePath(filePath: thumbPath)
                //删除加密大图
                let defaultPath = String.ImagePath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
                fileManagerDeleteFileWithFilePath(filePath: defaultPath)
                CDSqlManager.instance().deleteOneSafeFile(fileId: fileInfo.fileId)
            }
            DispatchQueue.main.async {
                 //删除操作后，删除本地数据源中被删除的元素，取消批量操作,选中数据源以删除，不用恢复
                self.batchHandleFiles(isBatch: false, type: .delete)
                CDHUDManager.shared.hideWait()
                CDHUDManager.shared.showComplete(text: "删除完成！")
                
            }
        }
        
        
        let btnTitle = selectedImageArr.count > 1 ? "删除\(selectedImageArr.count)张图片":"删除照片"
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: btnTitle, style: .destructive, handler: { (action) in
            CDHUDManager.shared.showWait(text: "删除中...")
            DispatchQueue.global().async {
                deleteTheSelectImage()
            }
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)

    }
    
    // MARK:拼接
    @objc func appendItemClick(){
        handelSelectedArr()
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "拼图", style: .default, handler: { (action) in
            let puzzleVC = CDPuzzleViewController()
           self.navigationController?.pushViewController(puzzleVC, animated: true)
        }))

        sheet.addAction(UIAlertAction(title: "合成GIF", style: .default, handler: { (action) in
            let gifVC = CDComposeGifViewController()
            gifVC.fileArr = self.selectedImageArr
            gifVC.folderId = self.folderInfo.folderId
            gifVC.composeType = .Gif
            gifVC.composeHandle = {(success) -> Void in
                //拼接产生新的数据，更新DB数据源
                self.refreshDBData()
                //取消批量操作，更新DB时，所有本地数据重新从DB中更新，无需重复操作
                self.batchHandleFiles(isBatch: false, type: .nothing)
            }
            self.navigationController?.pushViewController(gifVC, animated: true)

        }))
        sheet.addAction(UIAlertAction(title: "合成视频", style: .default, handler: { (action) in
            let videoVC = CDComposeVideoViewController()
            self.navigationController?.pushViewController(videoVC, animated: true)

        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    //MARK: document
    @objc func documentItemClick(){
        let documentTypes = ["public.image"]
        super.subFolderId = folderInfo.folderId
        super.subFolderType = folderInfo.folderType
        super.processHandle = {(_ success:Bool) -> Void in
            if success {
                self.refreshDBData()
            }
        }
        presentDocumentPicker(documentTypes: documentTypes)
    }
    //MARK:拍照
    @objc func takePhotoClick() -> Void {

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if authStatus == .denied ||
                authStatus == .restricted{

                let alert = UIAlertController(title: "相机访问被拒绝", message: "请在”设置-隐私-相机“中，允许相机访问本应用", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
//                let camera = CDCameraViewController()
//                camera.delegate = self
//                camera.isVideo = false
//                camera.modalPresentationStyle = .fullScreen
//                CDSignalTon.shared.customPickerView = camera
//                self.present(camera, animated: true, completion: nil)
                
                let camera = GPUCameraViewController()
                camera.modalPresentationStyle = .fullScreen
                camera.isVideo = false
                self.present(camera, animated: true, completion: nil)
            }
        }
        
    }
    //MARK:导入
    @objc func inputItemClick() -> Void {
        //保持屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
        let cdPicker = CDMediaPickerViewController(isVideo: false)
        cdPicker.pickerDelegate = self
        CDAssetTon.shared.mediaType = .CDMediaImage
        CDSignalTon.shared.customPickerView = cdPicker
        cdPicker.modalPresentationStyle = .fullScreen
        self.present(cdPicker, animated: true, completion: nil)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCellIdrr", for: indexPath) as! CDImageCell
        let tmpFile:CDSafeFileInfo = imageArr[indexPath.item]
        cell.setImageData(fileInfo: tmpFile,isBatchEdit: batchBtn.isSelected)
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:CDImageCell = collectionView.cellForItem(at: indexPath) as! CDImageCell
        if batchBtn.isSelected{
            let tmFile = imageArr[indexPath.item]
            if tmFile.isSelected == .CDFalse { //本地点击之前未选中
                cell.isSelected = true
                selectCount += 1
                tmFile.isSelected = .CDTrue
            } else {
                cell.isSelected = false
                selectCount -= 1
                tmFile.isSelected = .CDFalse
            }
            cell.reloadSelectImageView()
            
            refreshUI(hasGif: tmFile.fileType == .GifType)
        } else {
            self.isNeedReloadData = true
            let scrollerVC = CDImageScrollerViewController()
            scrollerVC.currentIndex = indexPath.item
            scrollerVC.inputArr = imageArr
            self.navigationController?.pushViewController(scrollerVC, animated: true)
        }
    }

    
    //MARK:CDCameraViewControllerDelegate
    func onCameraTakePhotoDidFinshed(cameraVC: CDCameraViewController, obj: Dictionary<String, Any>) {
        CDSignalTon.shared.saveOrigialImage(obj: obj, folderId: folderInfo.folderId)
        self.isNeedReloadData = true
        CDSignalTon.shared.customPickerView = nil
        cameraVC.dismiss(animated: true, completion: nil)
    }
    //MARK:CDMeidaPickerDelegate
    func onMediaPickerDidFinished(picker: CDMediaPickerViewController, data: Dictionary<String, Any>, index: Int, totalCount: Int) {
        
        CDSignalTon.shared.saveOrigialImage(obj: data, folderId: folderInfo.folderId)
               if index == 1 { //第一个出现进度条
                   DispatchQueue.main.async {
                       CDHUDManager.shared.showProgress(text: "开始导入！")
                       CDHUDManager.shared.updateProgress(num: Float(index)/Float(totalCount), text: "第\(index)个 共\(totalCount)个")
                   }
               }
               if index == totalCount  {
                   DispatchQueue.main.async {
                       CDSignalTon.shared.customPickerView = nil
                       picker.dismiss(animated: true, completion: nil)
                       self.refreshDBData()
                       CDHUDManager.shared.hideProgress()
                       CDHUDManager.shared.showComplete(text: "导入完成！")
                   }
                   
               }else{
                   DispatchQueue.main.async {
                       CDHUDManager.shared.updateProgress(num: Float(index)/Float(totalCount), text: "第\(index)个 共\(totalCount)个")
                   }
                   
               }
    }


    func onMediaPickerDidCancle(picker: CDMediaPickerViewController) {
        CDSignalTon.shared.customPickerView = nil
        picker.dismiss(animated: true, completion: nil)
    }

    
    //MARK:NSNotications
    @objc func onNeedReloadData() {
        isNeedReloadData = true
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: NeedReloadData, object: nil)
    
    }
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNeedReloadData), name: NeedReloadData, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //    func onSelectedMediaPickerDidFinished(picker: CDMediaPickerViewController, info: NSMutableDictionary) {
    //        let defualtImagePath = info["savePath"] as! String
    //        let imageHeight = info["imageHeight"] as! Double
    //        let imageWidth = info["imageWidth"] as! Double
    //        let isLast = info["isLast"] as! Bool
    //        let time = info["time"] as! Int
    //        var fileName = info["fileName"] as! String
    //        let isGif = info["isGif"] as! Bool
    //
    //        let fileNameArr = fileName.components(separatedBy: ".")
    //        fileName = fileNameArr.first!
    //
    //        //缩略图路径
    //        let thumpImagePath = String.thumpImagePath().appendingFormat("/\(time).jpg")
    //        var bigData = Data()
    //        do {
    //            bigData = try Data(contentsOf: URL(fileURLWithPath: defualtImagePath))
    //        } catch  {
    //
    //        }
    //
    //        let defualtImage = UIImage(data:bigData)!
    //        let thumbImage = scaleImageAndCropToMaxSize(image: defualtImage, newSize: CGSize(width: 200, height: 200))
    //        let tmpData:Data = thumbImage.jpegData(compressionQuality: 1.0)! as Data
    //
    //        do {
    //            try tmpData.write(to: URL(fileURLWithPath: thumpImagePath))
    //        } catch  {
    //
    //        }
    //        let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
    //        fileInfo.folderId = self.folderInfo.folderId
    //        fileInfo.fileName = fileName
    //        fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: defualtImagePath)
    //        fileInfo.thumbImagePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: thumpImagePath)
    //        fileInfo.fileSize = getFileSizeAtPath(filePath: defualtImagePath)
    //        fileInfo.fileWidth = imageWidth
    //        fileInfo.fileHeight = imageHeight
    //        fileInfo.createTime = Int(time)
    //        fileInfo.fileType = isGif == true ? .GifType : .ImageType
    //        fileInfo.userId = CDUserId()
    //        CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)
    //        if isLast{
    //            DispatchQueue.main.async {
    //                CDSignalTon.shared.customPickerView = nil;
    //                self.refreshDBData()
    //                picker.dismiss(animated: true, completion: nil)
    //            }
    //        }
    //    }
    
    //    //MARK:UIImagePickerControllerDelegate
    //    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //        isNeedReloadData = true
    //        picker.dismiss(animated: true, completion: nil)
    //    }
    //    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    //
    //        //获取当前时间
    //        let time = getCurrentTimestamp()
    //        //大图路径
    //        let defualtImagePath = String.ImagePath().appendingFormat("/%lld.jpg", time)
    //        //缩略图路径
    //        let thumpImagePath = String.thumpImagePath().appendingFormat("/%lld.jpg", time)
    //
    //        let defualtImage:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    //        let bigData:Data = UIImageJPEGRepresentation(defualtImage, 1.0)!
    //
    //        let thumbImage = scaleImageAndCropToMaxSize(image: defualtImage, newSize: CGSize(width: 200, height: 200))
    //        let tmpData:Data = UIImageJPEGRepresentation(thumbImage, 1.0)! as Data
    //
    //        do {
    //            try bigData.write(to: URL(fileURLWithPath: defualtImagePath))
    //            try tmpData.write(to: URL(fileURLWithPath: thumpImagePath))
    //        } catch  {
    //
    //        }
    //
    //        let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
    //        fileInfo.folderId = self.folderInfo.folderId
    //        fileInfo.fileName = "未命名"
    //        fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: defualtImagePath)
    //        fileInfo.thumbImagePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: thumpImagePath)
    //        fileInfo.fileSize = getFileSizeAtPath(filePath: defualtImagePath)
    //        fileInfo.fileWidth = Double(defualtImage.size.width)
    //        fileInfo.fileHeight = Double(defualtImage.size.height)
    //        fileInfo.createTime = Int(time)
    //        fileInfo.fileType = .ImageType
    //        CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)
    //        DispatchQueue.main.async {
    //            self.isNeedReloadData = true
    //            picker.dismiss(animated: true, completion: nil)
    //        }
    //
    //
    //    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
