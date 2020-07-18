//
//  PECropView.swift
//  PhotoEdit
//
//  Created by changdong on 2019/5/15.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
let MarginTop:CGFloat = 37.0
let MarginBottom:CGFloat = MarginTop
let MarginLeft:CGFloat = 27.0
let MarginRight:CGFloat = MarginLeft

class PECropView: UIView,UIScrollViewDelegate,UIGestureRecognizerDelegate {
//    func cropRectViewDidBeginEditing(cropRectView: PECropRectView) {
//        <#code#>
//    }
//
//    func cropRectViewEditingChanged(cropRectView: PECropRectView) {
//        <#code#>
//    }
//
//    func cropRectViewDidEndEditing(cropRectView: PECropRectView) {
//        <#code#>
//    }


    var image:UIImage!
    var croppedImage:UIImage!
    var zoomedRect:CGRect!
    var rotation:CGAffineTransform!
    var userHasModified:Bool!
    var keepingCropAspectRatio:Bool!
    var cropAspectRatio: Bool!
    var cropRect: CGRect!
    var imageCropRect:CGRect!
    var rotationAngle:CGRect!
    var scrollView:UIScrollView!
    var zoomingView:UIView!
    var imageView: UIImageView!

    var cropRectView:PECropRectView!
    var topOverlayView:UIView!
    var leftOverlayView:UIView!
    var rightOverlayView:UIView!
    var bottomOverlayView:UIView!

