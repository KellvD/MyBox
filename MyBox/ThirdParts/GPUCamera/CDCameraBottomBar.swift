//
//  CDCameraBottomVar.swift
//  MyRule
//
//  Created by changdong on 2019/5/24.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

protocol CDCameraBottomBarDelegate:NSObjectProtocol  {
    func onTakePhoto()
    func onCameraTurnAround()
    func onCanclePhoto()
    func onFigPhoto()
}
class CDCameraBottomBar: UIView {

    var delegate:CDCameraBottomBarDelegate!

    var takeButton:UIButton!
    var cameraSwitch:UIButton!
    var cancle:UIButton! //取消
    var figBtn:UIButton! //美颜
    var bgView:UIView!


    override init(frame: CGRect) {
        super.init(frame: frame)
        let blur = UIBlurEffect(style: .light)
        bgView = UIVisualEffectView(effect: blur)
        bgView.alpha = 0.5
        bgView.frame = self.bounds
        self.addSubview(bgView)

        takeButton = UIButton(type: .custom)
        takeButton.frame = CGRect(x: (frame.width - 80)/2, y: frame.height - 80 - 15, width: 80, height: 80)
        takeButton.layer.cornerRadius = 80/2
        takeButton.setImage(UIImage(named: "takePhoto"), for: .normal)
        takeButton.addTarget(self, action: #selector(onTakePhotoClick), for: .touchUpInside)
        self.addSubview(takeButton)


//        let width = (frame.height-30)/2
//        figBtn = UIButton(type: .custom)
//        figBtn.frame = CGRect(x: frame.width - 48 - 15, y: 10, width: width, height: width)
//        figBtn.layer.cornerRadius = width/2
//        figBtn.setImage(UIImage(named: "meiyan"), for: .normal)
//        figBtn.addTarget(self, action: #selector(onCameraFigClick), for: .touchUpInside)
//        self.addSubview(figBtn)

        cameraSwitch = UIButton(type: .custom)
        cameraSwitch.frame = CGRect(x: frame.width - 48 - 15, y: frame.height - 48 - 15, width: 48, height: 48)
        cameraSwitch.setImage(UIImage(named: "cameraSwitch"), for: .normal)
        cameraSwitch.addTarget(self, action: #selector(onCameraSwitchClick), for: .touchUpInside)
        self.addSubview(cameraSwitch)

        cancle = UIButton(type: .custom)
        cancle.frame = CGRect(x: 15, y: frame.height - 48 - 15, width: 48, height: 48)

        cancle.setTitle(LocalizedString("cancel"), for: .normal)
        cancle.addTarget(self, action: #selector(onCameraCancleClick), for: .touchUpInside)
        self.addSubview(cancle)

    }



    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func onTakePhotoClick(){


        delegate.onTakePhoto()
    }

    @objc func onCameraSwitchClick(){
        delegate.onCameraTurnAround()
    }

    @objc func onCameraCancleClick(){
        delegate.onCanclePhoto()
    }

    @objc func onCameraFigClick(){
        delegate.onFigPhoto();
    }
}
