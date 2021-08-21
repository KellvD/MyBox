//
//  UITextView+extension.swift
//  fr
//
//  Created by changdong cwx889303 on 2021/2/22.
//

import Foundation
import UIKit

extension UITextView{
    convenience init(frame:CGRect,placeHolder:String?) {
        self.init(frame: frame, textContainer: nil)
        self.placeHolder = placeHolder == nil ? "" : placeHolder
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(noti:)), name: UITextView.textDidChangeNotification, object: nil)

    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
//    }
    
    struct PropertyKey {
        static var _isLongPressKey:Bool = true
        static var _placeHolderKey:Void?
        static var _placeHolderColorKey:Void?
    }
    @IBInspectable var placeHolder:String?{
        get{
            return objc_getAssociatedObject(self, &PropertyKey._placeHolderKey) as? String
        }
        
        set{
            objc_setAssociatedObject(self, &PropertyKey._placeHolderKey, newValue, .OBJC_ASSOCIATION_COPY)
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var placeHolderColor:UIColor?{
        get{
            return objc_getAssociatedObject(self, &PropertyKey._placeHolderColorKey) as? UIColor
        }
        
        set{
            objc_setAssociatedObject(self, &PropertyKey._placeHolderColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsDisplay()
        }
    }
    
    
    var isLongPress:Bool?{
        get{
            return PropertyKey._isLongPressKey
        }
        
        set{
            PropertyKey._isLongPressKey = newValue ?? true
        }
    }
    
    @IBInspectable var text: String!{
        set {
            self.text = newValue
            setNeedsDisplay()
        }
        get{
            return self.text
        }
    }
    
    @IBInspectable var attributedText: NSAttributedString!{
        set {
            self.attributedText = newValue
            setNeedsDisplay()
        }
        get{
            return self.attributedText
        }
    }
    
    
    @objc func textDidChange(noti:NSNotification){
        self.setNeedsDisplay()
    }
    
    open override func layoutSubviews() {
        self.setNeedsLayout()
    }
    
    open override func draw(_ rect: CGRect) {
        if self.hasText { //如果有文字，直接返回，不需要重绘占位符
            return
        }
        let attr = [NSAttributedString.Key.foregroundColor : self.placeHolderColor ?? .gray,NSAttributedString.Key.font:self.font ?? UIFont.systemFont(ofSize: 13)]
        let width = rect.width - 2 * rect.origin.x
        let mrect:CGRect = CGRect(x: 5, y: 8, width: width, height: rect.height)
 
        ((self.placeHolder ?? "") as NSString).draw(in: mrect, withAttributes: attr)
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return isLongPress!
    }
}
    
   
    
