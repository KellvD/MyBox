//
//  CDImageItemPickViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/13.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos
import MJRefresh

let itemWidth_Height = (CDSCREEN_WIDTH-20)/4
let normalLoadCount = 36
class CDAssetPickViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
   
    public var albumItem:CDAlbum!
    public var isVideo:Bool!
    public var assetDelegate:CDAssetSelectedDelagete!

    public var cdAssetArr:[CDPHAsset] = []
    public var photoTab:UICollectionView!
    private var previewBtn:UIButton!
    private var sendBtn:UIButton!
    private var selectCount = 0
    private var progressBgView:UIView!
    private var progressView:UIProgressView!
    private var inputTipLabel:UILabel!
    private var lastLoadIndex:Int = 0
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
        self.previewBtn.addTarget(self, action: #selector(onPreviewClick), for: .touchUpInside)
        bottomV.addSubview(self.previewBtn)

        self.sendBtn = UIButton(type: .custom)
        self.sendBtn .frame = CGRect(x: CDSCREEN_WIDTH-80, y: 4, width: 65, height: 40)
        self.sendBtn .setTitle("发送", for:.normal)
        self.sendBtn.backgroundColor = NavigationColor
        self.sendBtn.titleLabel?.font = TextMidSmallFont
        self.sendBtn.layer.cornerRadius = 4.0
        self.sendBtn .setTitleColor(UIColor.white, for: .normal)
        self.sendBtn .addTarget(self, action: #selector(onSendBtnClick), for: .touchUpInside)
        bottomV.addSubview(self.sendBtn)
        self.previewBtn.isEnabled = false
        self.sendBtn.isEnabled = false
        refleshData(index: lastLoadIndex)
    }
    
    func refleshData(index:Int)  {
        for i in 0..<self.albumItem.fetchResult.count {
            let asset = self.albumItem.fetchResult[i]
            let cdAsset = CDPHAsset()
            cdAsset.asset = asset
            cdAsset.isSelected = .CDFalse

            let resource = PHAssetResource.assetResources(for: asset).first
            cdAsset.fileSize = resource?.value(forKey: "fileSize") as? Int
            cdAsset.fileName = (asset.value(forKey: "filename") as! String)
            cdAsset.videoLength = asset.duration
            if resource?.uniformTypeIdentifier == "com.compuserve.gif" {
                cdAsset.format = .Gif
            } else if asset.mediaSubtypes.contains(.photoLive) {
                cdAsset.format = .Live
            } else{
                cdAsset.format = .Normal
            }
            self.cdAssetArr.append(cdAsset)

        }
        DispatchQueue.main.async {
            self.photoTab.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cdAssetArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoSelectIDentify", for: indexPath) as! CDPhotoItemCell

        let asset:CDPHAsset = self.cdAssetArr[indexPath.item]
        if isVideo {
            cell.setAssetVideoData(cdAsset: asset)
        }else{
            cell.setAssetImageData(cdAsset: asset)

        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! CDPhotoItemCell
        var hidden = cell.selectImageView.isHidden
        let asset:CDPHAsset = self.cdAssetArr[indexPath.item]
        if hidden {
            hidden = false
            asset.isSelected = .CDTrue
            self.selectCount += 1
        }else{
            hidden  = true
            asset.isSelected = .CDFalse
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

    @objc func onPreviewClick(){
        let preViewVC = CDPreviewViewController()
        var selecctArr:[CDPHAsset] = []
        cdAssetArr.forEach { (asset) in
            if asset.isSelected == .CDTrue {
                selecctArr.append(asset)
            }
        }
        preViewVC.assetArr = selecctArr
        preViewVC.isVideo = isVideo
        preViewVC.assetDelegate = assetDelegate
        self.navigationController?.pushViewController(preViewVC, animated: true)
    }

    @objc func onSendBtnClick(){
        var selectArr:[CDPHAsset] = []
       cdAssetArr.forEach { (asset) in
            if asset.isSelected == .CDTrue {
                selectArr.append(asset)
            }
        }
        DispatchQueue.global().async {
            self.assetDelegate.selectedAssetsComplete(assets: selectArr)

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


class CDPhotoItemCell: UICollectionViewCell {

    var imageView:UIImageView!
    var selectImageView:UIImageView!
    var itemWidth:CGFloat = 0.0
    var infoL:UILabel?


    override init(frame:CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.itemWidth = self.frame.width
        self.imageView = UIImageView(frame: CGRect(x: 0.5, y: 0.5, width: frame.width-1, height: frame.height-1))
        self.addSubview(self.imageView)

        self.selectImageView = UIImageView(frame: CGRect(x: 0.5, y: 0.5, width: frame.width-2, height: frame.height-2))
        self.selectImageView.image = UIImage(named: "照片选中@2x")
        self.addSubview(self.selectImageView)
        self.selectImageView.isHidden = true
        
        infoL = UILabel(frame: CGRect(x: 2, y: frame.height - 20, width: frame.width-4, height: 20))
        infoL?.textColor = UIColor.white
        infoL?.textAlignment = .right
        infoL?.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(infoL!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func setAssetImageData(cdAsset:CDPHAsset){
        let asset:PHAsset = cdAsset.asset
        let scale = UIScreen.main.scale
        let cellSize = CGSize(width: itemWidth*scale, height: itemWidth*scale)
        CDAssetTon.shared.getImageFromAsset(asset: asset, targetSize: cellSize) { (image, info) in
            self.imageView.image = image
        }

        if cdAsset.format == .Gif {
            infoL?.isHidden = false
            infoL?.text = "GIF"
            infoL?.font = UIFont.boldSystemFont(ofSize: 12)

        }else if cdAsset.format == .Live {
            infoL?.isHidden = false
            infoL?.text = "LIVE"
            infoL?.font = UIFont.boldSystemFont(ofSize: 12)

        }else{
            infoL?.isHidden = true
        }
        
        if cdAsset.isSelected == .CDTrue{
            self.selectImageView.isHidden = false
        }else{
            self.selectImageView.isHidden = true
        }
        
    }
    public func setAssetVideoData(cdAsset:CDPHAsset){

        let scale = UIScreen.main.scale
        let cellSize = CGSize(width: itemWidth*scale, height: itemWidth*scale)
        CDAssetTon.shared.getImageFromAsset(asset: cdAsset.asset, targetSize: cellSize) { (image, info) in
            self.imageView.image = image
        }
        let videoTime = Int(cdAsset.asset.duration)
        if videoTime > 0 {
            infoL?.isHidden = false
            self.infoL?.text = getMMSSFromSS(second: videoTime)

        }
    }

    func getMMSSFromSS(second:Int)->String{
        let hour = second / 3600
        let minute = (Int(second) % 3600)/3600
        let second = Int(second) % 60
        var format:String = ""
        if hour > 0 {
            format = String.init(format: "%02ld:%02ld:%02ld", hour,minute,second)
        }else{
            format = String.init(format: "%02ld:%02ld", minute,second)
        }
        return format
    }
    
}
