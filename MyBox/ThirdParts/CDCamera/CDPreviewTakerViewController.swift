//
//  CDPreviewTakerViewController.swift
//  MyBox
//
//  Created by changdong on 2020/5/26.
//  Copyright © 2019 changdong. 2012-2019. All rights reserved.
//

import UIKit
import AVFoundation
typealias CDPreviewDoneHandle = (_ success:Bool) -> Void
class CDPreviewTakerViewController: UIViewController {
    private var preview:UIImageView!
    private var playerLayer:AVPlayerLayer!
    private var player:AVPlayer!
    private var playBtn:UIButton!
    
    var videoUrl:URL?
    var isVideo:Bool = false
    var origialImage:UIImage!
    var previewHandle:CDPreviewDoneHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //顶部工具栏
        let naviBar = UIImageView(frame: CGRect(x: 0, y: StatusHeight, width: CDSCREEN_WIDTH, height: 48))
        naviBar.isUserInteractionEnabled = true
        naviBar.backgroundColor = .white
        self.view.addSubview(naviBar)
        
        //返回按钮
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 1.5, width: 45, height: 45)
        backBtn.setImage(LoadImageByName(imageName: "back_blue", type: "png"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        naviBar.addSubview(backBtn)
        
        let timeLabel = UILabel(frame: CGRect(x: CDSCREEN_WIDTH/2 - 75, y: 6, width: 150, height: 36))
        timeLabel.text = "今天" + timestampTurnString(timestamp: getCurrentTimestamp())
        timeLabel.textAlignment = .center
        timeLabel.textColor = TextLightBlackColor
        timeLabel.font = TextMidSmallFont
        naviBar.addSubview(timeLabel)
        
        //底部工具栏
        let toolBar = UIImageView(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH-48, width: CDSCREEN_WIDTH, height: 48))
        toolBar.isUserInteractionEnabled = true
        toolBar.image = UIImage(named: "下导航-bg")
        self.view.addSubview(toolBar)
        
        let edit = UIButton(type: .custom)
        edit.frame = CGRect(x: 15, y: 1.5, width: 45, height: 45)
        edit.setTitle("编辑", for:.normal)
        edit.setTitleColor(CustomBlueColor, for: .normal)
        edit.addTarget(self, action: #selector(editClick), for: .touchUpInside)
        toolBar.addSubview(edit)
        
        playBtn = UIButton(type: .custom)
        playBtn.frame = CGRect(x: CDSCREEN_WIDTH/2 - 45/2, y: 1.5, width: 45, height: 45)
        playBtn.setImage(LoadImageByName(imageName: "audiostop", type: "png"), for: .normal)
        playBtn.addTarget(self, action: #selector(playVideoClick), for: .touchUpInside)
        toolBar.addSubview(playBtn)
        
        let saveBtn = UIButton(type: .custom)
        saveBtn.frame = CGRect(x: CDSCREEN_WIDTH - 60, y: 1.5, width: 45, height: 45)
        saveBtn.setTitle("保存", for:.normal)
        saveBtn.setTitleColor(CustomBlueColor, for: .normal)
        saveBtn.addTarget(self, action: #selector(makeSureSaveTaker), for: .touchUpInside)
        toolBar.addSubview(saveBtn)
        
        //预览界面
        preview = UIImageView(frame: CGRect(x: 0, y: naviBar.frame.maxY, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH - naviBar.frame.maxY - toolBar.frame.height))
        self.view.addSubview(preview)
        
        if isVideo {
            initPlayer()
        }else{
            preview.image = origialImage
            playBtn.isHidden = true
            
        }
    }

    
    
    @objc func backButtonClick(){
        previewHandle(false)
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @objc func makeSureSaveTaker(){
        
        if isVideo {
            self.dismiss(animated: false, completion: nil)
            distoryPlayer()
            previewHandle(true)
        }else{
            self.dismiss(animated: false, completion: nil)

            previewHandle(true)
            
        }
        
    }
    
//    @objc private func outputPhotoComplete(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
//
//    }
    
    
    @objc func editClick(){
        
    }
    @objc func playVideoClick(){
        if player == nil {
            initPlayer()
        }else if player.timeControlStatus == .playing {
            //正在播放就暂停
            player.pause()
            playBtn.setImage(LoadImageByName(imageName: "audioplay", type: "png"), for: .normal)

        }else if player.timeControlStatus == .paused {
            //暂停了就播放
            player.play()
            playBtn.setImage(LoadImageByName(imageName: "audiostop", type: "png"), for: .normal)

        }
    }
    
    func initPlayer() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        playBtn.setImage(LoadImageByName(imageName: "audiostop", type: "png"), for: .normal)
        let urlAsset = AVURLAsset(url: videoUrl!, options: nil)
        let playerItem = AVPlayerItem(asset: urlAsset)
        let session = AVAudioSession.sharedInstance()
        
        try! session.setCategory(.playAndRecord, options: .defaultToSpeaker)

        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = preview.bounds
        playerLayer.videoGravity = .resizeAspectFill
        preview.layer.addSublayer(playerLayer)
        player.play()
    }
    func distoryPlayer() {
        if player != nil {
            player.pause()
            player.currentItem?.cancelPendingSeeks()
            player.currentItem?.asset.cancelLoading()
            player.replaceCurrentItem(with: nil)
            playerLayer.removeFromSuperlayer()
            playerLayer = nil
            player = nil;
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }

    @objc func playerItemDidFinish(){
        playBtn.setImage(LoadImageByName(imageName: "audioplay", type: "png"), for: .normal)
        player.pause()
        player.currentItem?.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    
    func timestampTurnString(timestamp:Int)->String{
        let formter = DateFormatter()
        formter.dateFormat = "HH:mm:ss"
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp/1000))
        let dateStr = formter.string(from: date)
        return dateStr
    }
}



