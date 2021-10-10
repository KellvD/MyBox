//
//  CDPreviewTakerViewController.swift
//  MyBox
//
//  Created by changdong on 2020/5/26.
//  Copyright © 2019 changdong. 2012-2019. All rights reserved.
//

import UIKit
import AVFoundation
import CDMediaEditor
typealias CDPreviewDoneHandle = (_ success:Bool) -> Void
typealias CDPreviewEditPhotoComplete = (_ image:UIImage?) ->Void
typealias CDPreviewEditVideoComplete = (_ videoUrl:URL?) ->Void

class CDPreviewTakerViewController: UIViewController {
    private var preview:UIImageView!
    private var playerLayer:AVPlayerLayer!
    private var player:AVPlayer!
    private var playBtn:UIButton!
    
    var videoUrl:URL?
    var isVideo:Bool = false
    var origialImage:UIImage!
    var previewHandle:CDPreviewDoneHandle!
    var previewEditPhotoHandle:CDPreviewEditPhotoComplete!
    var previewEditVideoHandle:CDPreviewEditVideoComplete!
    var cameraVC:CDCameraViewController!
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //顶部工具栏
        let naviBar = UIImageView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 44 + NavigationHeight))
        naviBar.isUserInteractionEnabled = true
        naviBar.backgroundColor = .white
        self.view.addSubview(naviBar)
        
        //返回按钮
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: NavigationHeight + 1.5, width: 45, height: 45)
        backBtn.setImage(LoadImage("back_blue"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        naviBar.addSubview(backBtn)
        
        let timeLabel = UILabel(frame: CGRect(x: CDSCREEN_WIDTH/2 - 75, y: 6, width: 150, height: 36))
        timeLabel.text = "今天" + timestampTurnString(timestamp: GetTimestamp(nil))
        timeLabel.textAlignment = .center
        timeLabel.textColor = .textLightBlack
        timeLabel.font = .midSmall
        naviBar.addSubview(timeLabel)
        
        //底部工具栏
        let toolBar = UIImageView(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - BottomBarHeight, width: CDSCREEN_WIDTH, height: BottomBarHeight))
        toolBar.isUserInteractionEnabled = true
        toolBar.image = UIImage(named: "下导航-bg")
        self.view.addSubview(toolBar)
        
        let edit = UIButton(type: .custom)
        edit.frame = CGRect(x: 15, y: 5, width: 45, height: 45)
        edit.setTitle("编辑", for:.normal)
        edit.setTitleColor(.customBlue, for: .normal)
        edit.addTarget(self, action: #selector(editClick), for: .touchUpInside)
        toolBar.addSubview(edit)
        
        playBtn = UIButton(type: .custom)
        playBtn.frame = CGRect(x: CDSCREEN_WIDTH/2 - 45/2, y: 1.5, width: 45, height: 45)
        playBtn.setImage(LoadImage("audiostop"), for: .normal)
        playBtn.addTarget(self, action: #selector(playVideoClick), for: .touchUpInside)
        toolBar.addSubview(playBtn)
        
        let saveBtn = UIButton(type: .custom)
        saveBtn.frame = CGRect(x: CDSCREEN_WIDTH - 60, y: 5, width: 45, height: 45)
        saveBtn.setTitle("保存", for:.normal)
        saveBtn.setTitleColor(.customBlue, for: .normal)
        saveBtn.addTarget(self, action: #selector(makeSureSaveTaker), for: .touchUpInside)
        toolBar.addSubview(saveBtn)
        
        //预览界面
        preview = UIImageView(frame: CGRect(x: 0, y: naviBar.frame.maxY, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH - naviBar.frame.height - toolBar.frame.height))
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
    
    @objc func editClick(){
        if isVideo {
            let config = VideoEditorConfiguration()
            let videoEditVC = EditorController(videoURL: videoUrl!, config: config)
            videoEditVC.modalPresentationStyle = .fullScreen
            videoEditVC.videoEditorDelegate = self
            present(videoEditVC, animated: true, completion: nil)
        }else{
            let photoConfig = PhotoEditorConfiguration()
            let vc = EditorController.init(image: origialImage!, config: photoConfig)
            vc.photoEditorDelegate = self
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
//
    }
    
    @objc func playVideoClick(){
        if player == nil {
            initPlayer()
        }else if player.timeControlStatus == .playing {
            //正在播放就暂停
            player.pause()
            playBtn.setImage(LoadImage("menu_audioplay"), for: .normal)

        }else if player.timeControlStatus == .paused {
            //暂停了就播放
            player.play()
            playBtn.setImage(LoadImage("audiostop"), for: .normal)

        }
    }
    
    func initPlayer() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        playBtn.setImage(LoadImage("audiostop"), for: .normal)
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
        playBtn.setImage(LoadImage("menu_audioplay"), for: .normal)
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



extension CDPreviewTakerViewController:VideoEditorViewControllerDelegate,PhotoEditorViewControllerDelegate{
    func videoEditorViewController(_ videoEditorViewController: VideoEditorViewController, didFinish result: VideoEditResult){
        self.dismiss(animated: false, completion: {
            self.previewEditVideoHandle(result.editedURL)
        })

        
    }
    
    func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController, didFinish result: PhotoEditResult) {
        self.dismiss(animated: false, completion: {
            self.previewEditPhotoHandle(result.editedImage)
        })
        
        
    }
}
