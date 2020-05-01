//
//  CDImageViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/5.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import AVFoundation

class CDImageViewController: CDBaseAllViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CDMediaPickerDelegate,CDCameraViewControllerDelegate,CDComposeGifViewControllerDelegate {



    var toolbar:CDToolBar!
    var popView:CDPopMenuView!

    var selectBtn:UIButton!
    var backBtn:UIButton!
    var collectionView:UICollectionView!
    var imageArr:[CDSafeFileInfo] = []

    var isEditSelected = Bool()
    var folderInfo:CDSafeFolder!
    var selectDic = NSMutableDictionary()
    var selectCount:Int = 0
    var selectedImageArr:[CDSafeFileInfo] = []
    var outputImageArr:[CDSafeFileInfo] = []
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
//        print(NSStringFromCGRect(collectionView.frame))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView!)

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
        selectCount = 0
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
            selectedImageArr.removeAll()
            for i in 0..<imageArr.count {
                selectDic.setObject("NO", forKey: "\(i)" as NSCopying)
            }
            collectionView.reloadData()
        }
    }

    //返回
    @objc func backBtnClick() -> Void {
        if isEditSelected { //
            selectedImageArr.removeAll()
            selectDic.removeAllObjects()
            if (self.backBtn.titleLabel?.text == "全选") { //全选
                backBtn.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
                backBtn.contentHorizontalAlignment = .left
                self.backBtn.setTitle("全不选", for: .normal)
                for i in 0..<imageArr.count {
                    selectDic.setObject("YES", forKey: "\(i)" as NSCopying)
                }
                selectCount = imageArr.count

            }else{
                self.backBtn.setTitle("全选", for: .normal)
                for i in 0..<imageArr.count {
                    selectDic.setObject("NO", forKey: "\(i)" as NSCopying)
                }
                selectCount = 0
            }
            if selectCount > 0{
                toolbar.enableReloadBar(isSelected: true)
            }else{
                toolbar.enableReloadBar(isSelected: false)
            }
            collectionView.reloadData()
        }else{
            self.navigationController?.popViewController(animated: true)
        }

    }

    func handelSelectedArr(){
        selectedImageArr.removeAll()
        let allkey:[String] = selectDic.allKeys as! [String]
        for key:String in allkey {
            let states:String = selectDic.object(forKey: key) as! String
            if states == "YES" {
                let row:Int = Int(key) ?? 0
                let fileIm = imageArr[row]
                selectedImageArr.append(fileIm)
            }
        }
    }
    //TODO:分享事件
    @objc func shareBarItemClick(){

        handelSelectedArr()
        if selectedImageArr.count <= 0{
            return
        }
        presentShareActivityWith(dataArr: selectedImageArr)
    }
    //移动
    @objc func moveBarItemClick(){

        isNeedReloadData = false
        handelSelectedArr()
        if selectedImageArr.count <= 0{
            return
        }
        let folderList = CDFolderListViewController()
        folderList.title = "文件夹列表"
        folderList.selectedArr = selectedImageArr
        folderList.folderType = .ImageFolder
        folderList.folderId = folderInfo.folderId
        self.navigationController?.pushViewController(folderList, animated: true)

    }
    //导出
    @objc func outputBarItemClick(){
        handelSelectedArr()
        if selectedImageArr.count <= 0{
            return
        }
        let outAlert = UIAlertController(title: nil, message: "您确定要导入选中的图片到系统相册？", preferredStyle: .alert)
        outAlert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in

        }))
        outAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                CDHUD.showLoading(text: "正在处理")
                self.outputImageArr = self.selectedImageArr
                self.outputPhoto()
            }
        }))
        present(outAlert, animated: false, completion: nil)

    }

    //删除
    @objc func deleteBarItemClick(){
        handelSelectedArr()
        var btnTitle = String()

        if selectedImageArr.count <= 0{
            return
        }else if selectedImageArr.count > 1{
            btnTitle = "删除\(selectedImageArr.count)张图片"
        }else{
            btnTitle = "删除照片"
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
            gifVC.delegate = self
            self.navigationController?.pushViewController(gifVC, animated: true)

        }))
        sheet.addAction(UIAlertAction(title: "合成视频", style: .default, handler: { (action) in
            let videoVC = CDComposeVideoViewController()
            self.navigationController?.pushViewController(videoVC, animated: true)

        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    @objc func documentItemClick(){
        let documentTypes = ["public.image"]
        super.subFolderId = folderInfo.folderId
        super.subFolderType = folderInfo.folderType
        presentDocumentPicker(documentTypes: documentTypes)
    }
    @objc func onDocumentInputFileSuccess(){
        refreshData()
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
                camera.isVideo = false
                camera.modalPresentationStyle = .fullScreen
                self.present(camera, animated: true, completion: nil)

            }

        }
        
    }
    //TODO:导入
    @objc func inputItemClick() -> Void {
        //保持屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
        let cdPicker = CDMediaPickerViewController(isVideo: false)
        cdPicker.pickerDelegate = self
        CDAssetTon.instance.mediaType = "public.image"
        CDSignalTon.shareInstance().customPickerView = cdPicker
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
        setConfig(cell: cell, indexPath: indexPath)

        return cell
    }

    func setConfig(cell:CDImageCell,indexPath:IndexPath) {
        let fileInfo:CDSafeFileInfo = imageArr[indexPath.item]
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
        if fileInfo.fileType == .GifType{
            cell.gifL.isHidden = false
        }else{
            cell.gifL.isHidden = true
        }

        let tmpPath = String.libraryUserdataPath().appendingFormat("%@",fileInfo.thumbImagePath)
        var mImgage:UIImage! = UIImage(contentsOfFile: tmpPath)
        if mImgage == nil {
            mImgage = LoadImageByName(imageName: "小图解密失败", type:"png")
        }
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
                if selectCount > 16{
                    toolbar.appendItem.isEnabled = false
                }else{
                    toolbar.appendItem.isEnabled = true
                }
            }else{
                toolbar.enableReloadBar(isSelected: false)
            }
            if selectCount == imageArr.count {
                backBtn.frame = CGRect(x: 0, y: 0, width: 88, height: 44)
                backBtn.contentHorizontalAlignment = .left
                backBtn.setTitle("全不选", for: .normal)
            }else{
                backBtn.setTitle("全选", for: .normal)
            }
        }else{
            let scrollerVC = CDImageScrollerViewController()
            scrollerVC.currentIndex = indexPath.item
            scrollerVC.inputArr = imageArr
            self.navigationController?.pushViewController(scrollerVC, animated: true)
        }
    }

    
    //TODO:CDCameraViewControllerDelegate
    func onCameraTakePhotoDidFinshed(cameraVC: CDCameraViewController, image: UIImage) {
        CDSignalTon.shareInstance().handleToSaveImage(image: image, folderId: folderInfo.folderId)
        self.isNeedReloadData = true
        cameraVC.dismiss(animated: true, completion: nil)
    }

    func onCameraTakePhotoDidCancle(cameraVC: CDCameraViewController) {

        cameraVC.dismiss(animated: true, completion: nil)

    }
    //TODO:CDMeidaPickerDelegate
    func onSelectedMediaPickerDidFinished(picker: CDMediaPickerViewController, info: NSMutableDictionary) {
        let defualtImagePath = info["savePath"] as! String
        let imageHeight = info["imageHeight"] as! Double
        let imageWidth = info["imageWidth"] as! Double
        let isLast = info["isLast"] as! Bool
        let time = info["time"] as! Int
        var fileName = info["fileName"] as! String
        let isGif = info["isGif"] as! Bool

        let fileNameArr = fileName.components(separatedBy: ".")
        fileName = fileNameArr.first!

        //缩略图路径
        let thumpImagePath = String.thumpImagePath().appendingFormat("/\(time).jpg")
        var bigData = Data()
        do {
            bigData = try Data(contentsOf: URL(fileURLWithPath: defualtImagePath))
        } catch  {

        }

        let defualtImage = UIImage(data:bigData)!
        let thumbImage = scaleImageAndCropToMaxSize(image: defualtImage, newSize: CGSize(width: 200, height: 200))
        let tmpData:Data = thumbImage.jpegData(compressionQuality: 1.0)! as Data

        do {
            try tmpData.write(to: URL(fileURLWithPath: thumpImagePath))
        } catch  {

        }
        let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
        fileInfo.folderId = self.folderInfo.folderId
        fileInfo.fileName = fileName
        fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: defualtImagePath)
        fileInfo.thumbImagePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: thumpImagePath)
        fileInfo.fileSize = getFileSizeAtPath(filePath: defualtImagePath)
        fileInfo.fileWidth = imageWidth
        fileInfo.fileHeight = imageHeight
        fileInfo.createTime = Int(time)
        fileInfo.fileType = isGif == true ? .GifType : .ImageType
        fileInfo.userId = CDUserId()
        CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)
        if isLast{
            DispatchQueue.main.async {
                CDSignalTon.shareInstance().customPickerView = nil;
                self.refreshData()
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }

    func onSelectedMediaPickerDidCancle(picker: CDMediaPickerViewController) {
        CDSignalTon.shareInstance().customPickerView = nil
        picker.dismiss(animated: true, completion: nil)
    }

    func outputPhoto() -> Void {
        if self.outputImageArr.count > 0 {
            for index in 0..<self.outputImageArr.count{
                let file:CDSafeFileInfo = self.outputImageArr[index]
                let fileName = file.filePath.lastPathComponent()
                let imagePath = String.ImagePath().appendingPathComponent(str: fileName)
                let urlC =  URL(fileURLWithPath: imagePath)
                var dataC = Data()
                do {
                     dataC = try Data(contentsOf:urlC)
                } catch {
                    print("catch log")
                }
                let imageD:UIImage! = UIImage(data: dataC)
                UIImageWriteToSavedPhotosAlbum(imageD, self, #selector(savePhoto(imageD:)), nil)
                savePhoto(imageD: imageD)
            }

        }else{
            DispatchQueue.main.async {
                CDHUD.hide()
                CDHUD.showText(text: "导出成功")
            }

        }
    }
    @objc func savePhoto(imageD:UIImage) {
        let filsC:CDSafeFileInfo = outputImageArr[0];
        let fileName = filsC.filePath.lastPathComponent()
        let decryFilePath = String.thumpImagePath().appendingPathComponent(str: fileName)
        fileManagerDeleteFileWithFilePath(filePath: decryFilePath)
        outputImageArr.remove(at: 0)
        outputPhoto()

    }

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
            CDHUD.hide()
            CDHUD.showText(text: "删除成功")
            self.refreshData()
            self.multisSelectBtnClick()
        }
    }
    func refreshData() {
        selectedImageArr.removeAll()
        selectDic.removeAllObjects()
        toolbar.enableReloadBar(isSelected: false)
        imageArr = CDSqlManager.instance().queryAllFileFromFolder(folderId: folderInfo.folderId)
        for index in 0..<imageArr.count{
            selectDic.setObject("NO", forKey: "\(index)" as NSCopying)
        }
        collectionView.reloadData()
    }
    //TODO:NSNotications
    @objc func onNeedReloadData() {
        isNeedReloadData = true
    }
    @objc func onDismissImagePicker() {
        isNeedReloadData = true
    }
    //TODO:CDComposeGifViewControllerDelegate
    func onComposeGifSuccess() {
        refreshData()
        multisSelectBtnClick()
    }

    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: NeedReloadData, object: nil)
        NotificationCenter.default.removeObserver(self, name: DismissImagePicker, object: nil)
        NotificationCenter.default.removeObserver(self, name: DocumentInputFile, object: nil)
        

    }
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNeedReloadData), name: NeedReloadData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDismissImagePicker), name: DismissImagePicker, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDocumentInputFileSuccess), name: DocumentInputFile, object: nil)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //    //TODO:UIImagePickerControllerDelegate
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
