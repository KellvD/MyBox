//
//  CDImageScrollerViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/28.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
let PADDING = 10

class CDImageScrollerViewController: CDBaseAllViewController,UIImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {



    var inputArr:[CDSafeFileInfo] = []
    var currentIndex:Int!
    var totalCount:Int!
    var toolBar:UIImageView!
    var shareItem:UIButton!
    var loveItem:UIButton!
    var editItem:UIButton!
    var deleteItem:UIButton!
    var indexLabel:UILabel!

    var collectionView:UICollectionView!
    var isPushNext = false  //

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isPushNext = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if toolBar.isHidden {
            onBarsHiddenOrNot()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        totalCount = inputArr.count
        let fileInfo = inputArr[currentIndex]
        self.title = fileInfo.fileName
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:CDSCREEN_WIDTH + 40, height: CDSCREEN_HEIGTH)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: 0, y: -(StatusHeight + 44.0), width: CDSCREEN_WIDTH + 40, height: CDSCREEN_HEIGTH), collectionViewLayout: layout)
        collectionView.register(CDImageCell.self, forCellWithReuseIdentifier: "imageScrollerr")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.black
        collectionView.isPagingEnabled = true
        view.addSubview(collectionView!)
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)



        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: LoadImageByName(imageName: "fileDetail", type: "png"), style: .plain, target: self, action: #selector(detailBtnClicked))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white

        indexLabel = UILabel(frame: CGRect(x: (CDSCREEN_WIDTH - 50)/2, y: CDViewHeight - 48 - 40, width: 50, height: 30))
        indexLabel.textAlignment = .center
        indexLabel.textColor = UIColor.lightGray
        indexLabel.font = TextMidFont
        indexLabel.text = String(format: "%d/%d", currentIndex+1,totalCount)
        indexLabel.backgroundColor = UIColor.clear
        self.view.addSubview(indexLabel)

        self.toolBar = UIImageView(frame: CGRect(x: 0, y: CDViewHeight - 48, width: CDSCREEN_WIDTH, height: 48))
        self.toolBar.isUserInteractionEnabled = true
        self.toolBar.image = UIImage(named: "下导航-bg")
        self.view.addSubview(self.toolBar)
        let spqce0:CGFloat = (CDSCREEN_WIDTH - 45 * 4)/5
        //分享
        self.shareItem = UIButton(type:.custom)
        self.shareItem.frame = CGRect(x: spqce0, y: 1.5, width: 45, height: 45)
        self.shareItem.setImage(UIImage(named: "menu_forward"), for: .normal)
        self.shareItem.addTarget(self, action: #selector(shareItemClick), for: .touchUpInside)
        self.toolBar.addSubview(self.shareItem)
        //收藏
        self.loveItem = UIButton(type:.custom)
        self.loveItem.frame = CGRect(x: spqce0 * 2 + 45, y: 1.5, width: 45, height: 45)
        if fileInfo.grade == .lovely{
            loveItem.setImage(LoadImageByName(imageName: "love_press", type: "png"), for: .normal)
        }else{
            loveItem.setImage(LoadImageByName(imageName: "love_normal", type: "png"), for: .normal)
        }
        self.loveItem.addTarget(self, action: #selector(loveItemClick), for: .touchUpInside)
        self.toolBar.addSubview(self.loveItem)

        //编辑
        self.editItem = UIButton(type:.custom)
        self.editItem.frame = CGRect(x: spqce0 * 3 + 45 * 2, y: 1.5, width: 45, height: 45)
        self.editItem.setImage(UIImage(named: "美图"), for: .normal)
        self.editItem.addTarget(self, action: #selector(editItemClick), for: .touchUpInside)
        self.toolBar.addSubview(self.editItem)
        //删除
        self.deleteItem = UIButton(type:.custom)
        self.deleteItem.frame = CGRect(x: spqce0 * 4 + 45 * 3, y: 1.5, width: 45, height: 45)
        self.deleteItem.setImage(UIImage(named: "menu_delete"), for: .normal)
        self.deleteItem.addTarget(self, action: #selector(deleteItemItemClick), for: .touchUpInside)
        self.toolBar.addSubview(self.deleteItem)


        registerNotification()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inputArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageScrollerr", for: indexPath) as! CDImageCell
        cell.scroller.isHidden = false
        setConfig(scroller: cell.scroller, indexPath: indexPath)
        return cell
    }

    func setConfig(scroller:CDImageScrollView,indexPath:IndexPath) {

        let fileInfo:CDSafeFileInfo = inputArr[indexPath.item]

        DispatchQueue.global().async {
            let tmpPath = String.ImagePath().appendingFormat("/%@",fileInfo.filePath.lastPathComponent())
            let tmpImage = UIImage(contentsOfFile: tmpPath)
            let tmpData = NSData(contentsOfFile: tmpPath)
            let imageSize = tmpImage!.size
            var isWidthLonger = false
            if Int(imageSize.width) > Int(imageSize.height){
                isWidthLonger = false
            }
            var newSize = CGSize()
            if isWidthLonger{
                let tempWidth = CGFloat(5500)

                if Int(imageSize.width) > Int(tempWidth) {
                    newSize = CGSize(width: tempWidth, height: tempWidth * imageSize.height / imageSize.width)
                } else {
                    newSize = imageSize
                }
            }else{
                let tempHeight = CGFloat(5500)
                if imageSize.height > tempHeight {
                    newSize = CGSize(width: tempHeight * imageSize.width / imageSize.height, height: tempHeight)
                } else {
                    newSize = imageSize
                }
            }
            var new = UIImage()
            UIGraphicsBeginImageContext(newSize)
            let context = UIGraphicsGetCurrentContext()
            if context != nil {
                tmpImage?.draw(in: CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height))
                new = UIGraphicsGetImageFromCurrentImageContext()!
            }
            UIGraphicsEndImageContext()
            DispatchQueue.main.async(execute: {
                scroller.loadImageView(image: new, gifData: tmpData!)
            })

        }

    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let firstIndexPath = collectionView.indexPathsForVisibleItems.first

        let page = firstIndexPath!.item
        let fileinfo = inputArr[page]
        DispatchQueue.main.async {
            if fileinfo.grade == .lovely {
                self.loveItem.setImage(LoadImageByName(imageName: "love_press", type: "png"), for: .normal)

            }else{
                self.loveItem.setImage(LoadImageByName(imageName: "love_normal", type: "png"), for: .normal)
            }
            if fileinfo.fileType == .GifType{
                self.editItem.isEnabled = false
            }else{
                self.editItem.isEnabled = true
            }
        }

        self.title = fileinfo.fileName
        currentIndex = page
        indexLabel.text = String(format: "%d/%d", currentIndex+1,totalCount)
    }

    @objc func detailBtnClicked(){
        let fileInfo = inputArr[currentIndex]
        let fileDetail = CDFileDetailViewController()
        fileDetail.fileInfo = fileInfo
        self.navigationController?.pushViewController(fileDetail, animated: true)
    }
    //TODO:分享
    @objc func shareItemClick()
    {
        let fileInfo = inputArr[currentIndex]
        let selectedImageArr:[CDSafeFileInfo] = [fileInfo]
        presentShareActivityWith(dataArr: selectedImageArr)
    }
    //TODO:收藏
    @objc func loveItemClick()
    {
        let fileInfo = inputArr[currentIndex]

        if fileInfo.grade == .normal {
            fileInfo.grade = .lovely
            loveItem.setImage(LoadImageByName(imageName: "love_press", type: "png"), for: .normal)
            CDSqlManager.instance().updateOneSafeFileGrade(grade: .lovely, fileId: fileInfo.fileId)
        }else{
            fileInfo.grade = .normal
            loveItem.setImage(LoadImageByName(imageName: "love_normal", type: "png"), for: .normal)
            CDSqlManager.instance().updateOneSafeFileGrade(grade: .normal, fileId: fileInfo.fileId)
        }

        self.inputArr[currentIndex] = fileInfo

    }
    //TODO:删除
    @objc func deleteItemItemClick()
    {
        let fileInfo = inputArr[currentIndex]
        let sheet = UIAlertController(title: nil, message: "删除照片", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (action) in
            let thumbPath = String.thumpImagePath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
            fileManagerDeleteFileWithFilePath(filePath: thumbPath)
            //删除加密大图
            let defaultPath = String.ImagePath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
            fileManagerDeleteFileWithFilePath(filePath: defaultPath)
            CDSqlManager.instance().deleteOneSafeFile(fileId: fileInfo.fileId)
            self.inputArr.remove(at: self.currentIndex!)
            DispatchQueue.main.async {
                CDHUD.hide()
                CDHUD.showText(text: "删除成功")
                self.collectionView.reloadData()
                NotificationCenter.default.removeObserver(self, name: NeedReloadData, object: nil)

            }

        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        self.present(sheet, animated: true, completion: nil)

    }
    @objc func editItemClick(){
        let editVC = CDImageEditViewController()
        editVC.imageInfo = inputArr[currentIndex]
        editVC.modalPresentationStyle = .fullScreen
        self.present(editVC, animated: true, completion: nil)
    }
    func setTitleWithCurrentIndex(){

    }

    //TODO:NotificationCenter
    @objc func onBarsHiddenOrNot(){

        if isPushNext {
            if #available(iOS 13, *) {
//                UIApplication.shared.windows.first.windowScene.statusBarManager.isStatusBarHidden = false

            }else{
                UIApplication.shared.isStatusBarHidden = false
            }
            return
        }

        if self.toolBar.isHidden {
            self.toolBar.isHidden = false
            self.navigationController?.navigationBar.isHidden = false
        }else{
            self.toolBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = true
        }
    }


    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onBarsHiddenOrNot), name: BarsHiddenOrNot, object: nil)
    }
    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: BarsHiddenOrNot, object: nil)
    }

    deinit {
        removeNotification()
    }




}
