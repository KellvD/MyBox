//
//  CDCameraPreview.swift
//  CDCamera
//
//  Created by changdong on 2019/5/24.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit
protocol CDCameraPreviewDelegate {
    func onCameraPreviewToRetake()
    func onCameraPreviewToEdit()
    func onCameraPreviewToSave()
}
class CDCameraPreview: UIView {

    var imageView:UIImageView!
    var delegate:CDCameraPreviewDelegate!

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.addSubview(imageView)


        let space:CGFloat = (frame.width - 80 * 3)/4
        let width:CGFloat = 80
        let Y = frame.height - width - 50


        let retake = UIButton(type: .custom)
        retake.frame = CGRect(x: space, y: Y, width: width, height: width)
        retake.layer.cornerRadius = width/2
        retake.backgroundColor = UIColor.init(red: 245/225.0, green: 222/255.0, blue: 179/255.0, alpha: 1)
        retake.setImage(UIImage(named: "retake@2x"), for: .normal)
        retake.setTitleColor(UIColor.white, for: .normal)
        retake.addTarget(self, action: #selector(onTakePhotoAgain), for: .touchUpInside)
        self.addSubview(retake)

        let edit = UIButton(type: .custom)
        edit.frame = CGRect(x: space * 2 + width , y: Y, width: width, height: width)
        edit.layer.cornerRadius = width/2
        edit.backgroundColor = UIColor.init(red: 245/225.0, green: 222/255.0, blue: 179/255.0, alpha: 1)
        edit.setImage(UIImage(named: "edit@2x"), for: .normal)
        edit.addTarget(self, action: #selector(oneEditPhotoClick), for: .touchUpInside)
        self.addSubview(edit)

        let save = UIButton(type: .custom)
        save.frame = CGRect(x: space * 3 + width * 2, y: Y, width: width, height: width)
        save.layer.cornerRadius = width/2
        save.backgroundColor = UIColor.white
        save.setImage(UIImage(named: "save@2x"), for: .normal)
        save.setTitleColor(UIColor.white, for: .normal)
        save.addTarget(self, action: #selector(onUserPhotoClick), for: .touchUpInside)
        self.addSubview(save)



    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc func onTakePhotoAgain(){
        delegate.onCameraPreviewToRetake()
    }
    @objc func oneEditPhotoClick(){
        delegate.onCameraPreviewToEdit()
    }

    @objc func onUserPhotoClick(){
        delegate.onCameraPreviewToSave()
    }
}
