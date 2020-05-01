//
//  CDSafeFileInfo.swift
//  MyRule
//
//  Created by changdong on 2018/12/7.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation

class CDSafeFileInfo: NSObject {

    var fileId = Int()
    var folderId = Int()
    var fileSize = Int()
    var fileWidth = Double()
    var fileHeight = Double()
    var timeLength = Double()
    var createTime = Int()
    var fileType:NSFileType!
    var fileName = String()
    var fileText = String()
    var thumbImagePath = String()
    var filePath = String()
    var markInfo = String()
    var userId = Int()
    var grade:NSFileGrade!
}
