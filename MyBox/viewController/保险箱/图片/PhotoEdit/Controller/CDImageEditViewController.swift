//
//  CDPhotoEditViewController.swift
//  PhotoEdit
//
//  Created by changdong on 2019/5/13.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit
class CDImageEditViewController:
    UIViewController,
    CDNavigationBarDelegate,
    CDEditorsViewDelegate {

    public var imageInfo:CDSafeFileInfo!
    public var scroller:CDPhotoView!
    private var toolBar:CDEditToolView!
    private var headerBar:CDNavigationBar!
    private var editImage:UIImage!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black
        CDEditManager.shareInstance().editStep = NSEditStep.NOTEdit
        headerBar = CDNavigationBar(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 44 + StatusHeight))
        headerBar.delegate = self
        self.view.addSubview(headerBar)

        scroller = CDPhotoView(frame: CGRect(x: 0, y: headerBar.frame.maxY + 15, width: CDSCREEN_WIDTH, height: CDViewHeight - headerBar.frame.maxY + 15 - 100))
        self.view.addSubview(scroller)
        CDEditManager.shareInstance().editVC = self
        CDEditManager.shareInstance().lastTranform = scroller.layer.transform

    
        DispatchQueue.global().async {
            let defaultPath = String.RootPath().appendingPathComponent(str: self.imageInfo.filePath)
                self.editImage = UIImage(contentsOfFile: defaultPath)!
            let imageSize = self.editImage.size
            var isWidthLonger = true
            if Int(imageSize.width) > Int(imageSize.height){
                isWidthLonger = false
            }
            var newSize = CGSize()
            if isWidthLonger{
                let tempWidth = CGFloat(5500)

                if Int(imageSize.width) > Int(tempWidth) {
                    newSize = CGSize(width: tempWidth, height: tempWidth * imageSize.height / imageSize.width)
                } else {
                    newSize = imageSize
                }
            }else{
                let tempHeight = CGFloat(5500)
                if imageSize.height > tempHeight {
                    newSize = CGSize(width: tempHeight * imageSize.width / imageSize.height, height: tempHeight)
                } else {
                    newSize = imageSize
                }
            }
            var new = UIImage()
            UIGraphicsBeginImageContext(newSize)
            let context = UIGraphicsGetCurrentContext()
            if context != nil {
                self.editImage.draw(in: CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height))
                new = UIGraphicsGetImageFromCurrentImageContext()!
            }
            UIGraphicsEndImageContext()
            DispatchQueue.main.async(execute: {
                self.scroller.loadImageView(image: new)
            })
        }

        toolBar = CDEditToolView(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - 48 * 2, width: CDSCREEN_WIDTH, height: 48 * 2))
        toolBar.itemsView.mDelegate = self
        self.view.addSubview(toolBar)

        
        NotificationCenter.default.addObserver(self, selector: #selector(setToolsStatus), name: NSNotification.Name("didSelectedEdtors"), object: nil)


    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didSelectedEdtors"), object: nil)

    }
    @objc func setToolsStatus(){
        headerBar.setNavigationsStatus()
        toolBar.setToolsStatus()
        if CDEditManager.shareInstance().editType == CDEditorsType.Rotate{
            scroller.isUserInteractionEnabled = false
        }
    }
    func onCDNavigationBarItemDidSelected(type: NSNavigationBarType) {
        switch type {
        case .back:
            if CDEditManager.shareInstance().editStep == .DidEdit{
                let alert = UIAlertController(title: nil, message: "当前图片已编辑，确认取消编辑么？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: LocalizedString("cancel"), style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: LocalizedString("sure"), style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        case .backward:
            CDEditManager.shareInstance().dropEditHandle()
        case .save:
            if CDEditManager.shareInstance().editStep == .NOTEdit{

            }
        case .done:

            CDEditManager.shareInstance().doneEditHandle()
            CDEditManager.shareInstance().editStep = .NOTEdit
            toolBar.setToolsStatus()
            headerBar.setNavigationsStatus()

        case .cancle:
            CDEditManager.shareInstance().cancleEditHandle()
            CDEditManager.shareInstance().editStep = .NOTEdit
            toolBar.setToolsStatus()
            headerBar.setNavigationsStatus()
        }
    }

    func onSelectEditorWith(model: CDEditorsModel) {
        UIApplication.shared.isStatusBarHidden = true
        switch model.type {
        case .Text:
            headerBar.isHidden = true;
            textView.onPopTextMarkView()
            
            
        default:
            break
        }
    }
    
    lazy var textView: CDWatermarkView = {
        let textV = CDWatermarkView(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        textV.completeHandler = {(content) in
            
        }
        textV.cancleHandler = {[weak self] in
            
            
            self!.headerBar.isHidden = false
        }
        UIApplication.shared.keyWindow?.addSubview(textV)
        return textV
    }()
}
