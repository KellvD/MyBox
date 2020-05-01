//
//  CDWaterMarkViewController.swift
//  PhotoEdit
//
//  Created by changdong on 2019/5/13.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit

class CDWaterMarkViewController: UIViewController {

    var block:ImageBlock!
    var imageView:UIImageView!
    var markView:UIImageView!
    var isDragingMarkView:Bool!
    var warkMarkView:CDWaterMarkView!
    var image:UIImage!


    override func viewDidLoad() {
        super.viewDidLoad()

        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        self.view.addSubview(imageView)

        markView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        markView.center = CGPoint(x: imageView.frame.width/2, y: imageView.frame.height/2)
        markView.layer.cornerRadius = 5.0
        markView.layer.masksToBounds = true
        markView.isHidden = true
        markView.addSubview(markView)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(markPanMethod))
        imageView.addGestureRecognizer(pan)

        warkMarkView = CDWaterMarkView(frame: CGRect(x:0 , y:self.view.frame.height - waterViewHeight - 40 , width: self.view.frame.width, height: waterViewHeight))

    }

    @objc func markPanMethod(pan:UIPanGestureRecognizer){

    }

}
