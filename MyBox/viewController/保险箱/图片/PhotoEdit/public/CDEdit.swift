//
//  CDEdit.swift
//  PhotoEdit
//
//  Created by changdong on 2019/5/14.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit
typealias ImageBlock = (UIImage?) -> Void
typealias VoidBlock = () -> Void
typealias IntegerBlock = (NSInteger?) -> Void
class CDEdit: NSObject {

    class func trunRGBToUIColor(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) ->UIColor{
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}
