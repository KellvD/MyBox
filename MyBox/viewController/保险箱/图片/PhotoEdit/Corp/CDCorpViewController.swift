//
//  CDCorpViewController.swift
//  PhotoEdit
//
//  Created by changdong on 2019/5/13.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit
class CDCorpViewController: UIViewController,CDCorpToolsViewDelegate {

    var originalImage:UIImage!

    var imageBlock:ImageBlock!
    var ratioView:CDPhotoChooseView!
    var cropView:PECropView!



    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "剪裁"

        let toolBar = CDCropToolsBar(frame: CGRect(x: 0, y: self.view.frame.height - 140, width: self.view.frame.width, height: 140))
        toolBar.delegate = self
        self.view.addSubview(toolBar)

//        let imageHeight = originalImage.size.height
//        let scale =  self.view.frame.width / self.view.frame.height
//        let height = CGFloat(imageHeight) * scale
//        let originalImageView = UIImageView(frame: CGRect(x: 0, y: (self.view.frame.height - 140 - 64 - height)/2, width: self.view.frame.width, height: height))
//        originalImageView.image = originalImage
//        self.view.addSubview(originalImageView)

//        cropView = PECropView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 140))
//        cropView.image = originalImageView
//        cropView.backgroundColor = UIColor.black
//        self.view.addSubview(cropView)
    }


    func handleFinish(Handel:@escaping(UIImage) ->Void) {

    }


    //MARK:CDCorpToosBarDelegate
    func onSelectCorpToolBar(barItem: CorpBarItem) {
        if barItem == .cancle {
            self.dismiss(animated: true, completion: nil)
        }else if barItem == .restore{

        }else{

        }
    }

    func onSelectCorpView(barItem: CorpBarView) {

    }

}
