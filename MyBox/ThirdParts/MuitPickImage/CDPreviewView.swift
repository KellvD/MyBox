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
    @objc optional func scrollMainPreview(indexPath:IndexPath)
    @objc optional func selectMainPreview()
}
class CDPreviewView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource {

    var assetArr:[CDPHAsset] = []
    var itemW:CGFloat = 0
    var itemH:CGFloat = 0
    var _isMian:Bool = false
    var isVideo:Bool!
    var identify:String!
    var selectitem = 0
    var currentOffset = 0.0

    weak var followDelegete:CDFollowPreviewDelegate?
    weak var mainDelegete:CDMainPreviewDelegate?
    init(frame:CGRect, layout:UICollectionViewFlowLayout,isMain:Bool) {
        super.init(frame: frame, collectionViewLayout: layout)
        _isMian = isMain
        self.delegate = self
        self.dataSource = self
        if isMain {
            identify = "mainPreviewIdentify"
        }else{
            identify = "followPreviewIdentify"
        }
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
        if selectitem == indexPath.item && !_isMian{
            cell.isShowBorder = true
        }else{
            cell.isShowBorder = false
        }
        if isVideo{
            cell.setVideoToView(cdAsset: asset, isMain: _isMian)
        }else{
            cell.setImageToView(cdAsset: asset, isMain: _isMian)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if _isMian {
            self.mainDelegete?.selectMainPreview!()
        }else{
            selectitem = indexPath.item
            self.followDelegete!.selectFollowWith!(indexPath: indexPath)
            
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if _isMian {
            let offet = scrollView.contentOffset.x/itemW
            let index = Int(roundf(Float(offet)))
            let indexPath:IndexPath = IndexPath(item: index, section: 0)
            self.mainDelegete?.scrollMainPreview!(indexPath: indexPath)
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if _isMian {
        //暂停上次播放的
        let offet = scrollView.contentOffset.x/itemW
        let index = Int(roundf(Float(offet)))
        let cell:CDPreviewCell = self.cellForItem(at: IndexPath(item: index, section: 0)) as! CDPreviewCell
        cell.stopPlayer()
        }
    }


}


import PhotosUI
class CDPreviewCell: UICollectionViewCell {
    private var player:AVPlayer!
    private var playBtn:UIButton!
    private var playerLayer:AVPlayerLayer!
    private var isPlaying:Bool = false
    private var livePhotoView:PHLivePhotoView!//呈现Live图片
    private var imageView:UIImageView! //呈现普通图片
    private var itemH:CGFloat = 0
    private var itemW:CGFloat = 0
    private var asset:PHAsset!
    public var isShowBorder:Bool = false
    


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
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
        playBtn.setImage(LoadImageByName(imageName: "play", type: "png"), for: .normal)
        playBtn.addTarget(self, action: #selector(onHandleVideoPlay), for: .touchUpInside)
        imageView.addSubview(playBtn)
        playBtn.isHidden = true
        
        
    }

    func setImageToView(cdAsset:CDPHAsset,isMain:Bool) {
        playBtn.removeFromSuperview()
        var cellSize = CGSize(width: itemW, height: itemH)
        if !isMain {
            let scale = UIScreen.main.scale
            cellSize = CGSize(width: itemW * scale, height: itemH * scale)
            if isShowBorder {
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.green.cgColor
            }else{
                self.layer.borderWidth = 0.5
                self.layer.borderColor = UIColor.white.cgColor
            }
        }
        if cdAsset.format == .Live {
            imageView.isHidden = true
            livePhotoView.isHidden = false
            CDAssetTon.shareInstance().getLivePhotoFromAsset(asset: cdAsset.asset, targetSize: CGSize(width: cellSize.width, height: cellSize.height)) { (livePhoto, info) in
                if livePhoto != nil {
                    self.livePhotoView.livePhoto = livePhoto
                }
            }
        }else{
            imageView.isHidden = false
            livePhotoView.isHidden = true
            
            CDAssetTon.shareInstance().getImageFromAsset(asset: cdAsset.asset, targetSize: CGSize(width: cellSize.width, height: cellSize.height)) { (image, info) in
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

    func setVideoToView(cdAsset:CDPHAsset,isMain:Bool) {
        livePhotoView.removeFromSuperview()
        var cellSize = CGSize(width: itemW, height: itemH)
        if isMain {
            playBtn.isHidden = false
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            let scale = UIScreen.main.scale
            cellSize = CGSize(width: itemW * scale, height: itemH * scale)

        }else{
            playBtn.isHidden = true
            if isShowBorder {
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.green.cgColor
            }else{
                self.layer.borderWidth = 0.5
                self.layer.borderColor = UIColor.white.cgColor
            }
        }


        asset = cdAsset.asset
        CDAssetTon.shareInstance().getImageFromAsset(asset: cdAsset.asset, targetSize: CGSize(width: cellSize.width, height: cellSize.height)) { (image, info) in
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

    @objc func onHandleVideoPlay(){

        if isPlaying {
            stopPlayer()
        }else{
            initPlayer()
        }
    }

    func initPlayer() {
        isPlaying = true
        //播放时在获取URL
        CDAssetTon.shareInstance().getVideoPlayerItem(asset: asset) { (playerItem, info) in
            DispatchQueue.main.async {
                self.imageView.isHidden = true
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
    func stopPlayer() {
        if isPlaying {
            isPlaying = false
            imageView.isHidden = false
            player.pause()
            player.currentItem?.cancelPendingSeeks()
            player.currentItem?.asset.cancelLoading()
            player.replaceCurrentItem(with: nil)
            playerLayer.removeFromSuperlayer()
            player = nil;
            playBtn.isHidden = false
        }

    }

    @objc func playerItemDidFinish(){
        onHandleVideoPlay()
    }
    @objc func onHandleLivePhotoPlay(){
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
