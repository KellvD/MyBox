//
//  CDShareView.swift
//  Share
//
//  Created by cwx889303 on 2021/10/11.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit
import SwiftSoup
class CDShareUrlView: UIView {
    
    private var iconImageView:UIImageView!
    private var titleLabel:UILabel!
    private var contentLabel:UILabel!
    public var titleContent:String? = nil
    override init(frame: CGRect) {
        super.init(frame: frame)

        iconImageView = UIImageView(frame: CGRect(x: 10, y: frame.height/2.0 - 65/2.0, width: 75, height: 75))
        iconImageView.layer.cornerRadius = 4.0
        iconImageView.image = UIImage(named: "link_icon")
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.borderColor =  UIColor(red: 243 / 255.0, green: 243 / 255.0, blue: 243 / 255.0, alpha: 1.0).cgColor
        iconImageView.clipsToBounds = true
        self.addSubview(iconImageView)
        
        titleLabel = UILabel(frame: CGRect(x: iconImageView.frame.maxX + 10, y: 15, width: frame.width - 110, height: frame.height - 30))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        self.addSubview(titleLabel)

        
        
        
        let sepertorbottom = UIView(frame: CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1))
        sepertorbottom.backgroundColor = UIColor(red: 243 / 255.0, green: 243 / 255.0, blue: 243 / 255.0, alpha: 1.0)
        self.addSubview(sepertorbottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadUrlData(url:URL){
        
        do {
            let html = try String(contentsOf: url)
            let document = try SwiftSoup.parse(html)
            
            let title = try document.title()
            titleContent = title
            titleLabel.text = title
            let metas: Elements = try document.select("meta")
            for meta in metas {
                let propertyKey: String = try meta.attr("property")
                if propertyKey.lowercased() == "og:image" {
                    let iconStr:String = try meta.attr("content")
                    iconImageView.image = UIImage(data: try Data(contentsOf: URL(string: iconStr)!))
                    break
                }
                
                let nameKey: String = try meta.attr("name")
                if nameKey.lowercased() == "description" {
                    let description = try meta.attr("content")
                    let titleAttr = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17),
                                                                                          NSAttributedString.Key.foregroundColor:UIColor.black])
                    let descriptionAttr = NSMutableAttributedString(string: description,
                                                                    attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),
                                                                                 NSAttributedString.Key.foregroundColor:UIColor.lightGray])
                    titleAttr.append(NSAttributedString(string: "\n"))
                    titleAttr.append(descriptionAttr)
                    titleLabel.attributedText = titleAttr
                }
                
                let itempropKey: String = try meta.attr("itemprop")
                if itempropKey.lowercased() == "image" {
                    let iconStr:String = try meta.attr("content")
                    iconImageView.image = UIImage(data: try Data(contentsOf: URL(string: iconStr)!))
                }
            }

        } catch {
            
            contentLabel.text = url.absoluteString
            print("解析HTML失败")
        }
    }
    
}

class CDShareTextView: UIView {
    
    private var titleLabel:UITextView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UITextView(frame: CGRect(x: 15, y: 0, width: frame.width - 30, height: frame.height - 1))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .left
        self.addSubview(titleLabel)
        
        let sepertorbottom = UIView(frame: CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1))
        sepertorbottom.backgroundColor = UIColor(red: 243 / 255.0, green: 243 / 255.0, blue: 243 / 255.0, alpha: 1.0)
        self.addSubview(sepertorbottom)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadTextData(content:String){
        titleLabel.text = content
    }
}


class CDShareFileView: UIView {

    private var iconImageView:UIImageView!
    private var titleLabel:UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)

        iconImageView = UIImageView(frame: CGRect(x: 15, y: frame.height/2.0 - 65.0/2.0, width: 65, height: 65))
        iconImageView.layer.cornerRadius = 4.0
        iconImageView.clipsToBounds = true
        iconImageView.image = UIImage(named: "file_other_big")
        self.addSubview(iconImageView)
        
        titleLabel = UILabel(frame: CGRect(x: iconImageView.frame.maxX + 15, y: iconImageView.frame.midY  - 45/2.0, width: frame.width - 110, height: 45))
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        self.addSubview(titleLabel)
        
        
        let sepertorbottom = UIView(frame: CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1))
        sepertorbottom.backgroundColor = UIColor(red: 243 / 255.0, green: 243 / 255.0, blue: 243 / 255.0, alpha: 1.0)
        self.addSubview(sepertorbottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadFileData(fileName:String){
        titleLabel.text = fileName
    }
}


