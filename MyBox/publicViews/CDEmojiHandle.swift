//
//  CDEmojiHandle.swift
//  MyRule
//
//  Created by changdong on 2019/6/21.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit


class CDEmojiHandle: NSObject {

    // 判断字符串中是否有自定义表情
    class func hasEmojiWithText(text:String) -> Bool{
        if text.count == 0{
            return false
        }
        let pattern = EmojiRegularExpression
        var regular:NSRegularExpression

        do {
            regular = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        } catch  {
            print("检查富文本error:\(error.localizedDescription)")
            return false
        }

        let resultArr = regular.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        if  resultArr.count > 0{
            return true
        }else{
            return false
        }
    }
//    // 所选字符最后位置是不是表情
//    class func isLastSelectedTextCustomEmoji(text:String) -> Bool{
//        if text.count > 0 {
//            //首先判断最后一个是不是表情
//            let lastChar = text.suffix(text.count - 1)
//            if lastChar == "]"{
//                //最后的位置是表情，查找表情的起始位置
//                var needIndex = -1
//                for i in 0..<(text.count - 1){
//                    let index = text.count - 1 - i
//                    let str = text.index(index, offsetBy: 1)
//                    if str == "["{
//                        needIndex = index
//                        break
//                    }
//                }
//                if needIndex >= 0{
//                    let emojiStr = String(text.suffix(needIndex))
//                    if self.isEmojiWithText(text: emojiStr){
//                        return true
//                    }
//
//                }
//
//            }
//
//        }
//        return false
//    }
//    // 删除最后位置是表情的字符
//    class func deleteLastEmojiTextWithText(text:String) -> NSDictionary{
//
//    }
//    // 将普通字符串转换成富文本
//    class func attributedStringWithText(text:String) -> NSAttributedString{
//
//        let attributedString = NSMutableAttributedString(string: text)
//        let pattern = EmojiRegularExpression
//        var regular:NSRegularExpression
//
//        do {
//            regular = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
//
//        } catch  {
//            print("检查富文本error:\(error.localizedDescription)")
//            return attributedString
//        }
//        let resultArr = regular.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
//        let imageArr = NSMutableArray(capacity: text.count)
//        let emojiArr = self.getClassicEmojiArray()
//        for match:NSTextCheckingResult in resultArr {
//            let range = match.range
//            let subStr = text.index(range.location, offsetBy: range.length)
//            for i in 0..<subStr.count{
//                var isInput = false
//                for i in 0..<emojiArr.count{
//                    if emojiArr[i]["en"] == text{
//                        isInput = true
//                    }else if emojiArr[i]["zh-Hans"] == text{
//                        isInput = true
//                    }else if emojiArr[i]["zh-Hant"] == text{
//                        isInput = true
//                    }
//                    if isInput{
//                        // 找到相应图片
//                        // 新建文字附件来存放我们的图片
//                        let textAttachment = NSTextAttachment()
//                        textAttachment.bounds = CGRect(x: textAttachment.bounds.origin.x, y: textAttachment.bounds.origin.y - 8, width: 25, height: 25)
//                        // 给附件添加图片
//                        textAttachment.image = UIImage(named: emojiArr[i]["png"])
//// 把附件转换成可变字符串，用于替换掉原字符串中的表情文字
//                        let imageStr = NSAttributedString(attachment: textAttachment)
//// 把图片和图片对应的位置存入字典中
//                        let imageDic = NSMutableDictionary(capacity: 2)
//                        imageDic.setObject(imageStr, forKey: "image")
//                        imageDic.setObject(NSValue(range: range), forKey: "range")
//                        imageArr.add(imageDic)
//
//                    }
//                }
//            }
//
//
//        }
//
//        for i in 0..<imageArr.count - 1 {
//            let index = imageArr.count - 1 - i
//            var range:Range!
//            imageArr[i]["range"].ge
//
//        }
//
//
//    }
//    // 将表情所在位置置换成三个空格，以便计算宽高
//    class func tempStringWithText(text:String) -> String{
//
//    }
//    // 获取经典表情数据
//    class func getClassicEmojiArray() -> Array{
//
//    }
//    // 计算富文本宽高
//    class func calculateAttributedStringSizeWithText(text:String) ->CGSize{
//
//
//    }
//
//    class func isEmojiWithText(text:String) ->Bool{
//        let emojiArr = getClassicEmojiArray()
//        for i in 0..<emojiArr.count{
//            if emojiArr[i]["en"] == text{
//                return true
//            }else if emojiArr[i]["zh-Hans"] == text{
//                return true
//            }else if emojiArr[i]["zh-Hant"] == text{
//                return true
//            }
//        }
//        return false
//
//    }

}
