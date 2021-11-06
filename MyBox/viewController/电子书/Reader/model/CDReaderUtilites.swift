//
//  CDReaderUtilites.swift
//  filter
//
//  Created by changdong on 2020/6/9.
//  Copyright changdong 2012-2019. All rights reserved.
//

import UIKit

class CDReaderUtilites: NSObject {


    
    static func encodeUrl(url:URL?) -> String? {
        if url == nil {
            return nil
        }
        var content:String!
        do {
            content = try String(contentsOf: url!, encoding: .utf8)
            return content
        } catch  {
            print("encodeUrl-utf8:",error)
        }
        
        if content == nil {
            do {
                content = try String(contentsOf: url!, encoding: String.Encoding(rawValue: 0x80000632))
                return content
            } catch  {
                print("encodeUrl-0x80000632:",error)
            }
        }
        if content == nil {
           do {
                content = try String(contentsOf: url!, encoding: String.Encoding(rawValue: 0x80000631))
                return content
            } catch  {
               print("encodeUrl-0x80000631:",error)
            }
        }
        
        return nil
        
        
    }
    
    static func parserContent(content:String,config:CDReaderConfig,bounds:CGRect) -> CTFrame{
        let attributeString = NSMutableAttributedString(string: content)
        let attribute = parserAttribute(config: config)
        attributeString.setAttributes(attribute, range: NSRange(location: 0, length: content.count))
        let setterRef:CTFramesetter = CTFramesetterCreateWithAttributedString(attributeString as CFAttributedString)
        let pathRef = CGPath(rect: bounds, transform: nil)
        let frmaeRef:CTFrame = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, 0), pathRef, nil)
        
        return frmaeRef
    }
    
    static func parserAttribute(config:CDReaderConfig) -> [NSAttributedString.Key:Any]{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = config.lineSpace
        paragraphStyle.alignment = .justified
        
        let dict = [NSAttributedString.Key.foregroundColor:config.fontColor!,
                    NSAttributedString.Key.font:UIFont(name: "Helvetica", size: CGFloat(config.fontSize))!,
                NSAttributedString.Key.paragraphStyle:paragraphStyle
            ] as [NSAttributedString.Key : Any]
        
        return dict
    }
}
