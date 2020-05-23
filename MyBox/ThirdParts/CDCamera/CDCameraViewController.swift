//
//  CDCameraViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/24.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import AVFoundation
@objc protocol CDCameraViewControllerDelegate {

    @objc optional func onCameraTakePhotoDidFinshed(cameraVC:CDCameraViewController,image:UIImage)
    @objc optional func onCameraTakePhotoDidCancle(cameraVC:CDCameraViewController)
    @objc optional func onCameraTakePhotoDidFinshed(cameraVC:CDCameraViewController,videoUrl:URL)
}
class CDCameraViewController: UIViewController,AVCaptureFileOutputRecordingDelegate,CDCameraBottomBarDelegate,CDCameraPreviewDelegate,UIGestureRecognizerDelegate,AVCapturePhotoCaptureDelegate {


    var delegate:CDCameraViewControllerDelegate!
    var captureSession:AVCaptureSession!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var device:AVCaptureDevice!
    var stillConnection:AVCaptureConnection!
    var imageInput:AVCaptureDeviceInput!
    var imageOutput:AVCapturePhotoOutput!

    var videoInput:AVCaptureDeviceInput!
    var audioInput:AVCaptureDeviceInput!
    var captureOutput:AVCaptureMovieFileOutput!
    var _timer:Timer!
    var _timeCount = 0
    var currentZoomFactor:CGFloat = 0

    var bottomBar:CDCameraBottomBar!
    var photoPreview:CDCameraPreview!
    var topBar:CDCameraTopBar!


    var image:UIImage!
    var isVideo:Bool!
    var isVideoTakeIng:Bool!
    var focusCursor:UIImageView!//聚焦光标


    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initWithAVCapture()
        topBar = CDCameraTopBar(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 48), isVideo: isVideo)
        self.view.addSubview(topBar)
        isVideoTakeIng = false
        
        bottomBar = CDCameraBottomBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - 140, width: CDSCREEN_WIDTH, height: 140))
        bottomBar.delegate = self
        self.view.addSubview(bottomBar)

        photoPreview = CDCameraPreview(frame: self.view.bounds)
        photoPreview.delegate = self
        self.view.addSubview(photoPreview)
        photoPreview.isHidden = true

        focusCursor = UIImageView(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2), size: CGSize(width: 100, height: 100)))
        focusCursor.image = LoadImageByName(imageName: "frame", type: "png")
        focusCursor.isHidden = true
        self.view.addSubview(focusCursor)

        //放大缩小手势
        let pitch = UIPinchGestureRecognizer()
        pitch.delegate = self
        pitch.addTarget(self, action: #selector(onZoomViewAction(pitch:)))
        self.view.addGestureRecognizer(pitch);

        //对焦手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSetFocusPoint(tap:)))
        self.view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(autoFocusModel), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: device)
    }


    func initWithAVCapture() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        //设定预览界面
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(previewLayer)

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

