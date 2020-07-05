//
//  CDReaderParser.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/7/1.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

class CDReaderParser: NSObject {

    
    static let shared = CDReaderParser()
    
    class func parserContent(content:String,config:CDReaderConfig,bounds:CGRect) -> CTFrame{
        let attributeString = NSMutableAttributedString(string: content)
        let attribute = parserAttribute(config: config)
        attributeString.setAttributes(attribute, range: NSRange(location: 0, length: content.count))
        let setterRef:CTFramesetter = CTFramesetterCreateWithAttributedString(attributeString)
        let pathRef = CGPath(rect: bounds, transform: nil)
        let frmaeRef:CTFrame = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, 0), pathRef, nil)
        
        return frmaeRef
    }
    
    class func parserAttribute(config:CDReaderConfig) -> [NSAttributedString.Key:Any]{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = config.lineSpace
        paragraphStyle.alignment = .justified
        
        let dict = [NSAttributedString.Key.foregroundColor:config.fontColor!,
                NSAttributedString.Key.font:config.fontSize!,
                NSAttributedString.Key.paragraphStyle:paragraphStyle
            ] as [NSAttributedString.Key : Any]
        
        return dict
    }
}
