//
//  CDImageScrollerViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/28.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import CDMediaEditor

class CDImageScrollerViewController: CDBaseAllViewController {

    public var inputArr: [CDSafeFileInfo] = [] // 所有照片文件
    public var currentIndex: Int!   // 当前索引位置
    public var folderId: Int!

    private var indexLabel: UILabel!
    private var collectionView: UICollectionView!
    private var isHiddenBottom: Bool! = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.isTranslucent = true

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.navigationBar.isTranslucent = false
    }

    override var prefersStatusBarHidden: Bool {
        return isHiddenBottom
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let fileInfo = inputArr[currentIndex]
        self.title = fileInfo.fileName
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH)
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
        collectionView.register(CDImageCell.self, forCellWithReuseIdentifier: "imageScrollerr")
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: LoadImage("fileDetail"), style: .plain, target: self, action: #selector(detailBtnClicked))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white

        self.view.addSubview(self.toolBar)
        self.toolBar.loveItem.setImage(LoadImage(fileInfo.grade == .lovely ? "menu_love_press" : "menu_love_normal"), for: .normal)

        indexLabel = UILabel(frame: CGRect(x: (CDSCREEN_WIDTH - 50)/2, y: self.toolBar.minY - 40, width: 50, height: 30))
        indexLabel.textAlignment = .center
        indexLabel.textColor = UIColor.lightGray
        indexLabel.font = .mid
        indexLabel.text = String(format: "%d/%d", currentIndex+1, inputArr.count)
        indexLabel.backgroundColor = UIColor.clear
        self.view.addSubview(indexLabel)
        let videoTap = UITapGestureRecognizer(target: self, action: #selector(onBarsHiddenOrNot))
        self.view.addGestureRecognizer(videoTap)

        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

    }

    lazy var toolBar: CDToolBar = {
        let bar = CDToolBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - BottomBarHeight, width: CDSCREEN_WIDTH, height: BottomBarHeight), barType: .ImageScrollerTools, superVC: self)
        return bar
    }()

    func tapQR(message: String) {
        let sheet = UIAlertController(title: "", message: "二维码", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "前往图中所包含的公众号", style: .default, handler: { (_) in
            let webVC = CDWebViewController()
            webVC.url = URL(string: message)!
            self.navigationController?.pushViewController(webVC, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: nil))
        present(sheet, animated: true, completion: nil)

    }

    @objc func detailBtnClicked() {
        let fileInfo = inputArr[currentIndex]
        let fileDetail = CDFileDetailViewController()
        fileDetail.fileInfo = fileInfo
        self.navigationController?.pushViewController(fileDetail, animated: true)
    }
    // MARK: 分享
    @objc func shareBarItemClick() {
        let fileInfo = inputArr[currentIndex]
        let imagePath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
        let url = imagePath.url
        presentShareActivityWith(dataArr: [url as NSObject]) { (_) in}
    }

    // MARK: 收藏
    @objc func loveItemClick() {
        let fileInfo = inputArr[currentIndex]
        if fileInfo.grade == .normal {
            fileInfo.grade = .lovely
            self.toolBar.loveItem.setImage(LoadImage("menu_love_press"), for: .normal)
            CDSqlManager.shared.updateOneSafeFileGrade(grade: .lovely, fileId: fileInfo.fileId)
        } else {
            fileInfo.grade = .normal
            self.toolBar.loveItem.setImage(LoadImage("menu_love_normal"), for: .normal)
            CDSqlManager.shared.updateOneSafeFileGrade(grade: .normal, fileId: fileInfo.fileId)
        }
    }

    // MARK: 删除
    @objc func deleteBarItemClick() {
        let fileInfo = inputArr[currentIndex]
        let sheet = UIAlertController(title: nil, message: "删除照片".localize, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "确定".localize, style: .destructive, handler: { (_) in
            let thumbPath = String.RootPath().appendingPathComponent(str: fileInfo.thumbImagePath)
            thumbPath.delete()
            let defaultPath = String.RootPath().appendingPathComponent(str: fileInfo.filePath)
            defaultPath.delete()
            CDSqlManager.shared.deleteOneSafeFile(fileId: fileInfo.fileId)
            self.inputArr.remove(at: self.currentIndex!)
            DispatchQueue.main.async {
                CDHUDManager.shared.showComplete("删除完成".localize)
                self.collectionView.reloadData()
            }

        }))
        sheet.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)

    }

    @objc func editItemClick() {
        let fileInfo = inputArr[currentIndex]
        let image = UIImage(contentsOfFile: String.RootPath().appendingPathComponent(str: fileInfo.filePath))
        let photoConfig = PhotoEditorConfiguration()
        let vc = EditorController.init(image: image!, config: photoConfig)
        vc.photoEditorDelegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

    // MARK: NotificationCenter
    @objc func onBarsHiddenOrNot() {
        self.isHiddenBottom = !self.isHiddenBottom
        var rect = self.toolBar.frame
        UIView.animate(withDuration: 0.25) {
            rect.origin.y = self.isHiddenBottom ? CDSCREEN_HEIGTH : (CDSCREEN_HEIGTH - BottomBarHeight)
            self.toolBar.frame = rect
        }

        self.navigationController?.setNavigationBarHidden(self.isHiddenBottom, animated: true)

    }

}

extension CDImageScrollerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inputArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageScrollerr", for: indexPath) as! CDImageCell
        let tmpFile: CDSafeFileInfo = inputArr[indexPath.item]
        cell.setScrollerImageData(fileInfo: tmpFile)
        cell.longTapHandle = {(massage) -> Void in
            self.tapQR(message: massage)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let firstIndexPath = collectionView.indexPathsForVisibleItems.first

        let page = firstIndexPath!.item
        let fileinfo = inputArr[page]
        DispatchQueue.main.async {
            self.toolBar.loveItem.setImage(LoadImage(fileinfo.grade == .lovely ? "menu_love_press" : "menu_love_normal"), for: .normal)
            self.toolBar.editItem.isEnabled = !(fileinfo.fileType == .GifType)
        }

        self.title = fileinfo.fileName
        currentIndex = page
        indexLabel.text = String(format: "%d/%d", currentIndex+1, inputArr.count)
    }

}

extension CDImageScrollerViewController: PhotoEditorViewControllerDelegate {
    func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController, didFinish result: PhotoEditResult) {

        CDSignalTon.shared.saveFileWithUrl(fileUrl: result.editedImageURL, folderId: self.folderId, subFolderType: .ImageFolder, isFromDocment: false)
    }

    func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController, loadTitleChartlet response: @escaping EditorTitleChartletResponse) {
        let chartLet = EditorChartlet(image: "weixiao".image)
        response([chartLet])
    }
    func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController, titleChartlet: EditorChartlet, titleIndex: Int, loadChartletList response: @escaping EditorChartletListResponse) {
        let emojiPath = Bundle.main.path(forResource: "ClassicExpressionPNGList", ofType: "plist")
        let arr = NSArray(contentsOfFile: emojiPath!) as! [NSDictionary]
        var charts: [EditorChartlet] = []
        arr.forEach { item in
            let name = item.object(forKey: "png") as! String
//            let title = item["zh-Hant"] as! String

            let chartLet = EditorChartlet(image: name.image)
            charts.append(chartLet)
        }
        response(titleIndex, charts)
    }

}
