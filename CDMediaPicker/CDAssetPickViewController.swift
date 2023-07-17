//
//  CDImageItemPickViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/13.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos

class CDAssetPickViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    public var albumItem: CDAlbum!
    public var isVideo: Bool!
    public weak var assetDelegate: CDAssetSelectedDelagete!

    private var cdAssetArr: [CDPHAsset] = []
    private var photoTab: UICollectionView!
    private var previewBtn: UIButton!
    private var sendBtn: UIButton!
    private var selectCount = 0
    private var progressBgView: UIView!
    private var progressView: UIProgressView!
    private var inputTipLabel: UILabel!
    private var lastLoadIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.albumItem.title
        self.navigationController!.navigationBar.topItem?.title = ""
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth_Height, height: itemWidth_Height)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        self.photoTab = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight - BottomBarHeight), collectionViewLayout: layout)
        self.photoTab.delegate = self
        self.photoTab.dataSource = self
        self.photoTab.backgroundColor = UIColor.white
        self.view.addSubview(self.photoTab)
        self.photoTab.register(CDPhotoItemCell.self, forCellWithReuseIdentifier: "photoSelectIDentify")

        let bottomV = UIView(frame: CGRect(x: 0, y: self.photoTab.frame.maxY, width: CDSCREEN_WIDTH, height: BottomBarHeight))
        bottomV.backgroundColor = UIColor.black
        self.view.addSubview(bottomV)
        self.previewBtn = UIButton(type: .custom)
        self.previewBtn.frame = CGRect(x: 15, y: 5, width: 50, height: 40)
        self.previewBtn.setTitle("预览", for: .normal)
        self.previewBtn.setTitleColor(UIColor.gray, for: .disabled)
        self.previewBtn.setTitleColor(UIColor.white, for: .normal)
        self.previewBtn.addTarget(self, action: #selector(onPreviewClick), for: .touchUpInside)
        bottomV.addSubview(self.previewBtn)

        self.sendBtn = UIButton(type: .custom)
        self.sendBtn.frame = CGRect(x: CDSCREEN_WIDTH-120, y: 5.0, width: 100, height: 40)
        self.sendBtn.setTitle("发送", for: .normal)
        self.sendBtn.setTitleColor(UIColor.white, for: .normal)
        self.sendBtn.setTitleColor(UIColor.gray, for: .disabled)
        self.sendBtn.addTarget(self, action: #selector(onSendBtnClick), for: .touchUpInside)
        self.sendBtn.titleLabel?.textAlignment = .right
        bottomV.addSubview(self.sendBtn)
        self.previewBtn.isEnabled = false
        self.sendBtn.isEnabled = false
        refleshData(index: lastLoadIndex)
    }

    func refleshData(index: Int) {
        DispatchQueue.global().async {
            for i in 0..<self.albumItem.fetchResult.count {
                let asset = self.albumItem.fetchResult[i]
                let cdAsset = CDPHAsset()
                cdAsset.asset = asset
                cdAsset.isSelected = .CD_False

                let resource = PHAssetResource.assetResources(for: asset).first
                cdAsset.fileSize = (resource?.value(forKey: "fileSize") as! Int) as Int
                cdAsset.fileName = (asset.value(forKey: "filename") as! String)
                cdAsset.videoLength = asset.duration
                if resource?.uniformTypeIdentifier == "com.compuserve.gif" {
                    cdAsset.format = .Gif
                } else if asset.mediaSubtypes.contains(.photoLive) {
                    cdAsset.format = .Live
                } else {
                    cdAsset.format = .Normal
                }
                self.cdAssetArr.append(cdAsset)
                // 先刷新30个，避免进入界面空白
                DispatchQueue.main.async {
                    if self.cdAssetArr.count == 30 {
                        self.photoTab.reloadData()
                    }
                }

            }
            DispatchQueue.main.async {
                self.photoTab.reloadData()
            }
        }

    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cdAssetArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoSelectIDentify", for: indexPath) as! CDPhotoItemCell
        let asset: CDPHAsset = self.cdAssetArr[indexPath.item]
        if isVideo {
            cell.setAssetVideoData(cdAsset: asset)
        } else {
            cell.setAssetImageData(cdAsset: asset)

        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! CDPhotoItemCell
        var hidden = cell.selectImageView.isHidden
        let asset: CDPHAsset = self.cdAssetArr[indexPath.item]
        if hidden {
            hidden = false
            asset.isSelected = .CD_True
            self.selectCount += 1
        } else {
            hidden  = true
            asset.isSelected = .CD_False
            self.selectCount -= 1
        }

        cell.selectImageView.isHidden = hidden
        if self.selectCount > 0 {
            self.previewBtn.isEnabled = true
            self.sendBtn.isEnabled = true
            self.sendBtn.setTitle("发送(\(self.selectCount))", for: .normal)
        } else {
            self.previewBtn.isEnabled = false
            self.sendBtn.isEnabled = false
            self.sendBtn.setTitle("发送", for: .normal)
        }
    }

    @objc func onPreviewClick() {
        let preViewVC = CDPreviewViewController()
        var selecctArr: [CDPHAsset] = []

        for asset in cdAssetArr where asset.isSelected == .CD_True {
            selecctArr.append(asset)
        }
        preViewVC.assetArr = selecctArr
        preViewVC.isVideo = isVideo
        preViewVC.assetDelegate = assetDelegate
        self.navigationController?.pushViewController(preViewVC, animated: true)
    }

    @objc func onSendBtnClick() {
        self.sendBtn.isEnabled = false
        var selectArr: [CDPHAsset] = []
       cdAssetArr.forEach { (asset) in
            if asset.isSelected == .CD_True {
                selectArr.append(asset)
            }
        }
        DispatchQueue.global().async {
            self.assetDelegate.selectedAssetsComplete(phAssets: selectArr)

        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class CDPhotoItemCell: UICollectionViewCell {

    private var imageView: UIImageView!
    public var selectImageView: UIImageView!
    private var itemWidth: CGFloat = 0.0
    private var formatLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        itemWidth = self.frame.width - 1
        imageView = UIImageView(frame: CGRect(x: 0.5, y: 0.5, width: frame.width-1, height: frame.height-1))
        imageView.contentMode = .scaleToFill
        self.addSubview(imageView)

        selectImageView = UIImageView(frame: CGRect(x: 0.5, y: 0.5, width: frame.width-2, height: frame.height-2))
        selectImageView.image = UIImage(named: "照片选中")
        self.addSubview(selectImageView)
        selectImageView.isHidden = true

        formatLabel = UILabel(frame: CGRect(x: 2, y: frame.height - 20, width: frame.width-4, height: 20))
        formatLabel?.textColor = UIColor.white
        formatLabel?.textAlignment = .right
        formatLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.addSubview(formatLabel!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func setAssetImageData(cdAsset: CDPHAsset) {
        let asset: PHAsset = cdAsset.asset
        let scale = UIScreen.main.scale
        let cellSize = CGSize(width: itemWidth*scale, height: itemWidth*scale)
        CDAssetTon.shared.getImageFromAsset(asset: asset, targetSize: cellSize) { (image, _) in
            self.imageView.image = image
        }
        formatLabel?.isHidden = cdAsset.format == .Normal
        formatLabel?.text = cdAsset.format.rawValue
        self.selectImageView.isHidden = !(cdAsset.isSelected == .CD_True)

    }

    public func setAssetVideoData(cdAsset: CDPHAsset) {

        let scale = UIScreen.main.scale
        let cellSize = CGSize(width: itemWidth*scale, height: itemWidth*scale)
        CDAssetTon.shared.getImageFromAsset(asset: cdAsset.asset, targetSize: cellSize) { (image, _) in
            self.imageView.image = image
        }
        let videoTime = cdAsset.asset.duration
        if videoTime > 0 {
            formatLabel?.isHidden = false
            self.formatLabel?.text = GetMMSSFromSS(second: videoTime)

        }
    }

}
