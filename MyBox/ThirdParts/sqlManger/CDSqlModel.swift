//
//  CDSQLModel.swift
//  MyBox
//
//  Created by changdong on 2020/5/1.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDUserInfo: NSObject {

    var userId = Int()
    var basePwd = String()
    var fakePwd = String()
}

class CDSafeFolder : NSObject {

    var folderName = String()  //文件夹名称
    var folderId = Int()       //文件夹id
    var folderType:NSFolderType! //文件夹类型
    var isLock = Int()           //文件夹是否新建还是默认
    var fakeType = CDFakeType.visible         //文件夹访客可见不可见
    var createTime = Int()       //文件夹创建时间
    var userId = Int()           //预留，多账户使用
    var superId = Int()          //多层级文件夹时顶级文件夹的ID
    var folderPath = String()    //文件夹路径
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
