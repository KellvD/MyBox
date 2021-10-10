//
//  CDVideoScrollerViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/12.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import MediaPlayer
import CDMediaEditor


class CDVideoScrollerViewController: CDBaseAllViewController{
    public var fileArr:[CDSafeFileInfo] = []
    public var currentIndex:Int!
    public var folderId:Int!
    
    private var collectionView:UICollectionView!
    private var toolBar:CDToolBar!
    private var indexLabel:UILabel!
    private var isHiddenBottom:Bool! = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.navigationBar.isTranslucent = false

        stopCurrentPlayCell()
    }
    
    override var prefersStatusBarHidden: Bool{
        return isHiddenBottom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
        let fileInfo = fileArr[currentIndex]
        self.title = fileInfo.fileName
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:CDSCREEN_WIDTH , height: CDSCREEN_HEIGTH)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = true
        view.addSubview(collectionView)
        collectionView.register(CDVideoScrollerCell.self, forCellWithReuseIdentifier: "CDVideoScrollerCell")
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: LoadImage("fileDetail"), style: .plain, target: self, action: #selector(detailBtnClicked))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white

        self.toolBar = CDToolBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - BottomBarHeight, width: CDSCREEN_WIDTH, height: BottomBarHeight),barType: .VideoScrollerTools, superVC: self)
        self.view.addSubview(self.toolBar)
        self.toolBar.loveItem.setImage(LoadImage(fileInfo.grade == .lovely ? "menu_love_press" : "menu_love_normal"), for: .normal)

        indexLabel = UILabel(frame: CGRect(x: (CDSCREEN_WIDTH - 50)/2, y: self.toolBar.minY - 40, width: 50, height: 30))
        indexLabel.textAlignment = .center
        indexLabel.textColor = UIColor.lightGray
        indexLabel.font = .mid
        indexLabel.text = String(format: "%d/%d", currentIndex+1,fileArr.count)
        indexLabel.backgroundColor = UIColor.clear
        self.view.addSubview(indexLabel)
        let videoTap = UITapGestureRecognizer(target: self, action: #selector(onBarsHiddenOrNot))
        self.view.addGestureRecognizer(videoTap)
    }
    
   
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        //暂停上次播放的
//        print("滚动前--")
//        
//        stopCurrentPlayCell()
//    }
    
    
    @objc func detailBtnClicked(){
        let fileInfo = fileArr[currentIndex]
        let fileDetail = CDFileDetailViewController()
        fileDetail.fileInfo = fileInfo
        self.navigationController?.pushViewController(fileDetail, animated: true)
    }
    
    //MARK:分享
    @objc func shareItemClick(){
        let fileInfo = fileArr[currentIndex]
        let videoPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
        let url = videoPath.url
        presentShareActivityWith(dataArr: [url as NSObject]) { (error) in}
    }
    
    //MARK:收藏
    @objc func loveItemClick(){
        let fileInfo = fileArr[currentIndex]

        if fileInfo.grade == .normal {
            fileInfo.grade = .lovely
            self.toolBar.loveItem.setImage(LoadImage("menu_love_press"), for: .normal)
            CDSqlManager.shared.updateOneSafeFileGrade(grade: .lovely, fileId: fileInfo.fileId)
        }else{
            fileInfo.grade = .normal
            self.toolBar.loveItem.setImage(LoadImage("menu_love_normal"), for: .normal)
            CDSqlManager.shared.updateOneSafeFileGrade(grade: .normal, fileId: fileInfo.fileId)
        }

        self.fileArr[currentIndex] = fileInfo
    }
    
    @objc func editItemClick(){
        let fileInfo = fileArr[currentIndex]
        let videoUrl = String.RootPath().appendingPathComponent(str: fileInfo.filePath).url
        let config = VideoEditorConfiguration()
        let videoEditVC = EditorController(videoURL: videoUrl, config: config)
        videoEditVC.modalPresentationStyle = .fullScreen
        videoEditVC.videoEditorDelegate = self
        present(videoEditVC, animated: true, completion: nil)
        

    }
    //MARK:删除
    @objc func deleteBarItemClick()
    {
        let fileInfo = fileArr[currentIndex]

        let sheet = UIAlertController(title: nil, message: "删除照片".localize, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "确定".localize, style: .destructive, handler: { (action) in
           
            let thumbPath = String.RootPath().appendingPathComponent(str: fileInfo.thumbImagePath)
            thumbPath.delete()
            //删除加密大图
            let defaultPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
            defaultPath.delete()
            CDSqlManager.shared.deleteOneSafeFile(fileId: fileInfo.fileId)

            DispatchQueue.main.async {
                CDHUDManager.shared.hideWait()
                CDHUDManager.shared.showText("删除完成".localize)

            }

        }))
        sheet.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)

    }
    
    @objc func shareBarItemClick(){
        let fileInfo = fileArr[currentIndex]
        let defaultPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
        let url = defaultPath.url
        presentShareActivityWith(dataArr: [url as NSObject]) { (error) in}
    }
    

    func stopCurrentPlayCell(){
        let indexPath = IndexPath(item: self.currentIndex, section: 0)
        let cell:CDVideoScrollerCell = self.collectionView.cellForItem(at: indexPath) as! CDVideoScrollerCell
        cell.stopPlayer()


    }
    
    //MARK:NotificationCenter
    @objc func onBarsHiddenOrNot(){
        self.isHiddenBottom = !self.isHiddenBottom
        UIView.animate(withDuration: 0.25) {
            self.toolBar.minY = self.isHiddenBottom ? CDSCREEN_HEIGTH : (CDSCREEN_HEIGTH - BottomBarHeight)
        }
        
        self.navigationController?.setNavigationBarHidden(self.isHiddenBottom, animated: true)
    }
    
    
    
    
}


extension CDVideoScrollerViewController:UICollectionViewDelegate,
                                        UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDVideoScrollerCell", for: indexPath) as! CDVideoScrollerCell
        let fileInfo = fileArr[indexPath.item]
        cell.setVideoToView(fileInfo: fileInfo)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let firstIndexPath = collectionView.indexPathsForVisibleItems.first
        let page = firstIndexPath!.item
        let fileinfo = fileArr[page]
        DispatchQueue.main.async {
            self.toolBar.loveItem.setImage(LoadImage(fileinfo.grade == .lovely ? "menu_love_press" : "menu_love_normal"), for: .normal)
        }
        
        self.title = fileinfo.fileName
        currentIndex = page
        self.indexLabel.text = String(format: "%d/%d", currentIndex+1,fileArr.count)
        

    }
}

extension CDVideoScrollerViewController:VideoEditorViewControllerDelegate{
    func videoEditorViewController(_ videoEditorViewController: VideoEditorViewController, didFinish result: VideoEditResult){
        CDHUDManager.shared.showComplete("剪辑完成")
        CDSignalTon.shared.saveFileWithUrl(fileUrl: result.editedURL, folderId: folderId, subFolderType: .VideoFolder,isFromDocment: false)
    }
    
    
    func videoEditorViewController(_ videoEditorViewController: VideoEditorViewController, loadMusic completionHandler: @escaping ([VideoEditorMusicInfo]) -> Void) -> Bool {
        let audioArr = CDSqlManager.shared.queryAllFile(fileType: .AudioType)
        var musicArr:[VideoEditorMusicInfo] = []
        for audio in audioArr {
            let pathUrl = audio.filePath.rootPath.url
            let music = VideoEditorMusicInfo(audioURL: pathUrl, lrc: "")
            musicArr.append(music)
        }
        completionHandler(musicArr)
        return true
    }
}


