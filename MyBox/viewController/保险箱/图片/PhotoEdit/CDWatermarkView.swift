//
//  CDWatermarkView.swift
//  MyRule
//
//  Created by changdong on 2019/6/28.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDWatermarkView: UIImageView {

    typealias BZTextHandle = (_ content:String)->Void
    var completeHandler:BZTextHandle!
    var cancleHandler:(()->())!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        blurView.alpha = 0.9
        self.addSubview(blurView)
        self.addSubview(cancle)
        self.addSubview(sure)
        self.addSubview(textView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    lazy var cancle: UIButton = {
        let btn = UIButton(frame: CGRect(x: 20, y: 20, width: 60, height: 40), text: "取消", textColor: .white, target: self, function: #selector(onDismissTextMarkView))
        return btn
    }()
    
    lazy var sure: UIButton = {
        let btn = UIButton(frame: CGRect(x: self.width - 20 - 60, y: 20, width: 60, height: 40), text: "确定", textColor: .white, target: self, function: #selector(onSureText))
        btn.backgroundColor = .green
        return btn
    }()
    
    lazy var textView: UITextView = {
        let textV = UITextView(frame: CGRect(x: 25.0, y: 100.0, width: self.width - 50.0, height: 200.0))
        textV.font = UIFont.boldSystemFont(ofSize: 20)
        textV.backgroundColor = .clear
        return textV
    }()
    
    
    @objc private func onDismissTextMarkView(){
        textView.resignFirstResponder()
        cancleHandler()
        UIView.animate(withDuration: 0.25) {
            var rect = self.frame
            if rect.origin.y == 0{
                rect.origin.y = CDSCREEN_HEIGTH
                self.frame = rect
            }
            
        }
    }
    
    @objc private func onSureText(){
        if !textView.text.isEmpty {
            completeHandler(textView.text)
        }
        onDismissTextMarkView()
    }
    func onPopTextMarkView() {
        
        UIView.animate(withDuration: 0.25) {
            var rect = self.frame
            if rect.origin.y == CDSCREEN_HEIGTH{
                rect.origin.y = 0
                self.frame = rect
            }
        } completion: { (flag) in
            self.textView.becomeFirstResponder()
        }

    }
}