    var insetRect:CGRect!
    var editingRect:CGRect!



    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }



    func commonInit() {
        self.autoresizingMask = .flexibleHeight
        self.backgroundColor = UIColor.clear
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.delegate = self
        self.scrollView.autoresizingMask = .flexibleLeftMargin
        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.maximumZoomScale = 20.0
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.bounces = false
        self.scrollView.bouncesZoom = false
        self.scrollView.clipsToBounds = false
        self.addSubview(self.scrollView)

//        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
//        rotation.delegate = self
//        self.scrollView.addGestureRecognizer(rotation)

        cropRectView = PECropRectView()
//        cropRectView.delegate = self
        self.addSubview(cropRectView)

        topOverlayView = UIView()
        topOverlayView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.4)
        self.addSubview(topOverlayView)

        leftOverlayView = UIView()
        leftOverlayView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.4)
        self.addSubview(leftOverlayView)

        rightOverlayView = UIView()
        rightOverlayView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.4)
        self.addSubview(rightOverlayView)

        bottomOverlayView = UIView()
        bottomOverlayView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.4)
        self.addSubview(bottomOverlayView)
    }


    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !self.isUserInteractionEnabled {
            return nil
        }
        let hitView = cropRectView.hitTest(self.convert(point, to: cropRectView), with: event)
        if hitView != nil {
            return hitView
        }
        let locationInImageView = self.convert(point, to: zoomingView)
        let zoomPoint = CGPoint(x: locationInImageView.x * scrollView.zoomScale, y:  locationInImageView.y * scrollView.zoomScale)
        if scrollView.frame.contains(zoomPoint) {
            return scrollView
        }
        return self.hitTest(point, with: event)

    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if (image == nil) {
//            return
//        }
//
//        let interfaceOrientation = UIApplication.shared.statusBarOrientation
//        if interfaceOrientation.isPortrait {
//            editingRect = bounds.insetBy(dx: CGFloat(MarginLeft), dy: CGFloat(MarginTop))
//        } else {
//            editingRect = bounds.insetBy(dx: CGFloat(MarginLeft), dy: CGFloat(MarginLeft))
//        }
//
//        if imageView == nil {
//            if interfaceOrientation.isPortrait {
//                insetRect = bounds.insetBy(dx: CGFloat(MarginLeft), dy: CGFloat(MarginTop))
//            } else {
//                insetRect = bounds.insetBy(dx: CGFloat(MarginLeft), dy: CGFloat(MarginLeft))
//            }
//
//            setupImageView()
//        }
//        if !isResizing {
//            la
//        }
//    }
//
//
//
//
//    func setupImageView() {
//        let cropRect = AVMakeRect(aspectRatio: image.size, insideRect: insetRect)
//
//        scrollView.frame = cropRect
//        scrollView.contentSize = cropRect.size
//
//        zoomingView = UIView(frame: scrollView.bounds)
//        zoomingView.backgroundColor = UIColor.clear
//        scrollView.addSubview(zoomingView)
//
//        imageView = UIImageView(frame: zoomingView.bounds)
//        imageView?.backgroundColor = UIColor.clear
//        imageView?.contentMode = .scaleAspectFit
//        imageView?.image = image
//        if let imageView = imageView {
//            zoomingView.addSubview(imageView)
//        }
//    }
//    func setImage(_ image: UIImage?) {
//        self.image = image
//
//        imageView?.removeFromSuperview()
//        imageView = nil
//
//        zoomingView.removeFromSuperview()
//        zoomingView = nil
//
//        setNeedsLayout()
//    }
//    func setKeepingCropAspectRatio(_ keepingCropAspectRatio: Bool) {
//        self.keepingCropAspectRatio = keepingCropAspectRatio
//        cropRectView.keepingAspectRatio = self.keepingCropAspectRatio
//    }
//
//    func setCropAspectRatio(_ aspectRatio: CGFloat, andCenter center: Bool) {
//        var cropRect = scrollView.frame
//        var width = cropRect.width
//        var height = cropRect.height
//        if aspectRatio <= 1.0 {
//            width = height * aspectRatio
//            if width > imageView.bounds.width {
//                width = cropRect.width
//                height = width / aspectRatio
//            }
//        } else {
//            height = width / aspectRatio
//            if height > imageView.bounds.height {
//                height = cropRect.height
//                width = height * aspectRatio
//            }
//        }
//        cropRect.size = CGSize(width: width, height: height)
//        zoom(toCropRect: cropRect, andCenter: true)
//    }
//
//    func setCropAspectRatio(_ aspectRatio: CGFloat) {
//        setCropAspectRatio(aspectRatio, andCenter: true)
//    }
//    func cropAspectRatio() -> CGFloat {
//        let cropRect = scrollView.frame
//        let width = cropRect.width
//        let height = cropRect.height
//        return width / height
//    }
//
//
//    func setImageCropRect(_ imageCropRect: CGRect) {
//        resetCropRect()
//
//        let scrollViewFrame = scrollView.frame
//        let imageSize = image.size
//
//        let scale = min(scrollViewFrame.width / imageSize.width, scrollViewFrame.height / imageSize.height)
//
//        let x = imageCropRect.minX * scale + scrollViewFrame.minX
//        let y = imageCropRect.minY * scale + scrollViewFrame.minY
//        let width = imageCropRect.width * scale
//        let height = imageCropRect.height * scale
//
//        let rect = CGRect(x: x, y: y, width: width, height: height)
//        let intersection = rect.intersection(scrollViewFrame)
//
//        if !intersection.isNull {
//            cropRect = intersection
//        }
//    }
//
//    func resetCropRect() {
//        resetCropRect(animated: false)
//    }
//
//    func resetCropRect(animated: Bool) {
//        if animated {
//            UIView.beginAnimations(nil, context: nil)
//            UIView.setAnimationDuration(0.25)
//            UIView.setAnimationBeginsFromCurrentState(true)
//        }
//
//        imageView?.transform = .identity
//
//        let contentSize = scrollView.contentSize
//        let initialRect = CGRect(x: 0.0, y: 0.0, width: contentSize.width, height: contentSize.height)
//        scrollView.zoom(to: initialRect, animated: false)
//
//        scrollView.bounds = imageView?.bounds ?? CGRect.zero
//
//        layoutCropRectView(withCropRect: scrollView.bounds)
//
//        if animated {
//            UIView.commitAnimations()
//        }
//    }
//    func croppedImage() -> UIImage? {
//        return image.rotatedImageWithtransform(rotation, croppedToRect: zoomedCropRect)
//    }
//    func zoomedCropRect() -> CGRect {
//        let cropRect = convert(scrollView.frame, to: zoomingView)
//        let size = image.size
//
//        var ratio: CGFloat = 1.0
//        let orientation = UIApplication.shared.statusBarOrientation
//        if UI_USER_INTERFACE_IDIOM() == .pad || orientation.isPortrait {
//            ratio = AVMakeRectWithAspectRatioInsideRect(image.size, insetRect).width / size.width
//        } else {
//            ratio = AVMakeRectWithAspectRatioInsideRect(image.size, insetRect).height / size.height
//        }
//
//        let zoomedCropRect = CGRect(x: cropRect.origin.x / ratio, y: cropRect.origin.y / ratio, width: cropRect.size.width / ratio, height: cropRect.size.height / ratio)
//
//        return zoomedCropRect
//    }
//    func userHasModifiedCropArea() -> Bool {
//        let zoomedCropRect = zoomedCropRect().intersection()
//        return !zoomedCropRect.origin.equalTo(CGPoint.zero) || !zoomedCropRect.size.equalTo(image.size) || !(rotation() == .identity)
//    }
//
//
//    func setRotationAngle(rotationAngle: CGFloat, snap: Bool) {
//        var rotationAngle = rotationAngle
//        if snap {
//            rotationAngle = CGFloat(nearbyintf(Float(rotationAngle) / Float(M_PI_2)) * Float(M_PI_2))
//        }
//        self.rotationAngle = rotationAngle
//    }
//
//
//    func zoom(toCropRect toRect: CGRect, andCenter center: Bool) {
//        if scrollView.frame.equalTo(toRect) {
//            return
//        }
//
//        let width = toRect.width
//        let height = toRect.height
//
//        let scale = min(editingRect.width / width, editingRect.height / height)
//
//        let scaledWidth = width * scale
//        let scaledHeight = height * scale
//        let cropRect = CGRect(x: (bounds.width - scaledWidth) / 2, y: (bounds.height - scaledHeight) / 2, width: scaledWidth, height: scaledHeight)
//
//        var zoomRect = convert(toRect, to: zoomingView)
//        zoomRect.size.width = cropRect.width / (scrollView.zoomScale * scale)
//        zoomRect.size.height = cropRect.height / (scrollView.zoomScale * scale)
//
//        if center{
//            let imageViewBounds = imageView.bounds
//            zoomRect.origin.y = imageViewBounds.height / 2 - zoomRect.height / 2
//            zoomRect.origin.x = imageViewBounds.width / 2 - zoomRect.width / 2
//        }
//        UIView.animate(withDuration: 0.25, animations: {
//            self.scrollView.bounds = cropRect
//            self.scrollView.zoom(to: zoomRect, animated: false)
//        }) { (flag) in
//
//        }
//
//
//    }
//    func layoutCropRectView(rect:CGRect){
//        self.cropRectView.frame = rect
//        layoutOverlayViews(rect: rect)
//    }
//
//    func layoutOverlayViews(rect:CGRect){
//
//        topOverlayView.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: rect.minY)
//        leftOverlayView.frame = CGRect(x: 0.0, y: rect.minY, width: rect.minX, height: rect.height)
//        rightOverlayView.frame = CGRect(x: cropRect.maxX, y: rect.minY, width: self.bounds.width - cropRect.maxX, height: rect.height)
//        bottomOverlayView.frame = CGRect(x: 0.0, y: rect.maxY, width: self.bounds.width, height: self.bounds.height - rect.maxY)
//    }
//    @objc func handleRotation(){
//
//    }
//
//
//
//
//    func resetCropRect() {
//
//    }


}
