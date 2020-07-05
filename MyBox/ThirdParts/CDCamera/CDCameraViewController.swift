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

    @objc optional func onCameraTakePhotoDidFinshed(cameraVC:CDCameraViewController,obj:Dictionary<String,Any>)
}

@objc protocol CDScanQRDelegate {

    @objc optional func onScanQRDidFinshed(cameraVC:CDCameraViewController,obj:String)
}
class CDCameraViewController: UIViewController,CDCameraBottomBarDelegate,CDCameraTopBarDelete{
    

    var delegate:CDCameraViewControllerDelegate!
    var bottomBar:CDCameraBottomBar!
    var topBar:CDCameraTopBar!
    var isVideo:Bool!
    var cameraManger:CDCameraManger!
    var delayLabel:UILabel!
    var QRView:UIImageView!
    
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
        cameraManger = CDCameraManger(baseView: self.view,isVideo:isVideo)
        
        topBar = CDCameraTopBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 48), isVideo: isVideo)
        topBar.delegate = self
        self.view.addSubview(topBar)
        cameraManger.topBar = topBar
        
        bottomBar = CDCameraBottomBar(frame: CGRect(x: 0, y: self.view.frame.height - 140, width: self.view.frame.width, height: 140))
        bottomBar.delegate = self
        self.view.addSubview(bottomBar)

        delayLabel = UILabel(frame: CGRect(x: self.view.frame.midX - 50, y: self.view.frame.midY - 80, width: 100, height: 160))
        delayLabel.textColor = .white
        delayLabel.textAlignment = .center
        delayLabel.font = UIFont.boldSystemFont(ofSize: 64)
        self.view.addSubview(delayLabel)
        delayLabel.isHidden = true
        
        let focusCursor = UIImageView(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2), size: CGSize(width: 100, height: 100)))
        focusCursor.image = LoadImageByName(imageName: "frame", type: "png")
        focusCursor.isHidden = true
        self.view.addSubview(focusCursor)
        cameraManger.focusCursor = focusCursor
        
        QRView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        QRView.layer.borderWidth = 1
        QRView.layer.borderColor = UIColor.yellow.cgColor
        QRView.backgroundColor = .clear
        self.view.addSubview(QRView)
        cameraManger.qrView = QRView
        
        cameraManger.takePhotoComplete = {(image) in
            if image != nil {
                let previewVC = CDPreviewTakerViewController()
                previewVC.isVideo = false
                previewVC.previewHandle = {(success) in
                    if success {
                        let dic:[String:Any] = ["fileName":"\(getCurrentTimestamp()).png","file":image!]
                        self.delegate.onCameraTakePhotoDidFinshed?(cameraVC: self, obj: dic)
                    } else {
                        self.cameraManger.reloadLayer()
                    }
                }
                previewVC.origialImage = image
                previewVC.modalPresentationStyle = .fullScreen
                self.present(previewVC, animated: false, completion: nil)
            }
        }
        
        cameraManger.takeVideoComplete = {(videoUrl) in
            let previewVC = CDPreviewTakerViewController()
            previewVC.isVideo = true
            previewVC.videoUrl = videoUrl
            previewVC.previewHandle = {(scuess) in
                if scuess {
                    let dic:[String:Any] = ["fileURL":videoUrl!]
                    self.delegate.onCameraTakePhotoDidFinshed?(cameraVC: self, obj: dic)
                } else {
                    do {
                        try FileManager.default.removeItem(at: videoUrl!)
                    } catch  {
                        print(error.localizedDescription)
                    }
                }
            }
            previewVC.modalPresentationStyle = .fullScreen
            self.present(previewVC, animated: false, completion: nil)
        }
        
        cameraManger.scanRQComplete = {(qrUrl,recoverHandle) in
            let urlStr = qrUrl?.host
            let alert = UIAlertController(title: "扫描到二维码", message: "在「Safari浏览器」中打开\(urlStr!)", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                recoverHandle()
            }))
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                recoverHandle()
                if UIApplication.shared.canOpenURL(qrUrl!) {
                    UIApplication.shared.open(qrUrl!, options: [:], completionHandler: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        cameraManger.updateDelayComplete = {(delay,isEnd) in
            if !isEnd {
                self.delayLabel.isHidden = false
                self.delayLabel.text = "\(delay)"
                let popAnimation = CAKeyframeAnimation(keyPath: "transform")
                popAnimation.duration = 0.5;
                popAnimation.values = [NSValue(caTransform3D: CATransform3DMakeScale(0.01, 0.01, 1.0)),
                                       NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)),
                                       NSValue(caTransform3D: CATransform3DIdentity)]
                popAnimation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut),
                                                CAMediaTimingFunction(name: .easeInEaseOut),
                                                CAMediaTimingFunction(name: .easeInEaseOut)]
                self.delayLabel.frame = CGRect(x: self.view.frame.midX - 50, y: self.view.frame.midY - 80, width: 100, height: 160)
                self.delayLabel.layer.add(popAnimation, forKey: nil)
            } else {
                self.delayLabel.isHidden = true
            }
            
        }
    }


    //CDCameraBottomBarDelegate
    func onCanclePhoto() {
        CDSignalTon.shared.customPickerView = nil
        self.dismiss(animated: true, completion: nil)
    }

    func onTakePhoto() {

        if isVideo {
            if cameraManger.isVideoRecording{
                bottomBar.cameraSwitch.isHidden = false
                bottomBar.cancle.isHidden = false;
                cameraManger.stopTakeVideo()
            }else{
                bottomBar.cameraSwitch.isHidden = true
                bottomBar.cancle.isHidden = true
                cameraManger.startTakeVideo()
            }
        }else{
            cameraManger.readyTakePhoto()
        }
    }
    
    //切换摄像头
    func onCameraTurnAround() {
        cameraManger.cameraTurnAround()
    }
    
    //开闭闪光灯
    func turnFlashModel(model: Int) {
        cameraManger.trunFlash(model: AVCaptureDevice.FlashMode(rawValue: model)!)
    }
    
    func turnHDRModel(model: Int) {
    }
    
    func onFigPhoto() {
        
    }

    
}
