//
//  UIView+extension.swift
//  MyBox
//
//  Created by changdong  on 2020/7/3.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit
public enum Direction : Int {
    case vertical
    case horizontal
}
extension UIView{
    
    var minX: CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var minY: CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.y
        }
    }
    
    var midX: CGFloat {
        set {
            var center = self.center
            center.x = newValue
            self.center = center
        }
        get {
            return self.center.x
        }
    }
    
    var midY: CGFloat {
        set {
            var center = self.center
            center.y = newValue
            self.center = center
        }
        get {
            return self.center.y
        }
    }
    var maxY: CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
        get {
            return self.height + self.minY
        }
    }
    
    var maxX: CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
        get {
            return self.width + self.minX
        }
    }
    var width: CGFloat {
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.width
        }
    }
    
    var height: CGFloat {
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.height
        }
    }
    
    var size: CGSize {
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
        get {
            return self.frame.size
        }
    }
    
    var origin: CGPoint {
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin
        }
    }
    
    
    
    
    /**
     添加翻页动画
     */
    func transition(subtype:CATransitionSubtype,duration:CFTimeInterval){
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.type = .push
        animation.subtype = subtype
        layer.add(animation, forKey: nil)
    }
    
    /**
     View添加圆角
     corners:圆角的方位，多个用[,]
     size:圆角的尺寸
     */
    func addRadius(corners:UIRectCorner,size:CGSize) {
        self.layoutIfNeeded()
        self.setNeedsLayout()
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    /*
     *View添加渐变背景
     *colors:渐变色
     *locations:色差分隔点
     *direction:渐变方向
     */
    
    func addBackgroundGradient(colors:[UIColor],locations:[NSNumber],direction:Direction) {
        let layer = CAGradientLayer()
        layer.colors = colors
        layer.locations = locations
        layer.startPoint = direction == .vertical ? CGPoint(x: 0.0, y: 0.0):CGPoint(x: 1.0, y: 0.0)
        layer.endPoint = direction == .vertical ? CGPoint(x: 0.0, y: 0.0):CGPoint(x: 1.0, y: 0.0)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.5
        layer.frame = self.bounds
        self.layer.addSublayer(layer)
    }
    
    /*
     *View增加边框
     *color:边框颜色
     *width:边框宽度
     *edge:边框位置
     */
    func addBorder(color:UIColor,width:CGFloat,edge:UIRectEdge) {
        if edge == .all {
            self.layer.borderColor = color.cgColor
            self.layer.borderWidth = width
        }else{
            let layer = CALayer()
            layer.backgroundColor = color.cgColor;
            let x = edge != .right ? 0 : self.frame.width - width
            let y = edge != .bottom ? 0 : self.frame.height - width
            layer.frame = CGRect(x: x, y: y, width: self.frame.width, height: self.frame.height)
            self.layer.addSublayer(layer)
        }
        self.layer.masksToBounds = true
    }
    
    /**
     *View 增加磨玻璃效果
     *style:样式
     */
    func addBlurEffect(style:UIBlurEffect.Style){
        let effect = UIBlurEffect(style: style)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.bounds
        self.backgroundColor = .clear
        self.addSubview(effectView)
        self.sendSubviewToBack(effectView)
    }
    
    
}
