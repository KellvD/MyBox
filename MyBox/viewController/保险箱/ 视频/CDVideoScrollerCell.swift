//
//  CDVideoScrollerCell.swift
//  MyRule
//
//  Created by changdong on 2019/5/12.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import AVFoundation
class CDVideoScrollerCell: UICollectionViewCell {
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
        self.addGestureRecognizer(videoTap!)
        videoTap!.isEnabled = false
    }


    func setVideoToView(fileInfo:CDSafeFileInfo) {
        playBtn.isHidden = false
        viewFlagV.isHidden = true
        videoSizeL.isHidden = false
        videoTap?.isEnabled = true

        let tmpPath = String.thumpVideoPath().appendingFormat("/%@",fileInfo.thumbImagePath.lastPathComponent())
        let videoPath = String.VideoPath().appendingFormat("/%@",fileInfo.filePath.lastPathComponent())
        videoUrl = URL(fileURLWithPath: videoPath)
        var mImgage:UIImage! = UIImage(contentsOfFile: tmpPath)
        if mImgage == nil {
            mImgage = LoadImageByName(imageName: "小图解密失败", type:"png")
        }

        itemH = (mImgage.size.height * self.frame.width)/mImgage.size.width
        imageView.frame = CGRect(x: 0, y: (self.frame.height - itemH)/2, width: self.frame.width, height: itemH)
        imageView.image = mImgage
        playBtn.frame = CGRect(x: frame.width/2 - 25, y: imageView.frame.height/2 - 25, width: 50, height: 50)


    }

    @objc func onHandleVideoPlay(){
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

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
        playBtn.isHidden = true
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
    }
    func stopPlayer() {
        if isPlaying {
            isPlaying = false
            videoTap?.isEnabled = false
            imageView.isHidden = false
            playBtn.isHidden = false
            player.pause()
            player.currentItem?.cancelPendingSeeks()
            player.currentItem?.asset.cancelLoading()
            player.replaceCurrentItem(with: nil)
            playerLayer.removeFromSuperlayer()
            player = nil;
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

        }

    }

    @objc func playerItemDidFinish(){
        stopPlayer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
