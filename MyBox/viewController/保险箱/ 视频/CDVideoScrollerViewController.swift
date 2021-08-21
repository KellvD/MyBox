//
//  CDVideoScrollerViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/12.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import MediaPlayer
class CDVideoScrollerViewController: CDBaseAllViewController,
                                     UICollectionViewDelegate,
                                     UICollectionViewDataSource {
    public var fileArr:[CDSafeFileInfo] = []
    public var currentIndex:Int!
    
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
        indexLabel.font = TextMidFont
        indexLabel.text = String(format: "%d/%d", currentIndex+1,fileArr.count)
        indexLabel.backgroundColor = UIColor.clear
        self.view.addSubview(indexLabel)
        let videoTap = UITapGestureRecognizer(target: self, action: #selector(onBarsHiddenOrNot))
        self.view.addGestureRecognizer(videoTap)
    }
    
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
        let url = URL(fileURLWithPath: videoPath)
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
        let segmentVC = CDSegmentVideoViewController()
        segmentVC.videoInfo = fileInfo
        self.navigationController?.pushViewController(segmentVC, animated: true)

    }
    //MARK:删除
    @objc func deleteBarItemClick()
    {
        let fileInfo = fileArr[currentIndex]

        let sheet = UIAlertController(title: nil, message: LocalizedString("delete photo"), preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: LocalizedString("sure"), style: .destructive, handler: { (action) in
           
            let thumbPath = String.RootPath().appendingPathComponent(str: fileInfo.thumbImagePath)
            DeleteFile(filePath: thumbPath)
            //删除加密大图
            let defaultPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
            DeleteFile(filePath: defaultPath)
            CDSqlManager.shared.deleteOneSafeFile(fileId: fileInfo.fileId)

            DispatchQueue.main.async {
                CDHUDManager.shared.hideWait()
                CDHUDManager.shared.showText(LocalizedString("Delete complete"))

            }

        }))
        sheet.addAction(UIAlertAction(title: LocalizedString("cancel"), style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)

    }

    func stopCurrentPlayCell(){
        let indexPath = IndexPath(item: self.currentIndex, section: 0)
        let cell:CDVideoScrollerCell = self.collectionView.cellForItem(at: indexPath) as! CDVideoScrollerCell
        cell.stopPlayer()


    }
    
    //MARK:NotificationCenter
    @objc func onBarsHiddenOrNot(){
        self.isHiddenBottom = !self.isHiddenBottom
        var rect = self.toolBar.frame
        UIView.animate(withDuration: 0.25) {
            rect.origin.y = self.isHiddenBottom ? CDSCREEN_HEIGTH : (CDSCREEN_HEIGTH - BottomBarHeight)
            self.toolBar.frame = rect
        }
        
        self.navigationController?.setNavigationBarHidden(self.isHiddenBottom, animated: true)
    }
    
}
