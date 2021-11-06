//
//  CDSqlDefines.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import SQLite
let sqlFileName = "CDSQL.db"

let SafeFileInfo = Table("CDSafeFileInfo")
let UserInfo = Table("CDUserInfo")
let MusicInfo = Table("CDMusicInfo")
let MusicClassInfo = Table("CDMusicClassInfo")
let AttendanceInfo = Table("CDAttendanceInfo")
let NovelInfo = Table("CDNovelInfo")
let ChapterInfo = Table("CDChapterInfo")

let db_id = Expression<Int>("id")
var db_folderName = Expression<String>("folderName")
var db_folderId = Expression<Int>("folderId")
var db_folderType = Expression<Int>("folderType")
var db_isLock = Expression<Int>("isLock")
var db_fakeType = Expression<Int>("fakeType")
var db_createTime = Expression<Int>("createTime")
var db_modifyTime = Expression<Int>("modifyTime")
var db_importTime = Expression<Int>("importTime")
var db_createLocation = Expression<String>("createLocation")
var db_folderPath = Expression<String>("folderPath")
var db_fileId = Expression<Int>("fileId")
var db_fileSize = Expression<Int>("fileSize")
var db_fileWidth = Expression<Double>("fileWidth")
var db_fileHeight = Expression<Double>("fileHeight")
var db_timeLength = Expression<Double>("timeLength")
var db_fileType = Expression<Int>("fileType")
var db_fileName = Expression<String>("fileName")
var db_fileText = Expression<String>("fileText")
var db_thumbImagePath = Expression<String>("thumbImagePath")
var db_filePath = Expression<String>("filePath")
var db_grade = Expression<Int>("grade")
var db_userId = Expression<Int>("userId")
var db_markInfo = Expression<String>("markInfo")
var db_basePwd = Expression<String>("basePwd")
var db_fakePwd = Expression<String>("fakePwd")

//MARK:musicInfo
var db_musicId = Expression<Int>("musicId")
var db_musicName = Expression<String>("musicName")
var db_musicMark = Expression<String>("musicMark")
var db_musicTimeLength = Expression<Double>("musicTimeLength")
var db_musicClassId = Expression<Int>("musicClassId")
var db_musicSinger = Expression<String>("musicSinger")
var db_musicPath = Expression<String>("musicPath")
var db_musicImage = Expression<String>("musicImage")
//MARK:musicClass
var db_classId = Expression<Int>("classId")
var db_className = Expression<String>("className")
var db_classAvatar = Expression<String>("classAvatar")
var db_classCreateTime = Expression<Int>("classCreateTime")
var db_superId = Expression<Int>("superId")

//MARK:CDAttendanceInfo
var db_attendanceId = Expression<Int>("attendanceId")
var db_time = Expression<Int>("time")
var db_day = Expression<Int>("day")
var db_month = Expression<Int>("month")
var db_year = Expression<Int>("year")
var db_title = Expression<String>("title")
var db_type = Expression<Int>("type")
var db_statue = Expression<Int>("statue")



var db_novelName = Expression<String>("novelName")
var db_novelPath = Expression<String>("novelPath")
var db_novelId = Expression<Int>("novelId")

var db_chapterName = Expression<String>("chapterName")
var db_content = Expression<String>("content")
var db_charterId = Expression<Int>("charterId")
