//
//  NSNotification+extension.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/12/17.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import Foundation

extension NSNotification.Name{
    public static let DismissImagePicker:NSNotification.Name = NSNotification.Name(rawValue: "DismissImagePicker")
    public static let DocumentInputFile:NSNotification.Name = NSNotification.Name(rawValue: "DocumentInputFile")
    public static let RefreshProgress:NSNotification.Name = NSNotification.Name(rawValue: "RefreshProgress")
    public static let BarsHiddenOrNot:NSNotification.Name = NSNotification.Name(rawValue: "BarsHiddenOrNot")
    public static let PlayThePlayer:NSNotification.Name = NSNotification.Name(rawValue: "PlayThePlayer")
}
