//
//  CDSafeFolder.swift
//  MyRule
//
//  Created by changdong on 2018/12/7.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation

class CDSafeFolder : NSObject {

    var folderName = String()
    var folderId = Int()
    var folderType:NSFolderType!
    var isLock = Int()
    var identify = Int()
    var createTime = Int()
    var userId = Int()
    var superId = Int()
    var folderPath = String()
}
