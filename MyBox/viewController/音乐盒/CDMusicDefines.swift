//
//  CDMusicDefines.swift
//  MyRule
//
//  Created by changdong on 2019/6/24.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit


let CD_MusicCurrentPlayId = "CD_MusicCurrentPlayId"
let CD_MusicPlayerStatus = "CD_MusicPlayerStatus"
let CD_MusicCircleStatus = "CD_MusicCircleStatus"

struct MusicInfo {
    //    var musicName = String() //歌名
    //    var albumName = String() //专辑
    var artist = String()    //歌手
    var image = UIImage()
    var length = Double()

}
enum CDCircleType:Int {
    case CDCircle_Signal
    case CDCircle_Queue
    case CDCircle_Random
}


let CD_CurrentCircleKey = "CurrentCircle"
let CD_CurrentMusicIdKey = "CurrentMusicId"
let CD_CurrentClassIdKey = "CurrentClassId"

let musicPopShare = "分享"
let musicPopCollection = "添加至歌单"
let musicPopEditClass = "编辑歌单"
let musicPopEditSort = "更改排序"
let musicPopDelete = LocalizedString("delete")
