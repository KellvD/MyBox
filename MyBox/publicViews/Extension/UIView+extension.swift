//
//  UIView+extension.swift
//  MyBox
//
//  Created by changdong  on 2020/7/3.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit

extension UIView{
    
    func transition(subtype:CATransitionSubtype,duration:CFTimeInterval){
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.type = .push
        animation.subtype = subtype
        layer.add(animation, forKey: nil)
        
    }
}
