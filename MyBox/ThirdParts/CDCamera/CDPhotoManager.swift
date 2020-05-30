//
//  CDPhotoManager.swift
//  MyBox
//
//  Created by changdong on 2020/5/26.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit
import AVFoundation
typealias PhotoTakeDoneHandle = (_ originalImage:UIImage) -> UIImage
class CDPhotoManager: NSObject,AVCapturePhotoCaptureDelegate {
    var captureSession:AVCaptureSession!
    var device:AVCaptureDevice!
    var stillConnection:AVCaptureConnection!
    var imageInput:AVCaptureDeviceInput!
    var imageOutput:AVCapturePhotoOutput!
    var takeDone:PhotoTakeDoneHandle!
    
    
    func initWithAVCapture() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        device = createDevice(position: .back)
        if isVideo{
            addVideoCapturePut()
        }else{
            addImageCapturePut()
        }
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    func createDevice(position:AVCaptureDevice.Position) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices(for: .video)
        var tmpdevice:AVCaptureDevice!

        for device in devices {
            if device.position == position{
                tmpdevice = device
                break;
            }
        }
        return tmpdevice
    }
    func addImageCapturePut(){
        if imageOutput != nil {
            captureSession.removeOutput(imageOutput)
        }
        if imageInput != nil {
            captureSession.removeInput(imageInput)
        }
        imageOutput = AVCapturePhotoOutput.init()


        if captureSession.canAddOutput(imageOutput){
            captureSession.addOutput(imageOutput)
        }

        imageInput = try! AVCaptureDeviceInput(device: device)
        if captureSession.canAddInput(imageInput) {
            captureSession.addInput(imageInput)
        }
        stillConnection = imageOutput.connection(with: .video)
        if device.position == .front{
            stillConnection.isVideoMirrored = true;
        }else{
            stillConnection.isVideoMirrored = false;
        }
    }
    
    func startTakePhoto(){
        let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
        imageOutput.capturePhoto(with: setting, delegate: self)
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if error != nil{
            print("拍照失败：\(error.debugDescription)")
        }else{

            
            let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let image = UIImage(data: data!)!
            self.captureSession.stopRunning()
            takeDone(image)
        }
    }
}
