//
//  CDCameraViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/24.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import CDMediaEditor

protocol CDCameraViewControllerDelegate:NSObjectProtocol  {
    func onCameraTakePhotoDidFinshed(cameraVC:CDCameraViewController,obj:[String:Any?])
    func onCameraTakeVideoDidFinshed(cameraVC:CDCameraViewController,obj:[String:Any?])
}
extension CDCameraViewControllerDelegate{
    func onCameraTakePhotoDidFinshed(cameraVC:CDCameraViewController,obj:[String:Any?]){}
    func onCameraTakeVideoDidFinshed(cameraVC:CDCameraViewController,obj:[String:Any?]){}
}


class CDCameraViewController: UIViewController,CDCameraBottomBarDelegate,CDCameraTopBarDelete{
    

    var delegate:CDCameraViewControllerDelegate!
    var bottomBar:CDCameraBottomBar!
    var topBar:CDCameraTopBar!
    var isVideo:Bool!
    var cameraManger:CDCameraManger!
    var delayLabel:UILabel!
    var QRBorderView:UIImageView! //扫描二维码识别边框
    var qrPopView:CDQrPopView!  //扫描二维码弹出内容框
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    open override var prefersStatusBarHidden: Bool{
        return true
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        cameraManger = CDCameraManger(baseView: self.view,isVideo:isVideo)
        cameraManger.delegate = self
        
        topBar = CDCameraTopBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44 + topSafeHeight), isVideo: isVideo)
        topBar.delegate = self
        self.view.addSubview(topBar)
        cameraManger.topBar = topBar
        
        bottomBar = CDCameraBottomBar(frame: CGRect(x: 0, y: self.view.frame.height - 140, width: self.view.frame.width, height: 140))
        bottomBar.delegate = self
        self.view.addSubview(bottomBar)
        
        delayLabel = UILabel(frame: CGRect(x: self.view.frame.midX - 100, y: self.view.frame.midY - 100, width: 200, height: 200))
        delayLabel.textColor = .white
        delayLabel.textAlignment = .center
        delayLabel.font = UIFont.boldSystemFont(ofSize: 180)
        self.view.addSubview(delayLabel)
        delayLabel.isHidden = true
        
        let focusCursor = UIImageView(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2), size: CGSize(width: 100, height: 100)))
        focusCursor.image = LoadImage("frame")
        focusCursor.isHidden = true
        self.view.addSubview(focusCursor)
        cameraManger.focusCursor = focusCursor
        
        QRBorderView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        QRBorderView.layer.borderWidth = 1
        QRBorderView.layer.borderColor = UIColor.yellow.cgColor
        QRBorderView.backgroundColor = .clear
        self.view.addSubview(QRBorderView)
        cameraManger.qrView = QRBorderView
        
        qrPopView = CDQrPopView(frame: CGRect(x: 15.0, y: -135.0, width: self.view.frame.width - 30.0, height: 100))
        self.view.addSubview(qrPopView)
        self.view.bringSubviewToFront(qrPopView)
        

    }
}

extension CDCameraViewController:CDCameraMangerDelegate{
    func cameraTakePhotoDidComplete(image: UIImage?) {
        if image != nil {
            let previewVC = CDPreviewTakerViewController()
            previewVC.cameraVC = self
            previewVC.isVideo = false
            previewVC.previewHandle = {(data) in
                if data != nil {
                    let prewImage = data as! UIImage
                    let dic:[String:Any?] = ["fileName":"\(GetTimestamp(nil)).png",
                                             "file":prewImage,
                                            "imageType":"normal",
                                            "createTime":GetTimestamp(nil),
                                            "location":nil]
                    self.delegate.onCameraTakePhotoDidFinshed(cameraVC: self, obj: dic)
                    self.dismiss(animated: false, completion: nil)
                } else {
                    self.cameraManger.reloadLayer()
                }
            }
            
            previewVC.origialImage = image
            previewVC.modalPresentationStyle = .fullScreen
            self.present(previewVC, animated: false, completion: nil)
        }
    }
    
    func cameraTakeVideoDidComplete(videoUrl: URL?) {
        let previewVC = CDPreviewTakerViewController()
        previewVC.isVideo = true
        previewVC.videoUrl = videoUrl
        previewVC.cameraVC = self
        previewVC.previewHandle = {(data)in
            if data != nil {
                let prewUrl = data as! URL
                let dic:[String:Any] = ["fileURL":prewUrl,
                                        "createTime": GetTimestamp(nil)]
                self.delegate.onCameraTakeVideoDidFinshed(cameraVC: self, obj: dic)
                self.dismiss(animated: false, completion: nil)
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
    
    func cameraScanQRDidComplete(content: String?, recoverHandle: @escaping () -> Void) {
        let qrUrl = URL(string: content!)
        let type:CDQrPopView.CDQRType = qrUrl != nil && UIApplication.shared.canOpenURL(qrUrl!) ? .Url : .Text

        let qrContent = type == .Url ? qrUrl!.host! : content!
        
        
        self.qrPopView.loadData(type: type, qrContent: qrContent)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.qrPopView.minX = 15.0
            }
        }
        
        
        self.qrPopView.onTapQrCodeHandle = {[weak self](isEnable) in
            recoverHandle()
            UIView.animate(withDuration: 0.25) {
                self!.qrPopView.minY = -115.0
            }
            if isEnable {
                if type == .Url {
                    UIApplication.shared.open(qrUrl!, options: [:], completionHandler: nil)
                }else{
                    let uslStr = "https://www.baidu.com/s?ie=UTF-8&wd=\(content!)"
                    UIApplication.shared.open(URL(string: uslStr)!, options: [:], completionHandler: nil)
                }
            }
            
        }
    }
    
    func cameraUpdateDelayDidComplete(delay: Int, isEnd: Bool) {
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
            self.delayLabel.layer.add(popAnimation, forKey: nil)
        } else {
            self.delayLabel.isHidden = true
        }
    }
    
    
    
}

extension CDCameraViewController{
    //CDCameraBottomBarDelegate
    func onCanclePhoto() {
        cameraManger.cancleCamera()
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

