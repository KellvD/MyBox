//
//  CDVideoPlayerView.swift
//  MyBox
//
//  Created by changdong on 2021/8/12.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import AVKit

typealias CDVideoPlayerProgressHandle = (_ process:Double)->()
class CDVideoPlayerView: UIView {

    private var playButton:UIButton!
    private var videoTap:UITapGestureRecognizer!
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
        
        
        videoTap = UITapGestureRecognizer(target: self, action: #selector(onPlayPause))
        self.addGestureRecognizer(videoTap)
        videoTap.isEnabled = false

              
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

    }

    var videoPath: String! {
        didSet {
            let mImgage:UIImage! = UIImage.previewImage(videoUrl: videoPath.url)
            
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
        let urlAsset = AVURLAsset(url: videoPath.url, options: nil)
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
        if self.player == nil{
            createPlayer()
        }
        playContinue()
    }
    @objc func onPlayFinished(){
        setPlayerTime(currentTime: 0)
    }
    
    @objc private func onPlayPause(){
        if player == nil {
            return
        }
        
        if player.timeControlStatus == .playing  {
            self.videoTap.isEnabled = false
            self.playButton.isHidden = false
            self.player.pause()
        }
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
        player = nil
        playerLayer.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.videoTap.isEnabled = false
        self.playButton.isHidden = false
        
    }
    
    public func playContinue(){
        if player.timeControlStatus != .playing{
            self.videoTap.isEnabled = true
            self.playButton.isHidden = true
            self.player.play()
        }
        
        
    }
    
    public func setPlayerTime(currentTime:Double){
        
        onPlayPause()
        let seekTime = CMTimeMake(value: Int64(currentTime), timescale: 1)
        self.player.seek(to: seekTime)

    }
    
}
