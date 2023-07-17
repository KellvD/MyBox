//
//  CDRippleView.swift
//  MyBox
//
//  Created by changdong on 2021/10/8.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDRippleView: UIView {

    private var shapeLayers: [CAShapeLayer] = []
    private var fillColor: UIColor! /// 波纹填充色
    private var timeInterval: TimeInterval = 0
    private var duration: TimeInterval = 0
    private var waveCount: Int! /// 波纹数量
    private var minRadius: CGFloat!
    private var animating: Bool = false
    init(frame: CGRect, fillColor: UIColor, minRadius: CGFloat, waveCount: Int, timeInterval: TimeInterval, duration: TimeInterval) {
        super.init(frame: frame)
        self.fillColor = fillColor
        self.timeInterval = timeInterval
        self.duration = duration
        self.waveCount = waveCount
        self.minRadius = minRadius
        self.shapeLayers = []
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        reloadShapeLayers()
    }
    public func startAnimating() {
        stopAnimating()
        animating = true
        for index in 0..<shapeLayers.count {
            let shapelayer = shapeLayers[index]
            let animation = newWaveAnimation()
            let dic = ["1": animation, "2": shapelayer]
            self.perform(#selector(appendAnimationParameters(dic:)), with: dic, afterDelay: Double(index) * timeInterval)
        }
    }

    public func stopAnimating() {
        animating = false
        for shapelayer in shapeLayers {
            shapelayer.removeAllAnimations()
        }
    }

    private func newShapeLayer() -> CAShapeLayer {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: minRadius * 2, height: minRadius * 2), cornerRadius: minRadius)

        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: center.x - minRadius, y: center.y - minRadius, width: minRadius * 2, height: minRadius * 2)
        shapeLayer.opacity = 0
        shapeLayer.lineWidth = 0.0
        shapeLayer.position = center
        shapeLayer.path = path.cgPath
        shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        shapeLayer.fillColor = fillColor?.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        return shapeLayer
    }

    private func newWaveAnimation() -> CAAnimation {
        let maxRadius = max(minRadius, min(self.bounds.width/2.0, self.bounds.height/2.0))
        let scale = maxRadius / minRadius

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scaleAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(scale, scale, 1))

        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = NSNumber(value: 1)
        alphaAnimation.toValue = NSNumber(value: 0)

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleAnimation, alphaAnimation]
        animationGroup.duration = duration
        animationGroup.repeatCount = Float(NSInteger.max)
        animationGroup.isRemovedOnCompletion = true
        return animationGroup
    }

    private func reloadShapeLayers() {
        for shapelayer in shapeLayers {
            shapelayer.removeAllAnimations()
            shapelayer.removeFromSuperlayer()
        }
        shapeLayers.removeAll()

        for _ in 0..<waveCount {
            let shapeLayer = newShapeLayer()
            self.layer.addSublayer(shapeLayer)
            shapeLayers.append(shapeLayer)
        }

        if animating {
            startAnimating()
        } else {
            stopAnimating()
        }

    }

    @objc private func appendAnimationParameters(dic: [String: Any]) {

        let layer = dic["2"] as! CAShapeLayer
        let animation = dic["1"] as! CAAnimation
        if animating {
            layer.add(animation, forKey: nil)
        }
    }
}

