//
//  CDImageScrollView.swift
//  MyRule
//
//  Created by changdong on 2019/5/23.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

typealias CDTapRQHandle = (_ message:String) -> Void
class CDImageScrollView: UIScrollView,UIScrollViewDelegate {

    private var imageView:UIImageView!
    private var imageViewFrame:CGRect!
    var tapQRHandle:CDTapRQHandle!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.maximumZoomScale = 3.0
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        imageView = UIImageView(frame: self.bounds)
        imageView.isUserInteractionEnabled = true
        self.addSubview(imageView)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction))
        singleTap.numberOfTapsRequired = 1
        addGestureRecognizer(singleTap)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(tap:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTapAction(tap:)))
        imageView.addGestureRecognizer(longTap)
        longTap.minimumPressDuration = 1
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func longTapAction(tap:UILongPressGestureRecognizer){
        if tap.state == .began {
            let image = imageView.image
            let msg = CDGeneralTool.IdentifedQRFromPhoto(image: image!)
            print(msg)
            if msg.count > 0 {
                tapQRHandle(msg)
                
            }
        }
        
    }
    @objc func singleTapAction() {
        NotificationCenter.default.post(name: BarsHiddenOrNot, object: nil)
    }

    @objc func doubleTapAction(tap:UITapGestureRecognizer) {
        zoomtoLocation(location: tap.location(in: self))
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if isZoomed() == false && imageViewFrame?.equalTo(imageView.frame) == false {
            imageView.frame = imageViewFrame
        }
    }

    func zoomtoLocation(location: CGPoint) {
        var newScale: Float
        var zoomRect: CGRect
        if isZoomed() {
            zoomRect = self.bounds
        } else {
            newScale = Float(maximumZoomScale)
            zoomRect = zoomRectForScaleWithCenter(scale: newScale, center: location)
        }
        zoom(to: zoomRect, animated: true)
    }

    func isZoomed() -> Bool {
        return !(self.zoomScale == self.minimumZoomScale)
    }

    func zoomRectForScaleWithCenter(scale:Float,center:CGPoint) ->CGRect{

        var zoomRect = CGRect()
        zoomRect.size.height = self.frame.size.height / CGFloat(scale)
        zoomRect.size.width = self.frame.size.width / CGFloat(scale)
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    func loadImageView(image:UIImage,gifData:NSData) {
        let ratio_w: CGFloat = image.size.width / CDSCREEN_WIDTH
        let ratio_h: CGFloat = image.size.height / bounds.height
        if ratio_w > ratio_h {
            let height = image.size.height / ratio_w

            imageViewFrame = CGRect(x: 0, y: (frame.size.height - height)/2, width: CDSCREEN_WIDTH, height: height)
        } else {
            imageViewFrame = CGRect(x: 0, y: 0, width: image.size.width / ratio_h, height: bounds.height)
        }
        imageView?.frame = imageViewFrame
        imageViewFrame = imageView?.frame
        if gifData.length > 0 {
            let type:SDImageFormat = imageFormatForImageData(data:gifData)
            if type == .SDImageFormatGIF {
                imageView?.image = UIImage.gif(data: gifData as Data)
            } else {
                imageView?.image = image
            }
        } else {
            imageView?.image = image
        }

    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        let view = imageView
        return view

    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    func centerScrollViewContents() {
        let boundsSize: CGSize? = UIApplication.shared.keyWindow?.bounds.size
        var contentsFrame: CGRect = imageView.frame

        if contentsFrame.size.width < (boundsSize?.width ?? 0.0) {
            contentsFrame.origin.x = ((boundsSize?.width ?? 0.0) - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }

        if contentsFrame.size.height < (boundsSize?.height ?? 0.0) {
            contentsFrame.origin.y = ((boundsSize?.height ?? 0.0) - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        imageView.frame = contentsFrame
    }
}
