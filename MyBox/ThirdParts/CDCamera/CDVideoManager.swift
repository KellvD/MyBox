//
//  CDVideoManager.swift
//  MyBox
//
//  Created by changdong on 2020/5/26.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit

class CDVideoManager: NSObject {

//    var videoInput:AVCaptureDeviceInput!
//    var audioInput:AVCaptureDeviceInput!
//    var captureOutput:AVCaptureMovieFileOutput!
//    var _timer:Timer!
//    var _timeCount = 0
//    var isVideoTakeIng:Bool!
//
//    func addVideoCapturePut(){
//        captureOutput = AVCaptureMovieFileOutput()
//
//        if captureSession.canAddOutput(captureOutput){
//            captureSession.addOutput(captureOutput)
//        }
//
//        videoInput = try! AVCaptureDeviceInput(device: device)
//        let isCanAdd = captureSession.canAddInput(videoInput)
//        if isCanAdd {
//            captureSession.addInput(videoInput)
//        }
//
//        if let audioCaptureDevice = AVCaptureDevice.devices(for: .audio).first {
//            audioInput = try? AVCaptureDeviceInput(device: audioCaptureDevice)
//            if audioInput != nil{
//                if captureSession.canAddInput(audioInput) {
//                    captureSession.addInput(audioInput)
//                }
//            }
//        }
//
//        let con = captureOutput.connection(with: .video)
//        if device.position == .front{
//            con?.isVideoMirrored = true;
//        }else{
//            con?.isVideoMirrored = false;
//        }
//    }
//
//    func startTake(){
//        if isVideoTakeIng{
//            _timeCount = 0;
//            topBar.timeLabel?.text = "00:00:00"
//            captureOutput.stopRecording()
//        }else{
//            perform(#selector(onStarToRecordIngVideo), with: nil, afterDelay: 1.0)
//        }
//    }
}
