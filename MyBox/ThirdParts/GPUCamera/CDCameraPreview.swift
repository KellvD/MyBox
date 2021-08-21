//
//  CDCameraPreview.swift
//  CDCamera
//
//  Created by changdong on 2019/5/24.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit
import AVFoundation
protocol CDCameraPreviewDelegate :NSObjectProtocol {
    func onCameraPreviewToRetake()
    func onCameraPreviewToEdit()
    func onCameraPreviewToSave()
}
class CDCameraPreview: UIView {

    var imageView:UIImageView!
    var delegate:CDCameraPreviewDelegate!
    var isPlaying:Bool = false
    
    var playerLayer:AVPlayerLayer!
    var player:AVPlayer!
    var videoUrl:URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.addSubview(imageView)


        let space:CGFloat = (frame.width - 80 * 3)/4
        let width:CGFloat = 80
        let Y = frame.height - width - 50


        let retake = UIButton(type: .custom)
        retake.frame = CGRect(x: space, y: Y, width: width, height: width)
        retake.layer.cornerRadius = width/2
        retake.backgroundColor = UIColor.init(red: 245/225.0, green: 222/255.0, blue: 179/255.0, alpha: 1)
        retake.setImage(UIImage(named: "retake"), for: .normal)
        retake.setTitleColor(UIColor.white, for: .normal)
        retake.addTarget(self, action: #selector(onTakePhotoAgain), for: .touchUpInside)
        self.addSubview(retake)

        let edit = UIButton(type: .custom)
        edit.frame = CGRect(x: space * 2 + width , y: Y, width: width, height: width)
        edit.layer.cornerRadius = width/2
        edit.backgroundColor = UIColor.init(red: 245/225.0, green: 222/255.0, blue: 179/255.0, alpha: 1)
        edit.setImage(UIImage(named: "edit"), for: .normal)
        edit.addTarget(self, action: #selector(oneEditPhotoClick), for: .touchUpInside)
        self.addSubview(edit)

        let save = UIButton(type: .custom)
        save.frame = CGRect(x: space * 3 + width * 2, y: Y, width: width, height: width)
        save.layer.cornerRadius = width/2
        save.backgroundColor = UIColor.white
        save.setImage(UIImage(named: "save"), for: .normal)
        save.setTitleColor(UIColor.white, for: .normal)
        save.addTarget(self, action: #selector(onUserPhotoClick), for: .touchUpInside)
        self.addSubview(save)



    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc func onTakePhotoAgain(){
        delegate.onCameraPreviewToRetake()
    }
    @objc func oneEditPhotoClick(){
        delegate.onCameraPreviewToEdit()
    }

    @objc func onUserPhotoClick(){
        delegate.onCameraPreviewToSave()
    }
    
    
    func initPlayer() {
        isPlaying = true
        
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

    
}
