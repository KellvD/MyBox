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
    var fileArr:[CDSafeFileInfo] = []
    var startIndex:Int!
    var currentIndex:Int!
    var totalCount:Int!
    var collectionView:UICollectionView!
    var toolBar:UIImageView!
    var shareItem:UIButton!
    var loveItem:UIButton!
    var deleteItem:UIButton!
    var editItem:UIButton!
    var indexLabel:UILabel!

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCurrentPlayCell()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        totalCount = fileArr.count
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

        [collectionView .scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)]
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
            if fileinfo.grade == .lovely {
                self.loveItem.setImage(LoadImageByName(imageName: "love_press", type: "png"), for: .normal)

            }else{
                self.loveItem.setImage(LoadImageByName(imageName: "love_normal", type: "png"), for: .normal)
            }
        }
        self.title = fileinfo.fileName
        currentIndex = page
        indexLabel.text = String(format: "%d/%d", currentIndex+1,totalCount)

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
    //TODO:分享
    @objc func shareItemClick()
    {
        let fileInfo = fileArr[currentIndex]
        let videoPath = String.VideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
        let url = URL(fileURLWithPath: videoPath)
        presentShareActivityWith(dataArr: [url as NSObject]) { (error) in}
    }
    //TODO:收藏
    @objc func loveItemClick()
    {
        let fileInfo = fileArr[currentIndex]

        if fileInfo.grade == .normal {
            fileInfo.grade = .lovely
            loveItem.setImage(LoadImageByName(imageName: "love_press", type: "png"), for: .normal)
            CDSqlManager.instance().updateOneSafeFileGrade(grade: .lovely, fileId: fileInfo.fileId)
        }else{
            fileInfo.grade = .normal
            loveItem.setImage(LoadImageByName(imageName: "love_normal", type: "png"), for: .normal)
            CDSqlManager.instance().updateOneSafeFileGrade(grade: .normal, fileId: fileInfo.fileId)
        }

        self.fileArr[currentIndex] = fileInfo
    }
    @objc func editItemClick(){
        let fileInfo = fileArr[currentIndex]
        let segmentVC = CDSegmentVideoViewController()
        segmentVC.videoInfo = fileInfo
        self.navigationController?.pushViewController(segmentVC, animated: true)

    }
    //TODO:删除
    @objc func deleteItemItemClick()
    {
        let fileInfo = fileArr[currentIndex]

        let sheet = UIAlertController(title: nil, message: "删除照片", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (action) in
            let thumbPath = String.thumpVideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
            fileManagerDeleteFileWithFilePath(filePath: thumbPath)
            //删除加密大图
            let defaultPath = String.VideoPath().appendingPathComponent(str: fileInfo.filePath.lastPathComponent())
            fileManagerDeleteFileWithFilePath(filePath: defaultPath)
            CDSqlManager.instance().deleteOneSafeFile(fileId: fileInfo.fileId)

            DispatchQueue.main.async {
                CDHUD.hide()
                CDHUDManager.shareInstance().showText(text: "删除成功")

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
