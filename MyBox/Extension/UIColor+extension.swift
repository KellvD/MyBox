//
//  UIColor+extension.swift
//  MyBox
//
//  Created by changdong on 2020/12/21.
//  Copyright © 2019 changdong. All rights reserved.
//

import Foundation
import UIKit
extension UIColor {

    // 随机颜色
    static var ramdom: UIColor {
        get {
            UIColor(red: CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1.0)
        }
    }
    // 全局背景色
    static var baseBgColor: UIColor {
        get {UIColor(247.0, 247.0, 247.0)}
    }

    // 分割线
    static var separatorColor: UIColor {
        get { return UIColor(223.0, 223.0, 223.0) }
    }

    // 导航栏背景色
    static var navgationBarColor: UIColor {
        get { return UIColor(250, 10, 32) }
    }

    // cell点击背景色
    static var cellSelectColor: UIColor {
        get { UIColor(213.0, 230.0, 244.0) }
    }

    static var customBlue: UIColor {
        get { UIColor(39.0, 160.0, 242.0) }
    }

    static var textBlack: UIColor {
        get { UIColor(61.0, 81.0, 97.0) }
    }

    static var textLightBlack: UIColor {
        get { UIColor(154.0, 154.0, 154.0) }
    }

    static var textGray: UIColor {
        get { UIColor(141.0, 151.0, 167.0) }
    }

    static var textLightGray: UIColor {
        get { UIColor(141.0, 151.0, 167.0) }
    }
}

extension UIColor {
    convenience init(_ Red: CGFloat, _ Green: CGFloat, _ Blue: CGFloat) {
        self.init(red: Red/255.0, green: Green/255.0, blue: Blue/255.0, alpha: 1.0)
    }

    convenience init(_ Red: CGFloat, _ Green: CGFloat, _ Blue: CGFloat, _ Alpha: CGFloat) {
        self.init(red: Red/255.0, green: Green/255.0, blue: Blue/255.0, alpha: Alpha)
    }

    convenience init(hexStr: String) {
        let hexNum = Int(hexStr, radix: 16)!
        self.init(red: CGFloat((hexNum & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((hexNum & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat((hexNum & 0x0000FF) >> 0) / 255.0,
                  alpha: 1.0)
    }
}
