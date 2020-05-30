//
//  CDCapturePreviewLayer.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/5/26.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

class CDCapturePreview: UIView,UIGestureRecognizerDelegate {
    var focusCursor:UIImageView!//聚焦光标
    var currentZoomFactor:CGFloat = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        focusCursor = UIImageView(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2), size: CGSize(width: 100, height: 100)))
        focusCursor.image = LoadImageByName(imageName: "frame", type: "png")
        focusCursor.isHidden = true
        self.addSubview(focusCursor)
        
        //放大缩小手势
        let pitch = UIPinchGestureRecognizer()
        pitch.delegate = self
        pitch.addTarget(self, action: #selector(onZoomViewAction(pitch:)))
        self.addGestureRecognizer(pitch);

        //对焦手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSetFocusPoint(tap:)))
        self.addGestureRecognizer(tap)
    }
    
    
    
    @objc func onZoomViewAction(pitch:UIPinchGestureRecognizer) {
        if pitch.state == .began ||
            pitch.state == .changed{
            let tmpCurrentZoomFactor = currentZoomFactor * pitch.scale
            let zoom = getZoomFactor()
            if tmpCurrentZoomFactor < zoom.max
                && tmpCurrentZoomFactor > zoom.min{
//                do{
//                    try device.lockForConfiguration()
//                }catch{
//
//                }
//                device.videoZoomFactor = tmpCurrentZoomFactor
//                device.unlockForConfiguration()

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
    
    @objc func onSetFocusPoint(tap:UITapGestureRecognizer){
        let point =  tap.location(in: tap.view)
        focusAtPoint(point: point)
    }
}
