//
//  CDCameraViewController.swift
//  MyRule
//
//  Created by changdong on 2019/5/24.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol CDCameraViewControllerDelegate:NSObjectProtocol  {

    @objc optional func onCameraTakePhotoDidFinshed(cameraVC:CDCameraViewController,obj:Dictionary<String,Any>)
}

@objc protocol CDScanQRDelegate:NSObjectProtocol  {

    @objc optional func onScanQRDidFinshed(cameraVC:CDCameraViewController,obj:String)
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
        delayLabel = UILabel(frame: CGRect(x: self.view.frame.midX - 80, y: self.view.frame.midY - 100, width: 160, height: 200))
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
        
//        qrPopView = CDQrPopView(frame: CGRect(x: 15.0, y: -135.0, width: self.view.frame.width - 30.0, height: 100))
//        self.view.addSubview(qrPopView)
        
        cameraManger.takePhotoComplete = {(image) in
            if image != nil {
                let previewVC = CDPreviewTakerViewController()
                previewVC.isVideo = false
                previewVC.previewHandle = {(success) in
                    if success {
                        let dic:[String:Any] = ["fileName":"\(GetTimestamp()).png","file":image!]
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
        
        cameraManger.scanRQComplete = { [weak self](content,recoverHandle) in
            
            let qrUrl = URL(string: content!)
            let type:CDQrPopView.CDQRType = qrUrl != nil && UIApplication.shared.canOpenURL(qrUrl!) ? .Url : .Text

            let qrContent = type == .Url ? qrUrl!.host! : content!
            
            
            self!.qrPopView.loadData(type: type, qrContent: qrContent)
            UIView.animate(withDuration: 0.25) {
                var fra = self!.qrPopView.frame
                fra.origin.y = 15.0
                self!.qrPopView.frame = fra
            }
            
            self!.qrPopView.onTapQrCodeHandle = {[weak self](isEnable) in
                recoverHandle()
                UIView.animate(withDuration: 0.25) {
                    var fra = self!.qrPopView.frame
                    fra.origin.y = -115.0
                    self!.qrPopView.frame = fra
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
                self.delayLabel.layer.add(popAnimation, forKey: nil)
            } else {
                self.delayLabel.isHidden = true
            }
        }
    }


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


class CDQrPopView: UIView {
    enum CDQRType:Int {
        case Text
        case Url
    }
    private var typeLabel:UILabel!
    private var titleLabel:UILabel!
    private var contentLabel:UILabel!
    var onTapQrCodeHandle:((_ isEnable:Bool)->Void)!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 14.0
        self.backgroundColor = UIColor(204, 194, 189)
        let iconView = UIImageView(frame: CGRect(x: 15.0, y: 15.0, width: 30, height: 30))
        iconView.backgroundColor = .red
        iconView.isUserInteractionEnabled = true
        self.addSubview(iconView)
        
        let detailIconView = UIImageView(frame: CGRect(x: self.frame.width - 20 - 45.0, y: self.frame.height/2.0 - 45.0/2.0, width: 45.0, height: 45.0))
        detailIconView.backgroundColor = .blue
        detailIconView.isUserInteractionEnabled = true
        self.addSubview(detailIconView)
        
        
        typeLabel = UILabel(frame: CGRect(x: iconView.frame.maxX + 10.0, y: iconView.frame.minY, width: detailIconView.frame.minX - iconView.frame.maxX - 20.0, height: 30.0))
        typeLabel.textColor = .gray
        typeLabel.font = UIFont.boldSystemFont(ofSize: 13)
        addSubview(typeLabel)
        
        titleLabel = UILabel(frame: CGRect(x: iconView.frame.minX, y: typeLabel.frame.maxY, width: detailIconView.frame.minX - iconView.frame.maxX, height: 20.0))
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        addSubview(titleLabel)
        
        contentLabel = UILabel(frame: CGRect(x: titleLabel.frame.minX, y: titleLabel.frame.maxY, width: self.width - iconView.frame.maxX, height: titleLabel.frame.height))
        contentLabel.textColor = .black
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        addSubview(contentLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onHitQrCodeTap))
        addGestureRecognizer(tap)
        
        let hiddenTap = UISwipeGestureRecognizer(target: self, action: #selector(onHiddenQrCodeTap))
        hiddenTap.direction = .up
        addGestureRecognizer(hiddenTap)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func loadData(type:CDQRType,qrContent:String){
        if type == .Text {
            typeLabel.text = "文本二维码"
            titleLabel.text = "在Safari浏览器中搜索网页"
            contentLabel.text = "内容：“\(qrContent)”"
        }else{
            typeLabel.text = "网站二维码"
            titleLabel.text = "在Safari浏览器中打开网站"
            contentLabel.text = "链接：“\(qrContent)”"
        }
        
    }
    
    @objc func onHitQrCodeTap(){
        self.onTapQrCodeHandle(true)
    }
    
    @objc func onHiddenQrCodeTap(){
        self.onTapQrCodeHandle(false)
    }
}
