//
//  CDVideoScrollerViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/12.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import MediaPlayer
class CDVideoScrollerViewController: CDBaseAllViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    public var fileArr:[CDSafeFileInfo] = []
    public var currentIndex:Int!
    
    private var collectionView:UICollectionView!
    private var toolBar:CDToolBar!
    private var indexLabel:UILabel!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCurrentPlayCell()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileInfo = fileArr[currentIndex]
        self.title = fileInfo.fileName
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:CDSCREEN_WIDTH + 40 , height: CDViewHeight - 48)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH + 40, height: CDViewHeight-48), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.isPagingEnabled = true
        view.addSubview(collectionView!)
        collectionView.register(CDVideoScrollerCell.self, forCellWithReuseIdentifier: "CDVideoScrollerCell")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: LoadImage(imageName: "fileDetail", type: "png"), style: .plain, target: self, action: #selector(detailBtnClicked))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white

        self.toolBar = CDToolBar(frame: CGRect(x: 0, y: CDViewHeight-48, width: CDSCREEN_WIDTH, height: 48), foldertype: .ImageFolder, superVC: self)
        self.view.addSubview(self.toolBar)
        self.toolBar.loveItem.setImage(LoadImage(imageName: fileInfo.grade == .lovely ? "love_press" : "love_normal", type: "png"), for: .normal)

        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
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
            self.toolBar.loveItem.setImage(LoadImage(imageName: fileinfo.grade == .lovely ? "love_press" : "love_normal", type: "png"), for: .normal)
        }
        
        self.title = fileinfo.fileName
        currentIndex = page
        indexLabel.text = String(format: "%d/%d", currentIndex+1,fileArr.count)

    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //暂停上次播放的
        stopCurrentPlayCell()
    }
    
    @objc func detailBtnClicked(){
        let fileInfo = fileArr[currentIndex]
        let fileDetail = CDFileDetailViewController()
        fileDetail.fileInfo = fileInfo
        self.navigationController?.pushViewController(fileDetail, animated: true)
    }
    
    //MARK:分享
    @objc func shareItemClick()
    {
        let fileInfo = fileArr[currentIndex]
        let videoPath = String.VideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
        let url = URL(fileURLWithPath: videoPath)
        presentShareActivityWith(dataArr: [url as NSObject]) { (error) in}
    }
    
    //MARK:收藏
    @objc func loveItemClick()
    {
        let fileInfo = fileArr[currentIndex]

        if fileInfo.grade == .normal {
            fileInfo.grade = .lovely
            self.toolBar.loveItem.setImage(LoadImage(imageName: "love_press", type: "png"), for: .normal)
            CDSqlManager.shared.updateOneSafeFileGrade(grade: .lovely, fileId: fileInfo.fileId)
        }else{
            fileInfo.grade = .normal
            self.toolBar.loveItem.setImage(LoadImage(imageName: "love_normal", type: "png"), for: .normal)
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
    @objc func deleteItemItemClick()
    {
        let fileInfo = fileArr[currentIndex]

        let sheet = UIAlertController(title: nil, message: "删除照片", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (action) in
           
            let thumbPath = String.thumpVideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
            DeleteFile(filePath: thumbPath)
            //删除加密大图
            let defaultPath = String.VideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
            DeleteFile(filePath: defaultPath)
            CDSqlManager.shared.deleteOneSafeFile(fileId: fileInfo.fileId)

            DispatchQueue.main.async {
                CDHUDManager.shared.hideWait()
                CDHUDManager.shared.showText(text: "删除成功")

            }

        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)

    }

    func stopCurrentPlayCell(){
        //暂停上次播放的
//        DispatchQueue.main.async {
//            let indexPath = IndexPath(item: self.currentIndex, section: 0)
//            let cell:CDVideoScrollerCell = self.collectionView.cellForItem(at: indexPath) as! CDVideoScrollerCell
//            cell.stopPlayer()
//        }

    }
}
