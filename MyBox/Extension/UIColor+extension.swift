//
//  UIColor+extension.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/12/21.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import Foundation
import UIKit
extension UIColor{

    //随机颜色
    var ramdom:UIColor{
        get{
            UIColor(red: CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1.0)
        }
    }
    //全局背景色
    static var baseBgColor:UIColor{
        get{
            UIColor(231.0, 231.0, 231.0)
        }
    }
    
    //分割线
    static var separatorColor:UIColor{
        get{
            return UIColor(223.0, 223.0, 223.0)
        }
    }
    
    //cell点击背景色
    static var cellSelectColor:UIColor{
        get{
            UIColor(213.0, 230.0, 244.0)
        }
    }
    
    convenience init(_ Red:CGFloat,_ Green:CGFloat,_ Blue:CGFloat){
        self.init(red:Red/255.0, green:Green/255.0,blue:Blue/255.0,alpha:1.0)
    }

    convenience init(_ Red:CGFloat,_ Green:CGFloat,_ Blue:CGFloat,_ Alpha:CGFloat){
        self.init(red:Red/255.0, green:Green/255.0,blue:Blue/255.0,alpha:Alpha)
    }
    
    convenience init(hexNum:Int) {
        self.init(red: CGFloat((hexNum & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((hexNum & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat((hexNum & 0x0000FF) >> 0) / 255.0,
                  alpha: 1.0)
    }
}
