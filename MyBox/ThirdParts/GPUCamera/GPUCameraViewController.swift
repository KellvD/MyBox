//
//  GPUCameraViewController.swift
//  MyBox
//
//  Created by changdong  on 2020/6/10.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit
@objc protocol GPUCameraViewControllerDelegate {
    @objc optional func onCameraTakePhotoDidFinshed(cameraVC:GPUCameraViewController,obj:Dictionary<String,Any>)
}
class GPUCameraViewController: UIViewController,CDCameraBottomBarDelegate,CDCameraTopBarDelete {
  
    weak var delegate:GPUCameraViewControllerDelegate!
    var cameraManger:GPCameraManager!
    var isVideo:Bool!
    
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
        cameraManger = GPCameraManager(baseView:self.view,isVideo:isVideo)
       
        self.view.addSubview(topBar)
        cameraManger.topBar = topBar
        self.view.addSubview(bottomBar)
        
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
                cameraManger.stopRecordVideo()
            }else{
                bottomBar.cameraSwitch.isHidden = true
                bottomBar.cancle.isHidden = true
                cameraManger.startRecordVideo()
            }
        }else{
            cameraManger.readyTakePhoto()
        }
    }
    
    //切换摄像头
    func onCameraTurnAround() {
        cameraManger.cameraTurnAround()
    }
    func onFigPhoto() {
        
    }
    
    func turnFlashModel(model: Int) {
        
    }
    
    func turnHDRModel(model: Int) {
        
    }
    
    
    //MARK: Lazy
    lazy var delayLabel: UILabel = {
           let delayLabel = UILabel(frame: CGRect(x: self.view.frame.midX - 50, y: self.view.frame.midY - 80, width: 100, height: 160))
           delayLabel.textColor = .white
           delayLabel.textAlignment = .center
           delayLabel.font = UIFont.boldSystemFont(ofSize: 64)
           self.view.addSubview(delayLabel)
           delayLabel.isHidden = true
           return delayLabel
       }()

       lazy var bottomBar: CDCameraBottomBar = {
           let bottomBar = CDCameraBottomBar(frame: CGRect(x: 0, y: self.view.frame.height - 140, width: self.view.frame.width, height: 140))
           bottomBar.delegate = self
           return bottomBar
       }()
       
       lazy var topBar: CDCameraTopBar = {
           let topBar = CDCameraTopBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 48), isVideo: isVideo)
           topBar.delegate = self
           return topBar
       }()
}
