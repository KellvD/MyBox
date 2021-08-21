//
//  CDVideoPlayerView.swift
//  MyBox
//
//  Created by cwx889303 on 2021/8/12.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit
import AVKit

typealias CDVideoPlayerProgressHandle = (_ process:Double)->()
class CDVideoPlayerView: UIView {

    private var playButton:UIButton!
    private var videoTap:UITapGestureRecognizer!
    private var isPlaying = false
    private var gvideoPath:String!
    private var coveryView:UIImageView!
    private var gprocessHandle:CDVideoPlayerProgressHandle!
    var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        coveryView = UIImageView()
        coveryView.isUserInteractionEnabled = true
        self.addSubview(coveryView)

        playButton = UIButton(type: .custom)
        playButton.frame = CGRect(x: frame.width/2.0 - 25, y: frame.height/2.0 - 25, width: 50, height: 50)
        playButton.setImage(LoadImage("play"), for: .normal)
        playButton.addTarget(self, action: #selector(onHandleVideoPlay), for: .touchUpInside)
        self.addSubview(playButton)
        
        
        videoTap = UITapGestureRecognizer(target: self, action: #selector(onCanclePlay))
        self.addGestureRecognizer(videoTap)
        videoTap.isEnabled = false

              
        NotificationCenter.default.addObserver(self, selector: #selector(onCanclePlay), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

    }

    var videoPath: String {
        get {
            return gvideoPath
        }
        set {
            gvideoPath = newValue
            let mImgage:UIImage! = UIImage.previewImage(videoUrl: URL(fileURLWithPath: gvideoPath))
            
            let itemH = (mImgage.size.height * frame.width)/mImgage.size.width
            coveryView.frame = CGRect(x: 0, y: (frame.height - itemH)/2, width: frame.width, height: itemH)
            coveryView.image = mImgage
            createPlayer()
            
        }
    }
    
    var processHandle: CDVideoPlayerProgressHandle {
        get {
            return gprocessHandle
        }
        set {
            gprocessHandle = newValue
            self.player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [self] (cmTime) in
                let currentTime = CMTimeGetSeconds(cmTime)
                gprocessHandle(Double(currentTime))
                
            }
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createPlayer() {
        let urlAsset = AVURLAsset(url: URL(fileURLWithPath: videoPath), options: nil)
        let playerItem = AVPlayerItem(asset: urlAsset)
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        
        dellocPlayer()
        player  = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.videoGravity = .resizeAspectFill
        self.playerLayer.frame = coveryView.frame
        self.layer.addSublayer(playerLayer)
        self.layer.insertSublayer(playButton.layer, above: playerLayer)
    }
    
    @objc private func onHandleVideoPlay(){
        
        self.continuePlay()
    }
    
    
    @objc private func onCanclePlay(){
        self.pause()
    }
    
    
    public func dellocPlayer(){
//        print("play delloc")
        if player == nil {
            return
        }
        player.pause()
        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()
        player.replaceCurrentItem(with: nil)
        
        playerLayer.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
//        print("play delloc ok")
    }
    
    public func pause(){
        if self.isPlaying {
            self.videoTap.isEnabled = false
            self.playButton.isHidden = false
            self.player.pause()
            self.isPlaying = false
        }
    }
    
    public func continuePlay(){
        if !self.isPlaying {
            self.videoTap.isEnabled = true
            self.playButton.isHidden = true
            self.player.play()
            self.isPlaying = true
        }
    }
    
    public func setPlayerTime(currentTime:Double){
        self.pause()
        let seekTime = CMTimeMake(value: Int64(currentTime), timescale: 1)
        self.player.seek(to: seekTime)

    }
    
}
