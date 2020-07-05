//
//  CDReadUtilites.swift
//  filter
//
//  Created by changdong cwx889303 on 2020/6/9.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

class CDReadUtilites: NSObject {

    
    class func separateChapter(_ chapters:inout [CDChapterModel],content:String) {
        chapters.removeAll()
        let parten = "第[0-9一二三四五六七八九十百千]*[章回].*"
        guard let regex = try? NSRegularExpression(pattern: parten, options: []) else {
            return
        }
        let nsContent = content as NSString
        let match = regex.matches(in: content, options: .reportCompletion, range: NSRange(location: 0, length: content.count))
        if match.count != 0 {
            var lastRange = NSRange(location: 0, length: 0)
            
            for idx in 0..<match.count {
                let obj = match[idx]
                let range = obj.range
                let location = range.location
                if idx == 0 {
                    let model = CDChapterModel()
                    model.title = "开始"
                    let len = location
                    model.content = nsContent.substring(with: NSRange(location: 0, length: len))
                    chapters.append(model)
                }
                
                if idx == 0 {
                    let model = CDChapterModel()
                    model.title = nsContent.substring(with: lastRange)
                    let len = location - lastRange.location
                    model.content = nsContent.substring(with: NSRange(location: lastRange.location, length: len))
                    chapters.append(model)
                }
                if idx == match.count - 1 {
                    let model = CDChapterModel()
                    model.title = nsContent.substring(with: range)
                    model.content = nsContent.substring(with: NSRange(location: location, length: nsContent.length - location))
                    chapters.append(model)
                }
                lastRange = range
            }
        } else {
            let model = CDChapterModel()
            model.content = content
            chapters.append(model)
        }
        
    }
    
}
