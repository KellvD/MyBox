//
//  CDShareMoveView.swift
//  Share
//
//  Created by cwx889303 on 2021/10/11.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit
import AVFoundation
class CDShareMoveView: UIView {
    private var shareMovieView:UIImageView!
    private var sizeLabel:UILabel!
    private var timeLabel:UILabel!
    private var playBtn:UIButton!
    private var player:AVPlayer!
    private var playerLayer:AVPlayerLayer!
    private var videoTap:UIGestureRecognizer!
    
    private var videoUrl:URL!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        shareMovieView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        shareMovieView.layer.cornerRadius = 4.0
        shareMovieView.clipsToBounds = true
        shareMovieView.backgroundColor = UIColor.clear
        self.addSubview(shareMovieView)
        shareMovieView.contentMode = .scaleAspectFit
        shareMovieView.isUserInteractionEnabled = true
        
        
        sizeLabel = UILabel(frame: CGRect(x: 0, y: frame.height - 40, width: frame.width / 2 - 5, height: 30))
        sizeLabel.textColor = UIColor.white
        sizeLabel.font = UIFont.systemFont(ofSize: 15)
        sizeLabel.textAlignment = .center
        self.addSubview(sizeLabel)

        
        timeLabel = UILabel(frame: CGRect(x: frame.width / 2 + 5, y: frame.height - 40, width: frame.width / 2 - 5, height: 30))
        timeLabel.textColor = UIColor.white
        timeLabel.font = UIFont.systemFont(ofSize: 15)
        timeLabel.textAlignment = .center
        self.addSubview(timeLabel)
        
        let sepertorbottom = UIView(frame: CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1))
        sepertorbottom.backgroundColor = UIColor(red: 243 / 255.0, green: 243 / 255.0, blue: 243 / 255.0, alpha: 1.0)
        self.addSubview(sepertorbottom)
        
        
        videoTap = UITapGestureRecognizer(target: self, action:#selector(onPlayPause))
        shareMovieView.addGestureRecognizer(videoTap)
        
        playBtn = UIButton(type: .custom)
        playBtn.frame = CGRect(x: frame.width / 2 - 25, y: frame.height / 2 - 25, width: 50, height: 50)
        playBtn.setImage(UIImage(named: "play"), for: .normal)
        playBtn.addTarget(self, action: #selector(playMovie), for: .touchUpInside)
        self.addSubview(playBtn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: Notification.Name.init("AVPlayerItemDidPlayToEndTime"), object: nil)

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    
    @objc private func onPlayPause(){
        if player == nil {
            return
        }
        
        if player.timeControlStatus == .playing  {
            self.videoTap.isEnabled = false
            self.playBtn.isHidden = false
            self.player.pause()
        }
    }
    
    
    public func dellocPlayer(){
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
        self.playBtn.isHidden = false
        
    }
    
    
    @objc private func playerItemDidReachEnd(){
        dellocPlayer()
    }

    
    @objc private func playMovie(){
        if self.player == nil{
            createPlayer()
        }
        playContinue()
    }
    
    
    func loadMoveData(url:URL){
        videoUrl = url
        let path = url.absoluteString
        shareMovieView.image = UIImage.previewImage(videoUrl: url)
        
        let data = try? Data(contentsOf: url)
        if data != nil && data!.count > 0 {
            sizeLabel.text = GetSizeFormat(fileSize: data!.count)
        }
        
        timeLabel.text = GetMMSSFromSS(timeLength: GetVideoLength(path: path))
        
    }
    
    
    private func createPlayer(){
        let urlAsset = AVURLAsset(url: videoUrl, options: nil)
        let playerItem = AVPlayerItem(asset: urlAsset)
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        
        player  = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.videoGravity = .resizeAspectFill
        self.playerLayer.frame = shareMovieView.bounds
        self.layer.addSublayer(playerLayer)
        self.layer.insertSublayer(playBtn.layer, above: playerLayer)
    }
    
    private func playContinue(){
        if player.timeControlStatus != .playing{
            self.videoTap.isEnabled = true
            self.playBtn.isHidden = true
            self.player.play()
        }
    }
}
