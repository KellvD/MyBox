//
//  CDSegmentVideoViewController.swift
//  MyRule
//
//  Created by changdong on 2019/6/19.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

import AVKit
class CDSegmentVideoViewController: CDBaseAllViewController {

    var videoInfo:CDSafeFileInfo!
    private var playerView:CDVideoPlayerView!
    private var sliderView:CDMediaSlider!
    private var timeLength:Double = 0
    private var gprocess:Double = 0
    private var videoPath:String!
    private var isHiddenBottom:Bool! = false
    private var barView:UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.isTranslucent = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.navigationBar.isTranslucent = false
        self.playerView.dellocPlayer()
        if isHiddenBottom {
            onBarsHiddenOrNot()
        }
    }
    override var prefersStatusBarHidden: Bool{
        return isHiddenBottom
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = videoInfo.fileName
        self.view.backgroundColor = UIColor.black
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneSegmentVideo))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white

        videoPath = String.RootPath().appendingPathComponent(str: videoInfo.filePath)
        timeLength = GetVideoLength(path: videoPath)
        playerView = CDVideoPlayerView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        playerView.videoPath = videoPath
        self.view.addSubview(playerView)
        
        playerView.processHandle = {[weak self](process) in
            self?.gprocess = process
            self!.sliderView.updateProcess(process: process)
        }
        
        barView = UIView(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - 100.0, width: CDSCREEN_WIDTH, height: 100))
        barView.backgroundColor = UIColor.white
        self.view.addSubview(barView)
        
        sliderView = CDMediaSlider(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 48))
        sliderView.timeLength = timeLength
        barView.addSubview(sliderView)
        sliderView.sliderValueChange = {[weak self] (value:Double) in
            self!.playerView.setPlayerTime(currentTime: value)
     
        }

        let reduceItem = UIButton(type: .custom)
        reduceItem.frame = CGRect(x: CDSCREEN_WIDTH/2 - 65, y: 50, width: 35, height: 35)
        reduceItem.setImage(LoadImage("减号-黑"), for: .normal)
        reduceItem.addTarget(self, action: #selector(onReduceCurrentTime), for: .touchUpInside)
        barView.addSubview(reduceItem)

        let increaseItem = UIButton(type: .custom)
        increaseItem.frame = CGRect(x: CDSCREEN_WIDTH/2 + 15, y: 50, width: 35, height: 35)
        increaseItem.setImage(LoadImage("加号-黑"), for: .normal)
        increaseItem.addTarget(self, action: #selector(onIncreaseCurrentTime), for: .touchUpInside)
        barView.addSubview(increaseItem)


        let videoTap = UITapGestureRecognizer(target: self, action: #selector(onBarsHiddenOrNot))
        self.view.addGestureRecognizer(videoTap)

    }
    //
    @objc func onDoneSegmentVideo(){
        let urlAsset = AVURLAsset(url: URL(fileURLWithPath: videoPath), options: nil)
        let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetPassthrough)
        let currentTime = GetTimestamp()

        let exportPath = String.VideoPath().appendingPathComponent(str: "\(currentTime).mp4")
        let exportUrl = URL(fileURLWithPath: exportPath)
        exportSession?.outputURL = exportUrl
        exportSession?.outputFileType = .mov
        let startCMTime = CMTimeMakeWithSeconds(0, preferredTimescale: self.playerView.player.currentTime().timescale)
        
        let duration = CMTimeMakeWithSeconds(timeLength, preferredTimescale: self.playerView.player.currentTime().timescale)
        let range = CMTimeRangeMake(start: startCMTime, duration: duration)
        exportSession?.timeRange = range
        exportSession?.exportAsynchronously(completionHandler: {
            if exportSession?.status == .completed{
                CDHUDManager.shared.showComplete("剪辑完成")
                CDSignalTon.shared.saveSafeFileInfo(fileUrl: exportUrl, folderId: self.videoInfo.folderId, subFolderType: .VideoFolder,isFromDocment: false)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }

    
    @objc func onReduceCurrentTime(){
        
        guard gprocess < 0.5 else {
            gprocess -= 0.5
            self.playerView.setPlayerTime(currentTime: gprocess)
            self.sliderView.updateProcess(process: gprocess)
            return
        }
    }
    
    @objc func onIncreaseCurrentTime(){
        guard gprocess > timeLength - 0.5 else {
            gprocess += 0.5
            self.playerView.setPlayerTime(currentTime: gprocess)
            self.sliderView.updateProcess(process: gprocess)
            return
        }
    }
    
    //MARK:NotificationCenter
    @objc func onBarsHiddenOrNot(){
        self.isHiddenBottom = !self.isHiddenBottom
        var rect = self.barView.frame
        UIView.animate(withDuration: 0.25) {
            rect.origin.y = self.isHiddenBottom ? CDSCREEN_HEIGTH : (CDSCREEN_HEIGTH - 100.0)
            self.barView.frame = rect
        }
        
        self.navigationController?.setNavigationBarHidden(self.isHiddenBottom, animated: true)
        

    }

   

}



