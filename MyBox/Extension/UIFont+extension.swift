//
//  UIFont+extension.swift
//  MyBox
//
//  Created by changdong on 2021/3/9.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import UIKit
extension UIFont {
    class var small: UIFont {
        get { return UIFont.systemFont(ofSize: 12) }
    }

    class var midSmall: UIFont {
        get { return UIFont.systemFont(ofSize: 15) }
    }

    class var mid: UIFont {
        get { return UIFont.systemFont(ofSize: 17) }
    }

    class var large: UIFont {
        get { return UIFont.systemFont(ofSize: 20) }
    }

}

extension UIFont {
    class func font(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
}
