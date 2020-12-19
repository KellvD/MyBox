//
//  String+extension.swift
//  MyBox
//
//  Created by changdong  on 2020/7/6.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import Foundation
import CommonCrypto
import UIKit
extension String{
    /*
    字符串的MD5算法
    */
   var md5:String{
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = data(using: .utf8) {
            data.withUnsafeBytes { (bytes:UnsafePointer<UInt8>) -> Void in
                CC_MD5(bytes,CC_LONG(data.count),&digest)
            }
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
    
    /*
    判断字符串是否为空
    */
    var isEmpty:Bool{
        
        if self == "" || self.count == 0{
            return true
        }else{
            return false
        }
    }
    
    /*
    去除字符串的空格
    */
    func removeSpaceAndNewline()->String{
        let text = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        return text
    }
    
    /*
    获取字符串长度，汉字两个字节，字符一个
    */
    func getLength(needTrimSpaceCheck: Bool) -> Int {
        if needTrimSpaceCheck {
            let realText = self.removeSpaceAndNewline()
            if 0 == realText.count {
                return 0
            }
        }
        var len = 0
        for scalar in self.unicodeScalars {
            if scalar.value > 0 && scalar.value < 127{
                len += 1
            }else{
                len += 2
            }
        }
        return len
    }
    
    /*
    判断字符串是否包含表情包
    */
    func isContainsEmoji() -> Bool {
        var returnValue = false
        let nsStr = self as NSString

        nsStr.enumerateSubstrings(in: NSRange(location: 0, length: self.count), options: .byComposedCharacterSequences) { (substring, substringRange, enclosingRange, stop) in
            let nsSub = substring! as NSString

            let hs = unichar(nsSub.character(at: 0))
            // surrogate pair
            if 0xd800 <= hs && hs <= 0xdbff {
                if nsSub.length > 1 {
                    let ls = unichar(nsSub.character(at: 1))
                    let uc = (Int((hs - 0xd800)) * 0x400) + Int((ls - 0xdc00)) + 0x10000
                    if 0x1d000 <= uc && uc <= 0x1f77f {
                        returnValue = true
                    }
                }else if nsSub.length > 1 {
                    let ls = unichar(nsSub.character(at: 1))
                    if ls == 0x20e3 {
                        returnValue = true
                    }
                }else{
                    if 0x2100 <= hs && hs <= 0x27ff {
                        returnValue = true
                    } else if 0x2b05 <= hs && hs <= 0x2b07 {
                        returnValue = true
                    } else if 0x2934 <= hs && hs <= 0x2935 {
                        returnValue = true
                    } else if 0x3297 <= hs && hs <= 0x3299 {
                        returnValue = true
                    } else if hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50 {
                        returnValue = true
                    }

                }
            }
        }
        return returnValue;
    }
    
    func labelWidth(height:CGFloat,font:UIFont) -> CGFloat {
        let size:CGSize = CGSize(width: 0, height: height)
        let frame = self.boundingRect(with: size, options:
            NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.truncatesLastVisibleLine.rawValue |
                NSStringDrawingOptions.usesFontLeading.rawValue), attributes: [NSAttributedString.Key.font:font], context: nil)
        return frame.size.width
    }
    
    func labelHeight(width:CGFloat,font:UIFont) -> CGFloat {
        let size:CGSize = CGSize(width: width, height: 0)
        let frame = self.boundingRect(with: size, options:
            NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.truncatesLastVisibleLine.rawValue |
                NSStringDrawingOptions.usesFontLeading.rawValue), attributes: [NSAttributedString.Key.font:font], context: nil)
        return frame.size.height
    }
    
    func matches(pattern:String)->Bool{
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
            let res = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, self.count))
            if res.count > 0 {
                return true
            }
            return false
        } catch  {
            return false
        }
    }
}