// class CDRippleView: UIView {
//
//    private var firstGreyCircle:UIImageView!
//    private var secondGreyCircle:UIImageView!
//    private var thirdGreyCircle:UIImageView!
//    private var centerGreyCircle:UIImageView!
//    private var greyCircleOriginalWidth:CGFloat!
//    private var greyCircleMaxWidth:CGFloat!
//    private var blueCircleWidth:CGFloat!
//    private var isStop:Bool = false
//    init(frame: CGRect,centerWidth:CGFloat) {
//        super.init(frame: frame)
//
//        greyCircleOriginalWidth = centerWidth + 30.0
//        greyCircleMaxWidth = frame.width - 10
//
//        firstGreyCircle = UIImageView(frame: CGRect(x: frame.width/2.0 - greyCircleOriginalWidth/2.0, y: frame.height/2.0 - greyCircleOriginalWidth/2.0, width: greyCircleOriginalWidth, height: greyCircleOriginalWidth))
//        firstGreyCircle.backgroundColor = .clear
//        firstGreyCircle.image = "grey_circle".image
//        firstGreyCircle.isHidden = true
//        self.addSubview(firstGreyCircle)
//
//        secondGreyCircle = UIImageView(frame: CGRect(x: frame.width/2.0 - greyCircleOriginalWidth/2.0, y: frame.height/2.0 - greyCircleOriginalWidth/2.0, width: greyCircleOriginalWidth, height: greyCircleOriginalWidth))
//        secondGreyCircle.backgroundColor = .clear
//        secondGreyCircle.image = "grey_circle".image
//        secondGreyCircle.isHidden = true
//        self.addSubview(secondGreyCircle)
//
//
//        thirdGreyCircle = UIImageView(frame: CGRect(x: frame.width/2.0 - greyCircleOriginalWidth/2.0, y: frame.height/2.0 - greyCircleOriginalWidth/2.0, width: greyCircleOriginalWidth, height: greyCircleOriginalWidth))
//        thirdGreyCircle.backgroundColor = .clear
//        thirdGreyCircle.image = "grey_circle".image
//        thirdGreyCircle.isHidden = true
//        self.addSubview(thirdGreyCircle)
//
////        centerGreyCircle = UIImageView(frame: CGRect(origin: frame.origin, size: CGSize(width: greyCircleOriginalWidth, height: greyCircleOriginalWidth)))
////        centerGreyCircle.image = "blue_circle_play".image
////        centerGreyCircle.isUserInteractionEnabled = true
////        center.add
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//
//    public func startAnimation(){
//
//        startFirstCircle()
//        self.perform(#selector(startSecondCircle), with: nil, afterDelay: 1.0)
//        self.perform(#selector(startThirdCircle), with: nil, afterDelay: 1.0)
//        isStop = false
//    }
//
//
//    public func stopAnimation(){
//
//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(startFirstCircle), object: nil)
//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(startSecondCircle), object: nil)
//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(startThirdCircle), object: nil)
//
//        firstGreyCircle.isHidden = true
//        secondGreyCircle.isHidden = true
//        thirdGreyCircle.isHidden = true
//
//        if firstGreyCircle != nil {
//            firstGreyCircle.layer.removeAllAnimations()
//        }
//        if secondGreyCircle != nil {
//            secondGreyCircle.layer.removeAllAnimations()
//        }
//        if thirdGreyCircle != nil {
//            thirdGreyCircle.layer.removeAllAnimations()
//        }
//        isStop = true
//    }
//
//    @objc private func startFirstCircle(){
//        firstGreyCircle.bounds = CGRect(x: 0, y: 0, width: greyCircleOriginalWidth, height: greyCircleOriginalWidth)
//        firstGreyCircle.center = CGPoint(x: self.bounds.width/2.0, y: self.bounds.height/2.0)
//        firstGreyCircle.alpha = 1.0
//        firstGreyCircle.isHidden = false
//        controlFirstCircleExpand()
//
//    }
//    @objc private func startSecondCircle(){
//        secondGreyCircle.bounds = CGRect(x: 0, y: 0, width: greyCircleOriginalWidth, height: greyCircleOriginalWidth)
//        secondGreyCircle.center = CGPoint(x: self.bounds.width/2.0, y: self.bounds.height/2.0)
//        secondGreyCircle.alpha = 1.0
//        secondGreyCircle.isHidden = false
//        controlSecondCircleExpand()
//    }
//    @objc private func startThirdCircle(){
//        thirdGreyCircle.bounds = CGRect(x: 0, y: 0, width: greyCircleOriginalWidth, height: greyCircleOriginalWidth)
//        thirdGreyCircle.center = CGPoint(x: self.bounds.width/2.0, y: self.bounds.height/2.0)
//        thirdGreyCircle.alpha = 1.0
//        thirdGreyCircle.isHidden = false
//        controlThirdCircleExpand()
//    }
//
//    private func controlFirstCircleExpand(){
//        UIView.animate(withDuration: 4.0) {
//            self.firstGreyCircle.bounds = CGRect(x: 0, y: 0, width: self.greyCircleMaxWidth, height: self.greyCircleMaxWidth)
//            self.firstGreyCircle.center = CGPoint(x: self.bounds.width/2.0, y: self.bounds.height/2.0)
//            self.firstGreyCircle.alpha = 0.0
//        } completion: { [self] finished in
//            self.firstGreyCircle.isHidden = true
//            if !isStop{
//                self.startFirstCircle()
//            }
//        }
//
//    }
//
//    private func controlSecondCircleExpand(){
//        UIView.animate(withDuration: 4.0) {
//            self.secondGreyCircle.bounds = CGRect(x: 0, y: 0, width: self.greyCircleMaxWidth, height: self.greyCircleMaxWidth)
//            self.secondGreyCircle.center = CGPoint(x: self.bounds.width/2.0, y: self.bounds.height/2.0)
//            self.secondGreyCircle.alpha = 0.0
//        } completion: { [self] finished in
//            self.secondGreyCircle.isHidden = true
//            if !isStop{
//                self.startSecondCircle()
//            }
//        }
//
//    }
//
//    private func controlThirdCircleExpand(){
//        UIView.animate(withDuration: 4.0) {
//            self.thirdGreyCircle.bounds = CGRect(x: 0, y: 0, width: self.greyCircleMaxWidth, height: self.greyCircleMaxWidth)
//            self.thirdGreyCircle.center = CGPoint(x: self.bounds.width/2.0, y: self.bounds.height/2.0)
//            self.thirdGreyCircle.alpha = 0.0
//        } completion: { [self] finished in
//            self.thirdGreyCircle.isHidden = true
//            if !isStop{
//                self.startThirdCircle()
//            }
//        }
//
//    }
// }
