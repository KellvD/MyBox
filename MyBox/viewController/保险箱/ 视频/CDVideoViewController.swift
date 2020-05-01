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
    var toolbar:CDToolBar!
    var selectBtn:UIButton!
    var backBtn:UIButton!
    var collectionView:UICollectionView!
    var videoArr:[CDSafeFileInfo] = []

    var isEditSelected = Bool()
    var folderInfo:CDSafeFolder!
    var selectDic = NSMutableDictionary()
    var selectCount:Int = 0
    var selectedVideoArr:[CDSafeFileInfo] = []
    var outputVideoArr:[CDSafeFileInfo] = []
    var isNeedReloadData:Bool = false

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

        self.toolbar = CDToolBar(frame: CGRect(x: 0, y: CDViewHeight-48, width: CDSCREEN_WIDTH, height: 48), foldertype: .ImageFolder, superVC: self)
        self.view.addSubview(self.toolbar)

        registerNotification()
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
            selectedVideoArr.removeAll()
            for i in 0..<videoArr.count {
                selectDic.setObject("NO", forKey: "\(i)" as NSCopying)
            }
        }
        collectionView.reloadData()
    }

    //返回
    @objc func backBtnClick() -> Void {
        if isEditSelected { //
            selectedVideoArr.removeAll()
            selectDic.removeAllObjects()
            if (self.backBtn.titleLabel?.text == "全选") { //全选
                backBtn.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
                backBtn.contentHorizontalAlignment = .left
                self.backBtn.setTitle("全不选", for: .normal)
                for i in 0..<videoArr.count {
                    selectDic.setObject("NO", forKey: "\(i)" as NSCopying)
                }
                selectCount = 0
            }else{
                self.backBtn.setTitle("全选", for: .normal)
                for i in 0..<videoArr.count {
                    selectDic.setObject("YES", forKey: "\(i)" as NSCopying)
                }
                selectCount = videoArr.count

            }
            collectionView.reloadData()
        }else{
            self.navigationController?.popViewController(animated: true)
        }

    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCellIdrr", for: indexPath) as! CDImageCell


        setConfig(cell: cell, indexPath: indexPath)

        return cell
    }

    func setConfig(cell:CDImageCell,indexPath:IndexPath) {
        let fileInfo:CDSafeFileInfo = videoArr[indexPath.item]
        if selectBtn.isSelected {
            let selectState:String = selectDic.object(forKey: "\(indexPath.item)") as! String
            if selectState == "YES" {
                cell.selectedView.isHidden = false
            }else{
                cell.selectedView.isHidden = true
            }

        }else{
            cell.selectedView.isHidden = true
        }

        let tmpPath = String.thumpVideoPath().appendingFormat("/%@",fileInfo.thumbImagePath.lastPathComponent())
        var mImgage:UIImage! = UIImage(contentsOfFile: tmpPath)
        if mImgage == nil {
            mImgage = LoadImageByName(imageName: "小图解密失败", type:"png")
        }
        cell.videoSizeL.isHidden = false
        cell.videoSizeL.text = getMMSSFromSS(second: fileInfo.timeLength)
        cell.backgroundView = UIImageView(image: mImgage)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell:CDImageCell = collectionView.cellForItem(at: indexPath) as! CDImageCell

        if selectBtn.isSelected{
            var selectState = ""
            var hidden = cell.selectedView.isHidden
            if hidden {
                hidden = false
                selectState = "YES"
                selectCount += 1
            }else{
                hidden = true
                selectCount -= 1
                selectState = "NO"
            }
            cell.selectedView.isHidden = hidden
            cell.backgroundColor = UIColor.red
            selectDic.setObject(selectState, forKey: "\(indexPath.item)" as NSCopying)
            if selectCount > 0 {
                toolbar.deleteItem.tintColor = CustomPinkColor
                toolbar.enableReloadBar(isSelected: true)
                if selectCount < 2 && selectCount > 5{
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
        }else{
            let scrollerVC = CDVideoScrollerViewController()
            scrollerVC.currentIndex = indexPath.item
            scrollerVC.fileArr = videoArr
            scrollerVC.currentIndex = indexPath.item
            self.navigationController?.pushViewController(scrollerVC, animated: true)
        }
    }

    //编辑 剪裁，合并
    @objc func editVideoItemClick(){

    }
    //TODO:分享事件
    @objc func shareBarItemClick(){
        handelSelectedArr()
        if selectedVideoArr.count <= 0{
            return
        }
        presentShareActivityWith(dataArr: selectedVideoArr)
    }
    //TODO:移动
    @objc func moveBarItemClick(){
        isNeedReloadData = false
        handelSelectedArr()
        if selectedVideoArr.count <= 0{
            return
        }
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
        if selectedVideoArr.count <= 0{
            return
        }
        let alert = UIAlertController(title: nil, message: "您确定要导入选中的视频到系统相册？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in

        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            CDHUD.showLoading(text: "正在处理")

            DispatchQueue.main.async  {
                self.outputVideoArr = self.selectedVideoArr
                self.outputPhoto()

            }
        }))
    }
    func outputPhoto() -> Void {
        if self.outputVideoArr.count > 0 {
            for index in 0..<self.outputVideoArr.count{
                let file:CDSafeFileInfo = self.outputVideoArr[index]
                let fileName = file.filePath.lastPathComponent()
                let videoPath = String.VideoPath().appendingPathComponent(str: fileName)
                let compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)
                if compatible{
                    UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, #selector(saveVideoDidFinished(videoPath:error:)), nil)
                }else{
                    let filsC:CDSafeFileInfo = outputVideoArr[0];
                    let fileName = filsC.filePath.lastPathComponent()
                    let thumpVideoPath = String.thumpVideoPath().appendingPathComponent(str: fileName)
                    fileManagerDeleteFileWithFilePath(filePath: thumpVideoPath)
                    outputVideoArr.remove(at: 0)
                    outputPhoto()
                }

            }

        }
    }
    @objc func saveVideoDidFinished(videoPath:String,error:NSError) {

        let filsC:CDSafeFileInfo = outputVideoArr[0];
        let fileName = filsC.filePath.lastPathComponent()
        let thumpVideoPath = String.thumpVideoPath().appendingPathComponent(str: fileName)
        fileManagerDeleteFileWithFilePath(filePath: thumpVideoPath)
        outputVideoArr.remove(at: 0)
        outputPhoto()

    }

    //TODO:删除
    @objc func deleteBarItemClick(){
        handelSelectedArr()
        var btnTitle = String()

        if selectedVideoArr.count <= 0{
            return
        }else if selectedVideoArr.count > 1{
            btnTitle = "删除\(selectedVideoArr.count)条视频"
        }else{
            btnTitle = "删除视频"
        }

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: btnTitle, style: .destructive, handler: { (action) in
            CDHUD.showLoading(text: "正在处理...")
            DispatchQueue.global().async {
                self.deleteTheSelectImage()
            }

        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }

    func deleteTheSelectImage() -> Void {
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
            CDHUD.hide()
            CDHUD.showText(text: "删除成功")
            self.refreshData()
            self.multisSelectBtnClick()
        }
    }
    func refreshData() {
        selectedVideoArr.removeAll()
        selectDic.removeAllObjects()
        toolbar.enableReloadBar(isSelected: false)
        videoArr = CDSqlManager.instance().queryAllFileFromFolder(folderId: folderInfo.folderId)
        for index in 0..<videoArr.count{
            selectDic.setObject("NO", forKey: "\(index)" as NSCopying)
        }
        collectionView.reloadData()
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
//                let camera = CDCameraViewController()
//                camera.delegate = self
//                camera.isVideo = true
//                self.present(camera, animated: true, completion: nil)
                let pickVC = UIImagePickerController();
                pickVC.sourceType = .camera;
                pickVC.mediaTypes = ["public.movie"]
                pickVC.allowsEditing = true
                pickVC.delegate = self
                present(pickVC, animated: true, completion: nil)


            }

        }

    }
    //TODO:导入
    @objc func inputItemClick() -> Void {
        //保持屏幕常亮
        let elcPicker = CDMediaPickerViewController(isVideo: true)
        elcPicker.pickerDelegate = self
        CDAssetTon.shareInstance().mediaType = "public.movie"
        elcPicker.folderId = folderInfo.folderId
        CDSignalTon.shareInstance().customPickerView = elcPicker
        elcPicker.modalPresentationStyle = .fullScreen
        self.present(elcPicker, animated: true, completion: nil)
    }
    @objc func appendItemClick(){
        handelSelectedArr()

        let sheet = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "拼接视频", style: .destructive, handler: { (action) in
            CDHUD.showLoading(text: "正在处理...")
            DispatchQueue.global().async {
                self.deleteTheSelectImage()
            }

        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    @objc func documentItemClick(){
        let documentTypes = ["public.movie"]
        super.subFolderId = folderInfo.folderId
        super.subFolderType = folderInfo.folderType
        presentDocumentPicker(documentTypes: documentTypes)
    }
    @objc func onDocumentInputFileSuccess(){
        refreshData()
    }
    func handelSelectedArr(){
        selectedVideoArr.removeAll()
        let allkey:[String] = selectDic.allKeys as! [String]
        for key:String in allkey {
            let states:String = selectDic.object(forKey: key) as! String
            if states == "YES" {
                let row:Int = Int(key) ?? 0
                let fileIm = videoArr[row]
                selectedVideoArr.append(fileIm)


            }

        }

    }


    //TODO:CDMeidaPickerDelegate
    func onSelectedMediaPickerDidFinished(picker: CDMediaPickerViewController, info: NSMutableDictionary) {
    }

    func onSelectedMediaPickerDidCancle(picker: CDMediaPickerViewController) {
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
    @objc func onDismissImagePicker(notic:Notification) {
        isNeedReloadData = true
        refreshData()
        CDSignalTon.shareInstance().customPickerView.dismiss(animated: true, completion: nil)


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
        NotificationCenter.default.removeObserver(self, name: DismissImagePicker, object: nil)
        NotificationCenter.default.removeObserver(self, name: DocumentInputFile, object: nil)

    }
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(needReloadData), name: NeedReloadData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDismissImagePicker), name: DismissImagePicker, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDocumentInputFileSuccess), name: DocumentInputFile, object: nil)


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