//        let audioSession = AVAudioSession()
//        do {
//            try audioSession.setCategory(.record)
//            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.)
//        } catch {
//
//        }

    }
    func addVideoCapturePut(){
        captureOutput = AVCaptureMovieFileOutput()

        if captureSession.canAddOutput(captureOutput){
            captureSession.addOutput(captureOutput)
        }

        videoInput = try! AVCaptureDeviceInput(device: device)
        let isCanAdd = captureSession.canAddInput(videoInput)
        if isCanAdd {
            captureSession.addInput(videoInput)
        }
        if let audioCaptureDevice = AVCaptureDevice.devices(for: .audio).first {
            audioInput = try? AVCaptureDeviceInput(device: audioCaptureDevice)
            if audioInput != nil{
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                }
            }
        }

        let con = captureOutput.connection(with: .video)
        if device.position == .front{
            con?.isVideoMirrored = true;
        }else{
            con?.isVideoMirrored = false;
        }
    }
    func onCameraPreviewToRetake() {
        photoPreview.isHidden = true
        bottomBar.isHidden = false
        photoPreview.imageView.image = nil
        captureSession.startRunning()
    }

    func onCameraPreviewToEdit() {

    }

    func onCameraPreviewToSave() {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(outputPhotoComplete(image:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    @objc private func outputPhotoComplete(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        delegate.onCameraTakePhotoDidFinshed!(cameraVC: self, image: image)
        photoPreview.isHidden = true
        photoPreview.imageView.image = nil
    }
    func onCanclePhoto() {
        delegate.onCameraTakePhotoDidCancle!(cameraVC: self)
    }

    //CDCameraBottomBarDelegate
    func onTakePhoto() {

        if isVideo {
            if isVideoTakeIng{
                bottomBar.cameraSwitch.isHidden = false
                bottomBar.cancle.isHidden = false;
                _timeCount = 0;
                topBar.timeLabel?.text = "00:00:00"
                captureOutput.stopRecording()
            }else{
                bottomBar.cameraSwitch.isHidden = true
                bottomBar.cancle.isHidden = true
                perform(#selector(onStarToRecordIngVideo), with: nil, afterDelay: 1.0)
            }

        }else{
            let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
            imageOutput.capturePhoto(with: setting, delegate: self)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if error != nil{
            print("拍照失败：\(error.debugDescription)")
        }else{

            
            let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)

            self.photoPreview.isHidden = false
            self.bottomBar.isHidden = true
            self.image = UIImage(data: data!)!
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func onFigPhoto() {

    }
    func onCameraTurnAround() {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = 0.5
        animation.type = CATransitionType(rawValue: "oglFlip")
        if device.position == .back {
            device = createDevice(position: .front)
            animation.subtype = .fromLeft
            
        }else{
            device = createDevice(position: .back)
            animation.subtype = .fromRight
            
        }
        previewLayer.add(animation, forKey: nil)

        captureSession.beginConfiguration()
        if isVideo {
            addVideoCapturePut()
        }else{
            addImageCapturePut()
        }
        captureSession.commitConfiguration()

    }

    @objc func onZoomViewAction(pitch:UIPinchGestureRecognizer) {
        if pitch.state == .began ||
            pitch.state == .changed{
            let tmpCurrentZoomFactor = currentZoomFactor * pitch.scale
            let zoom = getZoomFactor()
            if tmpCurrentZoomFactor < zoom.max
                && tmpCurrentZoomFactor > zoom.min{
                do{
                    try device.lockForConfiguration()
                }catch{

                }
                device.videoZoomFactor = tmpCurrentZoomFactor
                device.unlockForConfiguration()

            }else{
                print("缩放限制了")
            }

        }

    }
    func getZoomFactor() ->(min:CGFloat,max:CGFloat) {
        var minZoom:CGFloat = 1.0
        var maxZoom:CGFloat = device.activeFormat.videoMaxZoomFactor

        if #available(iOS 11.0, *) {
            minZoom = device.minAvailableVideoZoomFactor
            maxZoom = device.maxAvailableVideoZoomFactor
        }
        if maxZoom > 6.0 {
            maxZoom = 6.0
        }
        return (minZoom,maxZoom)
    }

    func trunFlashModel(isOn:Bool){
        do{
            try device.lockForConfiguration()
        }catch{

        }
        device.flashMode = isOn ? .on : .off
        captureSession.beginConfiguration()
        if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
            device.whiteBalanceMode = .autoWhiteBalance
        }
        device.unlockForConfiguration()
        captureSession.commitConfiguration()
    }
    @objc func onSetFocusPoint(tap:UITapGestureRecognizer){
        let point =  tap.location(in: tap.view)
        focusAtPoint(point: point)
    }
    @objc func autoFocusModel() {
        if device.isFocusPointOfInterestSupported
        && device.isFocusModeSupported(.autoFocus){
            do{
                try device.lockForConfiguration()
            }catch{

            }
            device.focusMode = .autoFocus
            focusAtPoint(point: self.view.center)
            device.unlockForConfiguration()
        }

    }

    func focusAtPoint(point:CGPoint){

        let viewSize = self.view.frame.size
        let focusPoint = CGPoint(x: point.y / viewSize.height, y: point.y / viewSize.width)
        do{
            try device.lockForConfiguration()
        }catch{

        }
        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = focusPoint
        }
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus

        }
        device.unlockForConfiguration()
        focusCursor.center = point
        focusCursor.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.focusCursor.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (finished) in
            self.focusCursor.isHidden = true
        }
    }

    @objc func onStarToRecordIngVideo(){
        let time = getCurrentTimestamp()
        let videoPath = String.VideoPath().appendingPathComponent(str: "\(time).mp4")
        let url = URL(fileURLWithPath: videoPath)

        let conn = captureOutput.connection(with: .video)
        if conn?.isActive ?? false{

        }

        captureOutput.startRecording(to: url, recordingDelegate: self)
    }

    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("录制开始");
        isVideoTakeIng = true
        openTimer()

    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("录制结束");
        isVideoTakeIng = false
        closeTimer()
        delegate.onCameraTakePhotoDidFinshed!(cameraVC: self, videoUrl: outputFileURL)


    }


    //UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        currentZoomFactor = device.videoZoomFactor
        return true
    }

    //TODO:Time
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
        }
    }
    @objc func observedRecordTime(){
        print("定时")
        _timeCount += 1
        let hours = _timeCount / 3600
        let minutes = (_timeCount - hours * 3600) / 60
        let seconds = _timeCount - hours * 3600 - minutes * 60
        topBar.timeLabel?.text = String(format: "%02d:%02d:%02d", hours,minutes,seconds)

    }
}
