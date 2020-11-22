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
    
    func width()->CGFloat{
        return self.frame.width
    }
    func height()->CGFloat{
        return self.frame.height
    }
    func minX()->CGFloat{
        return self.frame.minX
    }
    func minY()->CGFloat{
        return self.frame.minY
    }
    func maxX()->CGFloat{
        return self.frame.maxX
    }
    func maxY()->CGFloat{
        return self.frame.maxY
    }
    func size()->CGSize{
        return self.frame.size
    }
    func midX()->CGFloat{
        return self.frame.midX
    }
    func midY()->CGFloat{
        return self.frame.midY
    }
    func centerY()->CGFloat{
        return self.center.y
    }
    func centerX()->CGFloat{
        return self.center.x
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
    
}
