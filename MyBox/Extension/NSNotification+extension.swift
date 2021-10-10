//
//  NSNotification+extension.swift
//  MyBox
//
//  Created by changdong on 2020/12/17.
//  Copyright © 2019 changdong. All rights reserved.
//

import Foundation

extension NSNotification.Name{
    public static let DismissImagePicker:NSNotification.Name = NSNotification.Name(rawValue: "DismissImagePicker")
    public static let DocumentInputFile:NSNotification.Name = NSNotification.Name(rawValue: "DocumentInputFile")
    public static let RefreshProgress:NSNotification.Name = NSNotification.Name(rawValue: "RefreshProgress")
    public static let BarsHiddenOrNot:NSNotification.Name = NSNotification.Name(rawValue: "BarsHiddenOrNot")
    public static let PlayThePlayer:NSNotification.Name = NSNotification.Name(rawValue: "PlayThePlayer")
}
