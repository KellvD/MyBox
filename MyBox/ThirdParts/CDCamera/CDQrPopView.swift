//
//  CDQrPopView.swift
//  MyBox
//
//  Created by changdong on 2021/10/8.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDQrPopView: UIView {
    enum CDQRType:Int {
        case Text
        case Url
    }
    private var typeLabel:UILabel!
    private var titleLabel:UILabel!
    private var contentLabel:UILabel!
    var onTapQrCodeHandle:((_ isEnable:Bool)->Void)!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 14.0
        self.backgroundColor = UIColor(204, 194, 189)
        let iconView = UIImageView(frame: CGRect(x: 15.0, y: 15.0, width: 30, height: 30))
        iconView.backgroundColor = .red
        iconView.isUserInteractionEnabled = true
        self.addSubview(iconView)
        
        let detailIconView = UIImageView(frame: CGRect(x: self.frame.width - 20 - 45.0, y: self.frame.height/2.0 - 45.0/2.0, width: 45.0, height: 45.0))
        detailIconView.backgroundColor = .blue
        detailIconView.isUserInteractionEnabled = true
        self.addSubview(detailIconView)
        
        
        typeLabel = UILabel(frame: CGRect(x: iconView.frame.maxX + 10.0, y: iconView.frame.minY, width: detailIconView.frame.minX - iconView.frame.maxX - 20.0, height: 30.0))
        typeLabel.textColor = .gray
        typeLabel.font = UIFont.boldSystemFont(ofSize: 13)
        addSubview(typeLabel)
        
        titleLabel = UILabel(frame: CGRect(x: iconView.frame.minX, y: typeLabel.frame.maxY, width: detailIconView.frame.minX - iconView.frame.maxX, height: 20.0))
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        addSubview(titleLabel)
        
        contentLabel = UILabel(frame: CGRect(x: titleLabel.frame.minX, y: titleLabel.frame.maxY, width: self.width - iconView.frame.maxX, height: titleLabel.frame.height))
        contentLabel.textColor = .black
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        addSubview(contentLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onHitQrCodeTap))
        addGestureRecognizer(tap)
        
        let hiddenTap = UISwipeGestureRecognizer(target: self, action: #selector(onHiddenQrCodeTap))
        hiddenTap.direction = .up
        addGestureRecognizer(hiddenTap)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func loadData(type:CDQRType,qrContent:String){
        if type == .Text {
            typeLabel.text = "文本二维码"
            titleLabel.text = "在Safari浏览器中搜索网页"
            contentLabel.text = "内容：“\(qrContent)”"
        }else{
            typeLabel.text = "网站二维码"
            titleLabel.text = "在Safari浏览器中打开网站"
            contentLabel.text = "链接：“\(qrContent)”"
        }
        
    }
    
    @objc func onHitQrCodeTap(){
        self.onTapQrCodeHandle(true)
    }
    
    @objc func onHiddenQrCodeTap(){
        self.onTapQrCodeHandle(false)
    }
}
