//
//  CDReaderModel.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/7/1.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit


class CDReaderModel: NSObject {

    public var resource:String!
    public var content:String!
    public var chapters:[CDChapterModel] = []
    public var record:CDRecordModel!
    public var font:NSNumber!
    
    init(con:String) {
        super.init()
        content = con
        var charpterArr:[CDChapterModel] = []
        CDReadUtilites.separateChapter(&charpterArr, content: content)
        chapters = charpterArr
        record = CDRecordModel()
        record.chapterModel = chapters.first ?? CDChapterModel()
        record.chapterCount = chapters.count
        font = NSNumber(value: CDReaderConfig.shared.fontSize)
    }
    
    public func getPageIndex(offset:NSInteger,chapterIndex:NSInteger) -> NSInteger {
        let chapter = chapters[chapterIndex]
        let pageArr = chapter.pa
    }
    
//    class public func updateLocalModel(model:CDReaderModel,url:URL){
//
//    }
//
//    class public func getLocalModel(url:URL) -> CDReaderModel {
//
//
//    }
}


class CDChapterModel: NSObject {
    var pageArray:[] = []
    var title = String()
    var content = String()
    var process = Double()
    var chapterIndex = Int()
    var pageCount = Int()
    
    func stringOfPage(index:Int) -> String {
        
    }
    func updateFont() {
        
    }
}

class CDRecordModel: NSObject {
    public var chapterModel = CDChapterModel();  //阅读的章节
    public var page = Int() //阅读的页数
    public var chapter = Int() //阅读的章节数
    public var chapterCount = Int()//总章节数
    

}
