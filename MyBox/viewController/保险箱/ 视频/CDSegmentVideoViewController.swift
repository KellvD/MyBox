//
//  CDSegmentVideoViewController.swift
//  MyRule
//
//  Created by changdong on 2019/6/19.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

import AVKit
class CDSegmentVideoViewController: CDBaseAllViewController,AVAudioPlayerDelegate {

    var videoInfo:CDSafeFileInfo!
    var playBtn:UIImageView!
    var imageView:UIImageView!
    var videoTap:UITapGestureRecognizer!
    var isPlayIng = false

    var timeLength:Double = 0
    var hasPlayTimeLab:UILabel!
    var sliderView:UISlider!
    var player:AVPlayer!
    var playerLayer:AVPlayerLayer!
    var videoPath:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = videoInfo.fileName
        self.view.backgroundColor = UIColor.black
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneSegmentVideo))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white

        let tmpPath = String.thumpVideoPath().appendingFormat("/%@",videoInfo.thumbImagePath.lastPathComponent())
        videoPath = String.VideoPath().appendingFormat("/%@",videoInfo.filePath.lastPathComponent())
        var mImgage:UIImage! = UIImage(contentsOfFile: tmpPath)
        if mImgage == nil {
            mImgage = LoadImage(imageName: "小图解密失败", type:"png")
        }

        let itemH = (mImgage.size.height * self.view.frame.width)/mImgage.size.width
        imageView = UIImageView(frame: CGRect(x: 0, y: (CDSCREEN_WIDTH - itemH)/2, width: CDSCREEN_WIDTH, height: itemH))
        imageView.isUserInteractionEnabled = true
        imageView.image = mImgage
        self.view.addSubview(imageView)

        playBtn = UIImageView(frame: CGRect(x: CDSCREEN_WIDTH/2 - 25, y: imageView.frame.minY + itemH/2 - 25, width: 50, height: 50))
        playBtn.image = LoadImage(imageName: "play", type: "png")
        playBtn.isUserInteractionEnabled = true
        playBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHandleVideoPlay)))

        
        videoTap = UITapGestureRecognizer(target: self, action: #selector(onCanclePlay))
        imageView.addGestureRecognizer(videoTap)
        videoTap.isEnabled = false


        timeLength = GetVideoLength(path: videoPath)

        let urlAsset = AVURLAsset(url: URL(fileURLWithPath: videoPath), options: nil)
        let playerItem = AVPlayerItem(asset: urlAsset)
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = imageView.frame
        playerLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(playerLayer)
        self.view.addSubview(playBtn)
        let playView = UIView(frame: CGRect(x: 0, y: CDViewHeight - 100, width: CDSCREEN_WIDTH, height: 100))
        playView.backgroundColor = UIColor.white
        self.view.addSubview(playView)

        hasPlayTimeLab = UILabel(frame: CGRect(x: 10, y: 14, width: 35, height: 20))
        hasPlayTimeLab.textColor = TextGrayColor
        hasPlayTimeLab.backgroundColor = UIColor.clear
        hasPlayTimeLab.font = TextSmallFont
        hasPlayTimeLab.text = GetMMSSFromSS(second: 0)
        hasPlayTimeLab.adjustsFontSizeToFitWidth = true
        playView.addSubview(hasPlayTimeLab)

        sliderView = UISlider(frame: CGRect(x: hasPlayTimeLab.frame.maxX+5, y: 14, width: CDSCREEN_WIDTH-90, height: 20))
        sliderView.setThumbImage(UIImage(named: "sliderPoint"), for: .normal)
        sliderView.minimumValue = 0
        sliderView.maximumValue = Float(timeLength)
        sliderView.addTarget(self, action: #selector(onSliderChangePlayTime), for: .valueChanged)
        playView.addSubview(sliderView)

        let remainTimeLab = UILabel(frame: CGRect(x: sliderView.frame.maxX, y: 14, width: 35, height: 20))
        remainTimeLab.textColor = TextGrayColor
        remainTimeLab.backgroundColor = UIColor.clear
        remainTimeLab.font = TextSmallFont
        remainTimeLab.text = GetMMSSFromSS(second: timeLength)
        remainTimeLab.adjustsFontSizeToFitWidth = true
        playView.addSubview(remainTimeLab)

        let reduceItem = UIButton(type: .custom)
        reduceItem.frame = CGRect(x: CDSCREEN_WIDTH/2 - 65, y: 50, width: 35, height: 35)
        reduceItem.setImage(UIImage(named: "微调减"), for: .normal)
        reduceItem.addTarget(self, action: #selector(onReduceCurrentTime), for: .touchUpInside)
        playView.addSubview(reduceItem)

        let increaseItem = UIButton(type: .custom)
        increaseItem.frame = CGRect(x: CDSCREEN_WIDTH/2 + 15, y: 50, width: 35, height: 35)
        increaseItem.setImage(UIImage(named: "微调加"), for: .normal)
        increaseItem.addTarget(self, action: #selector(onIncreaseCurrentTime), for: .touchUpInside)
        playView.addSubview(increaseItem)


        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)


    }
    @objc func onDoneSegmentVideo(){
        let urlAsset = AVURLAsset(url: URL(fileURLWithPath: videoPath), options: nil)
        let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetPassthrough)
        let currentTime = GetTimestamp()

        let exportPath = String.VideoPath().appendingPathComponent(str: "\(currentTime).mp4")
        let exportUrl = URL(fileURLWithPath: exportPath)
        exportSession?.outputURL = exportUrl
        exportSession?.outputFileType = .mov
        let startCMTime = CMTimeMakeWithSeconds(0, preferredTimescale: player.currentTime().timescale)
        
        let duration = CMTimeMakeWithSeconds(timeLength, preferredTimescale: player.currentTime().timescale)
        let range = CMTimeRangeMake(start: startCMTime, duration: duration)
        exportSession?.timeRange = range
        exportSession?.exportAsynchronously(completionHandler: {
            if exportSession?.status == .completed{
                CDSignalTon.shared.saveSafeFileInfo(tmpFileUrl: exportUrl, folderId: self.videoInfo.folderId, subFolderType: .VideoFolder)
            }
        })




    }
    @objc func onHandleVideoPlay(){
        DispatchQueue.main.async {
            self.imageView.isHidden = true
            self.videoTap.isEnabled = true
            self.playBtn.isHidden = true
            self.isPlayIng = true
            self.player.play()
            self.player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { (cmTime) in
                let currentTime = CMTimeGetSeconds(cmTime)
                self.sliderView.value = Float(currentTime)
                self.hasPlayTimeLab.text = GetMMSSFromSS(second: currentTime)

            }
        }
    }
    @objc func onCanclePlay(){
        DispatchQueue.main.async {
            self.videoTap.isEnabled = false
            self.playBtn.isHidden = false
            self.isPlayIng = false
            self.player.pause()
        }

    }

    @objc func onSliderChangePlayTime(){
        if isPlayIng {
            player.pause()
        }
        let currentTime = Double(sliderView.value)
        hasPlayTimeLab.text = GetMMSSFromSS(second: currentTime)
        setPlayerTime(currentTime: currentTime)
        if isPlayIng {
            player.play()
        }

    }
    @objc func playerItemDidFinish() {
        stopPlayer()
    }
    @objc func onReduceCurrentTime(){
        var currentTime = Double(sliderView.value)
        if currentTime < 0.5 {
            return
        }
        if isPlayIng {
            player.pause()
        }
        currentTime -= 0.5
        sliderView.value = Float(currentTime)
        hasPlayTimeLab.text = GetMMSSFromSS(second: currentTime)
        setPlayerTime(currentTime: currentTime)
        if isPlayIng {
            player.play()
        }
    }
    @objc func onIncreaseCurrentTime(){
        var currentTime = Double(sliderView.value)
        if currentTime > timeLength - 0.5 {
            return
        }
        if isPlayIng {
            player.pause()
        }
        currentTime += 0.5
        sliderView.value = Float(currentTime)
        
        hasPlayTimeLab.text = GetMMSSFromSS(second: currentTime)
        setPlayerTime(currentTime: currentTime)
        if isPlayIng {
            player.play()
        }
    }
    func setPlayerTime(currentTime:Double){

        let seekTime = CMTimeMake(value: Int64(currentTime), timescale: 1)
        player.seek(to: seekTime)
        print("kk = •ƒ\(CMTimeGetSeconds(player.currentItem!.currentTime()))")

    }

    @objc func stopPlayer(){
        imageView.isHidden = false
        playBtn.isHidden = false
        videoTap.isEnabled = false
        isPlayIng = false
        player.pause()
        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()
        player.replaceCurrentItem(with: nil)
        playerLayer.removeFromSuperlayer()
        player.removeTimeObserver(self)
        player = nil;
        sliderView.value = 0
        hasPlayTimeLab.text = GetMMSSFromSS(second: 0)

    }

}



