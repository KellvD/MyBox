//
//  CDImageItemPickViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/13.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos

private let itemWidth_Height = (CDSCREEN_WIDTH-20)/4
class CDPhotoPickViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    var albumItem:CDAlbumItem!
    var cdAssetArr:[CDPHAsset] = []
    var photoTab:UICollectionView!

    var previewBtn:UIButton!
    var sendBtn:UIButton!
    var selectCount = 0
    var isVideo:Bool!
    var assetDelegate:CDAessetSelectionDelagete!

    var progressBgView:UIView!
    var progressView:UIProgressView!
    var inputTipLabel:UILabel!



    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.albumItem.title

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:itemWidth_Height , height: itemWidth_Height)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        self.photoTab = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight-48), collectionViewLayout: layout)
        self.photoTab.delegate = self
        self.photoTab.dataSource = self
        self.photoTab.backgroundColor = UIColor.white
        self.view.addSubview(self.photoTab)
        self.photoTab.register(CDPhotoItemCell.self, forCellWithReuseIdentifier: "photoSelectIDentify")

        let bottomV = UIView(frame: CGRect(x: 0, y: self.photoTab.frame.maxY, width: CDSCREEN_WIDTH, height: 48))
        bottomV.backgroundColor = UIColor.black
        self.view.addSubview(bottomV)
        self.previewBtn = UIButton(type: .custom)
        self.previewBtn.frame = CGRect(x: 15, y: 4, width: 50, height: 40)
        self.previewBtn.setTitle("预览", for:.normal)
        self.previewBtn.setTitleColor(UIColor.white, for: .normal)
        self.previewBtn.addTarget(self, action: #selector(previewClick), for: .touchUpInside)
        bottomV.addSubview(self.previewBtn)

        self.sendBtn = UIButton(type: .custom)
        self.sendBtn .frame = CGRect(x: CDSCREEN_WIDTH-80, y: 4, width: 65, height: 40)
        self.sendBtn .setTitle("发送", for:.normal)
        self.sendBtn.backgroundColor = UIColor.green
        self.sendBtn.titleLabel?.font = TextMidSmallFont
        self.sendBtn.layer.cornerRadius = 4.0
        self.sendBtn .setTitleColor(UIColor.white, for: .normal)
        self.sendBtn .addTarget(self, action: #selector(sendBtnClick), for: .touchUpInside)
        bottomV.addSubview(self.sendBtn)
        self.previewBtn.isEnabled = false
        self.sendBtn.isEnabled = false
        refleshData()
    }

    func refleshData()  {
        if !isVideo {
            for i in 0..<self.albumItem.fetchResult.count {
                let asset = self.albumItem.fetchResult[i]
                let cdAsset = CDPHAsset()
                cdAsset.asset = asset
                cdAsset.isSelected = false
                let manager = PHCachingImageManager()
                let imageRequestOption:PHImageRequestOptions! = PHImageRequestOptions()
                imageRequestOption.isSynchronous = true// PHImageRequestOptions是否有效
                imageRequestOption.resizeMode = .none // 缩略图的压缩模式设置为无
                imageRequestOption.deliveryMode = .opportunistic// 缩略图的质量为高质量，不管加载时间花多少
                if #available(iOS 13, *) {
                    cdAsset.fileName = asset.value(forKey: "filename") as! String
                    manager.requestImageDataAndOrientation(for: asset, options: imageRequestOption) { (data, imageType, oritation, ofo) in
                        let s = String.init(data: data!, encoding: .utf16)
                        
                        if imageType == "com.compuserve.gif"{
                            cdAsset.isGif = true
                        }else{
                            cdAsset.isGif = false
                        }
                        self.cdAssetArr.append(cdAsset)
                        DispatchQueue.main.async {
                            self.photoTab.reloadData()
                        }
                    }
                } else {
                    manager.requestImageData(for: asset, options: imageRequestOption) { (data, imageType, oritation, ofo) in

                        if imageType == "com.compuserve.gif"{
                            cdAsset.isGif = true
                        }else{
                            cdAsset.isGif = false
                        }
                        let filePath:URL = ofo!["PHImageFileURLKey"] as! URL
                        cdAsset.filePath = filePath.absoluteString
                        self.cdAssetArr.append(cdAsset)
                        DispatchQueue.main.async {
                            self.photoTab.reloadData()
                        }
                    }
                }
            }
        }else{
            for i in 0..<self.albumItem.fetchResult.count {
                let asset = self.albumItem.fetchResult[i]
                let cdAsset = CDPHAsset()
                cdAsset.asset = asset
                cdAsset.isSelected = false
                let videoManager = PHImageManager.default()
                let option = PHVideoRequestOptions()
                option.version = .current
                option.isNetworkAccessAllowed = true
                option.deliveryMode = .automatic
                
                videoManager.requestAVAsset(forVideo: asset, options: option) { (avAsset, audioMix, info) in
                    guard let urlAsset: AVURLAsset = avAsset as? AVURLAsset else {
                        print("视频获取失败")
                        return
                    }
                    cdAsset.filePath = urlAsset.url.absoluteString
                    let fileData = NSData(contentsOf: urlAsset.url)
                    cdAsset.videoSize = fileData!.length
                    cdAsset.videoTime = Int(asset.duration)
                    self.cdAssetArr.append(cdAsset)
                    DispatchQueue.main.async {
                        self.photoTab.reloadData()
                    }


                }

            }
        }

    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cdAssetArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoSelectIDentify", for: indexPath) as! CDPhotoItemCell

        let asset:CDPHAsset = self.cdAssetArr[indexPath.item]
        if isVideo {
            cell.setVideoData(cdAsset: asset)
        }else{
            cell.setImageData(cdAsset: asset)

        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! CDPhotoItemCell
        var hidden = cell.selectImageView.isHidden
        let asset:CDPHAsset = self.cdAssetArr[indexPath.item]
        if hidden {
            hidden = false
            asset.isSelected = true
            self.selectCount += 1
        }else{
            hidden  = true
            asset.isSelected = false
            self.selectCount -= 1
        }


        cell.selectImageView.isHidden = hidden
        if self.selectCount > 0 {
            self.previewBtn.isEnabled = true
            self.sendBtn.isEnabled = true
            self.sendBtn.setTitle("发送(\(self.selectCount))", for: .normal)
        }else{
            self.previewBtn.isEnabled = false
            self.sendBtn.isEnabled = false
            self.sendBtn.setTitle("发送", for: .normal)
        }
    }

    @objc func previewClick(){
        let preViewVC = CDPreviewViewController()
        var selecctArr:[CDPHAsset] = []
        for i in 0..<cdAssetArr.count{
            let asset:CDPHAsset = cdAssetArr[i]
            if asset.isSelected {
                selecctArr.append(asset)
            }
        }
        preViewVC.assetArr = selecctArr
        preViewVC.isVideo = isVideo
        preViewVC.assetDelegate = assetDelegate
        self.navigationController?.pushViewController(preViewVC, animated: true)
    }

    @objc func sendBtnClick(){
        var selectArr:[CDPHAsset] = []
        for asset:CDPHAsset in self.cdAssetArr {
            if asset.isSelected {
                selectArr.append(asset)
            }
        }
        DispatchQueue.global().async {
            self.assetDelegate.selectedAssets(assets: selectArr)

        }
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
