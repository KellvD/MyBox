//
//  CDSQLModel.swift
//  MyBox
//
//  Created by changdong on 2020/5/1.
//  Copyright © 2019 baize. All rights reserved.
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
    var fakeType = CDFakeType.invisible         //文件夹访客可见不可见
    var createTime = Int()       //文件夹创建时间
    var modifyTime = Int() //修改时间
    var accessTime = Int() //访问时间
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
    var createTime = Int() //创建时间 相册，沙盒导入文件的创建时间
    var modifyTime = Int() //修改时间
    var accessTime = Int() //访问时间
    var importTime = Int() //导入时间
    var fileType:NSFileType!
    var fileName = String()
    var fileText = String()
    var thumbImagePath = String()
    var filePath = String()
    var markInfo = String()
    var createLocation = String()
    var userId = Int()
    var grade:NSFileGrade!
    var isSelected:CDSelectedStatus!
    var folderType:NSFolderType! //文件所属大类
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

class CDAttendanceInfo:NSObject{
    var attendanceId = Int() //日程Id
    var year = Int() //事件拆分年 不入库
    var month = Int() //事件拆分月 不入库
    var day = Int() //事件拆分日 不入库
    var time = Int() //年月日时分
    var title = String()
    var type = Int()
    var statue = Int()
}
