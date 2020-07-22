//
//  UIView+extension.swift
//  MyBox
//
//  Created by changdong  on 2020/7/3.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit

extension UIView{
    
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
}
