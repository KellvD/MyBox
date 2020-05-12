//
//  CDSQLModel.swift
//  MyBox
//
//  Created by changdong on 2020/5/1.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

class CDUserInfo: NSObject {

    var userId = Int()
    var basePwd = String()
    var fakePwd = String()
}

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
    var isSelected:CDSelectedStatus! //不入库，作为判断文件操作时是否选中，出库时设置为”false“,选中时设置为”True“，最后判断本字段
}

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
    var isSelected:CDSelectedStatus!
}

class CDMusicInfo: NSObject {

    var musicId = Int()
    var musicName = String()
    var musicMark = String()
    var musicTimeLength = Double()
    var musicClassId = Int()
    var userId = Int()
    var musicSinger = String()
    var musicPath = String()
    var musicImage = String()
}
class CDMusicClassInfo: NSObject {
    var classId = Int()
    var className = String()
    var classAvatar = String()
    var userId = Int()
    var classCreateTime = Int()
}
