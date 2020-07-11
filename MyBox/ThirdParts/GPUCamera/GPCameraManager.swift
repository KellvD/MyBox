//
//  GPCameraManager.swift
//  CPCamera
//
//  Created by changdong  on 2020/6/4.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit
import GPUImage
import Foundation
typealias GPUCameraTakePhotoComplete = (_ image:UIImage?) ->Void
typealias GPUCameraTakeVideoComplete = (_ videoUrl:URL?) ->Void
typealias GPUUpdateDelayComplete = (_ delay:Int,_ isEnd:Bool) ->Void

class GPCameraManager: NSObject,GPUImageVideoCameraDelegate {
    var filter:GPUImageFilter!
    var moveWriter:GPUImageMovieWriter!
    var stillCamera:GPUImageStillCamera!
    var videoCamera:GPUImageVideoCamera!
    var takePhotoComplete:GPUCameraTakePhotoComplete!
    var takeVideoComplete:GPUCameraTakeVideoComplete!
    var updateDelayComplete:GPUUpdateDelayComplete!
    var isVideoRecording:Bool = false
    var _isVideo:Bool!
    var topBar:CDCameraTopBar!

    private var _timer:Timer!
    private var _timeCount = 0
    private var delayNum:Int!
    var preview:GPUImageView!

    init(baseView:UIView,isVideo:Bool) {
        super.init()
        stillCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: AVCaptureDevice.Position.back)
        stillCamera!.outputImageOrientation = .portrait

        preview = GPUImageView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        baseView.addSubview(preview)

        filter = GPUImageBoxBlurFilter()
        filter.addTarget(preview)
        stillCamera!.addTarget(filter)
        stillCamera!.startCapture()

        _isVideo = isVideo
        //放大缩小手势
//        let pitch = UIPinchGestureRecognizer(target: self, action: #selector(onZoomViewAction(pitch:)))
//        pitch.delegate = self
//        baseView.addGestureRecognizer(pitch)
//
//        //对焦手势
//        let tap = UITapGestureRecognizer(target: self, action: #selector(onSetFocusPoint(tap:)))
//        baseView.addGestureRecognizer(tap)

//        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
//    @objc func orientationDidChange(noti:Notification){
//        let orientation = UIDevice.current.orientation as UIInterfaceOrientation
//        videoCamera.outputImageOrientation = orientation
//    }
    func readyTakePhoto(){
        let delayModel = UserDefaults.standard.integer(forKey: DelayKey)
        delayNum = delayModel == 0 ? 0 : delayModel == 1 ? 3 : 10
        //不延时拍照
        if delayNum == 0 {
            recordPhoto()
        }else{
            openTimer()
        }
    }


    func recordPhoto(){
//        let photoOutput = camer
        let stillCamera = videoCamera as? GPUImageStillCamera
        stillCamera?.capturePhotoAsJPEGProcessedUp(toFilter: filter, withCompletionHandler: { (data, error) in
            if error == nil{
                let image = UIImage(data: data!)
                self.takePhotoComplete(image!)
            }else{
                self.takePhotoComplete(nil)
                print("拍照失败:%s",error!.localizedDescription)
            }
        })
    }
    func startRecordVideo(){
        let time = getCurrentTimestamp()
        let videoPath = String.VideoPath().appendingPathComponent(str: "\(time).mp4")
        let url = URL(fileURLWithPath: videoPath)
        moveWriter = GPUImageMovieWriter(movieURL: url, size: CGSize(width: 480.0, height: 640.0), fileType: AVFileType.mp4.rawValue, outputSettings: nil)
        moveWriter.setHasAudioTrack(true, audioSettings: nil)
        videoCamera.audioEncodingTarget = moveWriter
        moveWriter?.startRecording()
        isVideoRecording = true
        openTimer()
    }
    func stopRecordVideo(){
        moveWriter.finishRecording {
            self.filter.removeTarget(self.moveWriter)
            self.moveWriter.finishRecording()
            self.takeVideoComplete(self.moveWriter.assetWriter.outputURL)
        }


    }
    func reloadLayer(){
        videoCamera.startCapture()
    }

    func cameraTurnAround(){
        videoCamera.stopCapture()
        if videoCamera.cameraPosition() == .back {
            videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: AVCaptureDevice.Position.front)

        } else {
            videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: AVCaptureDevice.Position.back)
        }
        videoCamera.horizontallyMirrorRearFacingCamera = false
        videoCamera.horizontallyMirrorFrontFacingCamera = true
        videoCamera!.outputImageOrientation = .portrait
        videoCamera!.addTarget(filter)
        videoCamera!.startCapture()
    }

    //MARK:拍照延时 + 视频计时
    func openTimer() {
        if _timer == nil {
            _timer = Timer.init(timeInterval: 1.0, target: self, selector: #selector(observedRecordTime), userInfo: nil, repeats: true)
            RunLoop.current.add(_timer, forMode: .default)

        }
        _timer.fire()
    }
    func closeTimer() {
        if _timer != nil {
            _timer.invalidate()
            _timer = nil
            _timeCount = 0
            if _isVideo {
                topBar.updateTimeLabel(time: 0)
            }

        }
    }
    @objc func observedRecordTime(){
        _timeCount += 1
        if _isVideo {
            topBar.updateTimeLabel(time: _timeCount)
        } else {
            if _timeCount <= delayNum {
                updateDelayComplete(_timeCount,false)
            }else{
                updateDelayComplete(0,true)
                closeTimer()
                delayNum = 0
                recordPhoto()
            }

        }

    }

//    lazy var audioSetting: [AnyHashable:String] = {
//        var channelLayout:AudioChannelLayout!
//        memset(&channelLayout, 0, sizeofValue(AudioChannelLayout))
//        channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo
//        let audioSetting = [NSNumber(value: kAudioFormatMPEG4AAC):AVFormatIDKey,
//                            NSNumber(value: 2):AVNumberOfChannelsKey,
//                            NSNumber(value: 16000.0):AVSampleRateKey,
//
//        NSData(bytesNoCopy: &channelLayout, length: sizeofValue(AudioChannelLayout), freeWhenDone: AVChannelLayoutKey),
//        ]
//        return audioSetting
//    }()
//
//    lazy var videoSetting: [AnyHashable:String] = {
//        let videoSetting = [:]
//        return videoSetting
//    }()
}
