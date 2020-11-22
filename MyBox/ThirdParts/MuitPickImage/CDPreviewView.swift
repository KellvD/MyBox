//
//  CDPreviewView.swift
//  MyRule
//
//  Created by changdong on 2018/12/15.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos
@objc protocol CDFollowPreviewDelegate {
    @objc optional func selectFollowWith(indexPath:IndexPath)
}
@objc protocol CDMainPreviewDelegate {
    @objc optional func scrollMainPreview(lastIndexPath:IndexPath,currentIndexPath:IndexPath)
    @objc optional func selectMainPreview()
}
class CDPreviewView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource {
    
    

    var assetArr:[CDPHAsset] = []
    var itemW:CGFloat = 0
    var itemH:CGFloat = 0
    
    var isVideo:Bool!
    var selectitem:Int = 0 //标记当前展示的cell的item
    private var isMian:Bool = false
    private var identify:String!
    private var isMeDrag:Bool = false //如果main是主动拖动后，就刷新缩略图；如果缩略图主动切换，main跟着刷新，不再刷新缩略图
    weak var followDelegete:CDFollowPreviewDelegate?
    weak var mainDelegete:CDMainPreviewDelegate?
    init(frame:CGRect, layout:UICollectionViewFlowLayout,isMain:Bool) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.delegate = self
        self.dataSource = self
        self.isMian = isMain
        self.identify = isMain ? "mainPreviewIdentify" : "followPreviewIdentify"
        self.register(CDPreviewCell.self, forCellWithReuseIdentifier: identify)
 
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.assetArr.count

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identify, for: indexPath) as! CDPreviewCell
        let asset:CDPHAsset = self.assetArr[indexPath.item]
        if !isMian{
            cell.hideBorder(isHide: self.selectitem != indexPath.item)
        }
        if isVideo{
            cell.setVideoToView(cdAsset: asset, isMain: isMian)
        }else{
            cell.setImageToView(cdAsset: asset, isMain: isMian)
        }

        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if isMian {
            self.mainDelegete?.selectMainPreview!()
        }else{
            if self.selectitem != indexPath.item { //防止单击同一张图做不必要的刷新
                let lastIndexPath = IndexPath(item: self.selectitem, section: 0)
                self.selectitem = indexPath.item
                self.reloadItems(at: [lastIndexPath,indexPath])
                self.followDelegete!.selectFollowWith!(indexPath: indexPath)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isMian && isMeDrag{
            //本次拖动未完成，cell没变，就不刷新
            let index:Int = lroundf(Float(self.contentOffset.x/itemW))
            if self.selectitem != index {//完成一次成功的滚动就去刷新一下
                let lastIndexPath = IndexPath(item: self.selectitem, section: 0)
                let currentIndexPath = IndexPath(item: index, section: 0)
                self.mainDelegete?.scrollMainPreview!(lastIndexPath: lastIndexPath, currentIndexPath: currentIndexPath)
                isMeDrag = false
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isMian {
            //暂停上次播放的
            self.selectitem = lroundf(Float(self.contentOffset.x/itemW))
            let cell:CDPreviewCell = self.visibleCells.first as! CDPreviewCell
            cell.playerItemDidFinish()
            isMeDrag = true
        }
    }


}


import PhotosUI
class CDPreviewCell: UICollectionViewCell {
    private var player:AVPlayer!
    private var playBtn:UIButton!
    private var playerLayer:AVPlayerLayer!
    private var livePhotoView:PHLivePhotoView!//呈现Live图片
    private var imageView:UIImageView! //呈现普通图片
    private var itemH:CGFloat = 0
    private var itemW:CGFloat = 0
    private var asset:PHAsset!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        itemH = frame.height
        itemW = frame.width

        livePhotoView = PHLivePhotoView(frame: CGRect(x: 0, y: 0, width:itemW, height: itemH))
        livePhotoView.isUserInteractionEnabled = true
        self.addSubview(livePhotoView)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width:itemW, height: itemH))
        imageView.isUserInteractionEnabled = true
        self.addSubview(imageView)

        playBtn = UIButton(type: .custom)
        playBtn.frame = CGRect(x: frame.width/2 - 25, y: imageView.frame.height/2 - 25, width: 50, height: 50)
        playBtn.setImage(LoadImage(imageName: "play", type: "png"), for: .normal)
        playBtn.addTarget(self, action: #selector(startPlayer), for: .touchUpInside)
        imageView.addSubview(playBtn)
        playBtn.isHidden = true
        
        
    }

    public func hideBorder(isHide:Bool){
        if isHide {
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.white.cgColor
        }else{
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.green.cgColor
            
        }
    }
    
    public func setImageToView(cdAsset:CDPHAsset,isMain:Bool) {
        
        let scale = isMain ? 1 : UIScreen.main.scale
        let cellSize = CGSize(width: itemW * scale, height: itemH * scale)
        if cdAsset.format == .Live {
            imageView.isHidden = true
            livePhotoView.isHidden = false
            CDAssetTon.shared.getLivePhotoFromAsset(asset: cdAsset.asset, targetSize: CGSize(width: cellSize.width, height: cellSize.height)) { (livePhoto, info) in
                if livePhoto != nil {
                    self.livePhotoView.livePhoto = livePhoto
                }
            }
        }else{
            imageView.isHidden = false
            livePhotoView.isHidden = true
            
            if cdAsset.format == .Gif {
                CDAssetTon.shared.getImageDataFromAsset(asset: cdAsset.asset) { (data, info) in
                    if isMain {
                        let image = UIImage(data: data!)
                        let width = image!.size.width
                        let height = image!.size.height
                        let scale = width / self.itemW
                        let resultH = height/scale
                        self.imageView.frame = CGRect(x: 0, y: (self.itemH-resultH)/2, width: self.itemW, height: resultH)
                        self.imageView.image = UIImage.gif(data: data!)
                    }else{
                        let image = UIImage(data: data!)
                        self.imageView.image = image
                    }
                    
                }
            }else{
                CDAssetTon.shared.getImageFromAsset(asset: cdAsset.asset, targetSize: CGSize(width: cellSize.width, height: cellSize.height)) { (image, info) in
                    if image != nil{
                        if isMain {
                            let width = image!.size.width
                            let height = image!.size.height
                            let scale = width / self.itemW
                            let resultH = height/scale
                            self.imageView.frame = CGRect(x: 0, y: (self.itemH-resultH)/2, width: self.itemW, height: resultH)
                        }
                        self.imageView.image = image
                    }
                }
            }
        }
        
    }

    public func setVideoToView(cdAsset:CDPHAsset,isMain:Bool) {
        livePhotoView.removeFromSuperview()
        var cellSize = CGSize(width: itemW, height: itemH)
        if isMain {
            playBtn.isHidden = false
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            let scale = UIScreen.main.scale
            cellSize = CGSize(width: itemW * scale, height: itemH * scale)

        }else{
            playBtn.isHidden = true
        }


        asset = cdAsset.asset
        CDAssetTon.shared.getImageFromAsset(asset: cdAsset.asset, targetSize: CGSize(width: cellSize.width, height: cellSize.height)) { (image, info) in
            if image != nil {
                if isMain {
                    let width = image!.size.width
                    let height = image!.size.height
                    let scale = width / self.itemW
                    let resultH = height/scale
                    self.imageView.frame = CGRect(x: 0, y: (self.itemH-resultH)/2, width: self.itemW, height: resultH)
                    self.playBtn.frame = CGRect(x: self.frame.width/2 - 25, y: self.imageView.frame.height/2 - 25, width: 50, height: 50)
                }
                self.imageView.image = image
            }
        }
    }


    @objc private func startPlayer() {
        //播放时在获取URL
        CDAssetTon.shared.getVideoPlayerItem(asset: asset) { (playerItem, info) in
            DispatchQueue.main.async {
                self.player = AVPlayer(playerItem: playerItem)
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer.frame = self.imageView.frame
                self.playerLayer.videoGravity = .resizeAspectFill
                self.layer.addSublayer(self.playerLayer)
                self.player.play()
                self.playBtn.isHidden = true
            }
        }
    }
    

    @objc func playerItemDidFinish(){
        if player != nil{
            player.pause()
            player.currentItem?.cancelPendingSeeks()
            player.currentItem?.asset.cancelLoading()
            player.replaceCurrentItem(with: nil)
            playerLayer.removeFromSuperlayer()
            player = nil;
            playBtn.isHidden = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
