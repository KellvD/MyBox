//
//  CDPreviewCell.swift
//  MyRule
//
//  Created by changdong on 2019/4/26.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
class CDPreviewCell: UICollectionViewCell {
    var player:AVPlayer!
    var playBtn:UIButton!
    var playerLayer:AVPlayerLayer!
    var isPlaying:Bool = false
    var imageView:UIImageView!
    var viewFlagV:UIImageView!
    var videoSizeL:UILabel!
    var videoTap:UITapGestureRecognizer?

    var itemH:CGFloat = 0
    var itemW:CGFloat = 0
    var isShow:Bool = false
    var videoUrl:URL?



    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        itemH = frame.height
        itemW = frame.width


        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width:itemW, height: itemH))
        imageView.isUserInteractionEnabled = true
        self.addSubview(imageView)

        viewFlagV = UIImageView(frame: CGRect(x: imageView.frame.width - 25, y: imageView.frame.height - 25, width: 24, height: 24))
        viewFlagV.image = LoadImageByName(imageName: "videoFlag", type: "png")
        imageView.addSubview(viewFlagV)
        viewFlagV.isHidden = true

        playBtn = UIButton(type: .custom)
        playBtn.frame = CGRect(x: frame.width/2 - 25, y: imageView.frame.height/2 - 25, width: 50, height: 50)
        playBtn.setImage(LoadImageByName(imageName: "play", type: "png"), for: .normal)
        playBtn.addTarget(self, action: #selector(onHandleVideoPlay), for: .touchUpInside)
        imageView.addSubview(playBtn)
        playBtn.isHidden = true

        videoSizeL = UILabel(frame: CGRect(x: imageView.frame.width-100, y: 5, width: 85, height: 20))
        videoSizeL.textAlignment = .right
        videoSizeL.font = TextSmallFont
        videoSizeL.textColor = UIColor.white
        imageView.addSubview(videoSizeL)
        videoSizeL.isHidden = true

        videoTap = UITapGestureRecognizer(target: self, action: #selector(playerItemDidFinish))
        imageView.addGestureRecognizer(videoTap!)
        videoTap!.isEnabled = false
    }

    func setImageToView(cdAsset:CDPHAsset,isMain:Bool) {

        var cellSize = CGSize(width: itemW, height: itemH)
        if !isMain {
            let scale = UIScreen.main.scale
            cellSize = CGSize(width: itemW * scale, height: itemH * scale)

            if isShow {
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.green.cgColor
            }else{
                self.layer.borderWidth = 0.5
                self.layer.borderColor = UIColor.white.cgColor
            }
        }

        CDAssetTon.shareInstance().getImageFromAsset(asset: cdAsset.asset, targetSize: CGSize(width: cellSize.width, height: cellSize.height)) { (image, info) in
            if isMain {
                let width = image.size.width
                let height = image.size.height
                let scale = width / self.itemW
                let resultH = height/scale
                self.imageView.frame = CGRect(x: 0, y: (self.itemH-resultH)/2, width: self.itemW, height: resultH)
            }
            self.imageView.image = image
        }
    }

    func setVideoToView(cdAsset:CDPHAsset,isMain:Bool) {
        var cellSize = CGSize(width: itemW, height: itemH)
        if isMain {
            playBtn.isHidden = false
            viewFlagV.isHidden = true
            videoSizeL.isHidden = false
            videoTap?.isEnabled = true
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            let scale = UIScreen.main.scale
            cellSize = CGSize(width: itemW * scale, height: itemH * scale)

        }else{
            playBtn.isHidden = true
            viewFlagV.isHidden = false
            videoSizeL.isHidden = true
            videoTap?.isEnabled = false
            if isShow {
                self.layer.borderWidth = 2
                self.layer.borderColor = UIColor.green.cgColor
            }else{
                self.layer.borderWidth = 0.5
                self.layer.borderColor = UIColor.white.cgColor
            }
        }

        self.videoSizeL.text = returnSize(fileSize: cdAsset.videoSize)
        self.videoUrl = URL(fileURLWithPath: cdAsset.filePath)

        CDAssetTon.shareInstance().getImageFromAsset(asset: cdAsset.asset, targetSize: CGSize(width: cellSize.width, height: cellSize.height)) { (image, info) in
            if isMain {
                let width = image.size.width
                let height = image.size.height
                let scale = width / self.itemW
                let resultH = height/scale
                self.imageView.frame = CGRect(x: 0, y: (self.itemH-resultH)/2, width: self.itemW, height: resultH)
                self.playBtn.frame = CGRect(x: self.frame.width/2 - 25, y: self.imageView.frame.height/2 - 25, width: 50, height: 50)
            }

            self.imageView.image = image
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
        imageView.isHidden = true
        videoTap?.isEnabled = true
        let urlAsset = AVURLAsset(url: videoUrl!, options: nil)
        let playerItem = AVPlayerItem(asset: urlAsset)
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(.playAndRecord, options: .defaultToSpeaker)

        player = AVPlayer(playerItem: playerItem)

        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = imageView.frame
        playerLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(playerLayer)
        player.play()
        playBtn.isHidden = true
    }
    func stopPlayer() {
        if isPlaying {
            isPlaying = false
            videoTap?.isEnabled = false
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
        stopPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
