//
//  CDTextViewConfig.swift
//  CDTextViewDemo
//
//  Created by changdong on 2020/9/10.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

let IndentsMin = 0
let PickFalgColor  = UIColor(red:39/255.0,green:162/255.0,blue:242/255.0,alpha:1.0)


//字体样式
enum CDTextTools:Int{
    case heading = 0  //标题
    case subHeading   //副标题
    case body         //正文
    case fontName     //字体名字
    case fontSize     //字体大小
    case subIndents   //减缩进
    case addIndents   //加缩进
    case textColor    //字体颜色
    case textBgColor      //字体背景颜色
    case blod         //粗体
    case italic       //斜体
    case underline    //下划线
    case paragraphSymbol //项目符号
}
//样式图片
let optionArr:[String] = ["heading","subheading","body",
                          "fontName","fontSize",
                          "subIndents","addIndents","fontColor","fontbgColor",
                          "blod","italic","underline","项目符号05"]


class CDTextViewConfig: NSObject {

    var superVC:UIViewController! //承载CDTextView的ViewController
    var textView:CDTextView!
    var titleType:CDTextTools! //标题，副标题，正文
    var blodType:CDTextTools! //粗体，斜体，下划线
    var textViewBgColor:UIColor!
    var indents:Int = 10
    var fontName:String = "楷体"
    var fontSize:String = "9"
    var fontColor:UIColor = .black
    var fontbgColor:UIColor = .white
    var paragraphSymbol:UIImage!
    var pickType:CDPickerType!
    static let share = CDTextViewConfig()
    
    lazy var textStyleView: CDInputView = {
        let view = CDInputView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 240))
        view.delegate = textView
        return view
    }()
    
    lazy var accessoryView: CDInputAccessoryView = {
        let view = CDInputAccessoryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48))
        return view
    }()
    
    lazy var textFontView: CDFontView = {
        let view = CDFontView(frame: CGRect(x: 0, y:  0, width:  UIScreen.main.bounds.width, height: 240))
        return view
    }()
    
    lazy var pickView: CDPickerView = {
        var view = CDPickerView(frame: CGRect(x: 0, y: 0, width:  UIScreen.main.bounds.width, height: 240))
        return view
    }()
    
    static func setObject(key:String,value:CDTextTools){
        
    }
    
    static func getObject(key:String){
        
    }
    

    /**
     *切换inputView
     */
    func addInputView(view:UIView) {
        if (view == pickView){
            pickView.reloadView()
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.textView.resignFirstResponder()
        }) { (flag) in
            self.textView.inputAccessoryView = nil
            self.textView.inputView = view
            UIView.animate(withDuration: 0.25) {
                self.textView.becomeFirstResponder()
            }
        }

    }
       
    func removeInputView(view:UIView) {
        UIView.animate(withDuration: 0.25, animations: {
            self.textView.resignFirstResponder()
        }) { (flag) in
            
            if (view == self.pickView && self.pickType == .viewBgColor){ //textView背景->字母键盘
                self.textView.inputView = nil
                self.textView.inputAccessoryView = self.accessoryView
            }else{ //其他的切回样式键盘
                self.textView.inputView = self.textStyleView
                self.textView.inputAccessoryView = nil
            }
            
            UIView.animate(withDuration: 0.25) {
                self.textView.becomeFirstResponder()
            }
        }
    }
    
    func updateTextView() {
        
        let selRange = textView.selectedRange
        
        let mutablAttributeStr = NSMutableAttributedString(string: textView.text)
        if selRange.length == 0 {//未选中
            
        }else{
            //处理选中的内容
            let dict:[NSAttributedString.Key:Any] = [
                NSAttributedString.Key.font:UIFont(name: fontName, size: CGFloat(Float(fontSize)!))!,
                NSAttributedString.Key.foregroundColor:fontColor,
                NSAttributedString.Key.backgroundColor:fontbgColor
                
            ]
            mutablAttributeStr.setAttributes(dict, range: selRange)
            textView.attributedText = mutablAttributeStr
            
        }
        
        superVC.view.backgroundColor = textViewBgColor

    }

    
//    func initTextViewAttributeString() -> NSAttributedString {
//
//    }
    
    
    
    func handleAccessoryOption(item:Int) {
        UIView.animate(withDuration: 0.25, animations: {
            self.textView.resignFirstResponder()
        }) { (flag) in
            if item == 0 { // 调换背景
                self.pickType = .viewBgColor
                self.addInputView(view: CDTextViewConfig.share.pickView)
            }else if item == 1 {
                self.textView.inputAccessoryView = nil
                self.textView.inputView = self.textStyleView
                UIView.animate(withDuration: 0.25) {
                    self.textView.becomeFirstResponder()
                }
                
            } else if item == 2{
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let scanAction = UIAlertAction(title: "扫描文稿".localize, style: .default, handler: { (action) in
                    
                })
                scanAction.setValue(UIColor.orange, forKey: "titleTextColor")
                alert.addAction(scanAction)
                
                let cameraAction = UIAlertAction(title: "拍照录像".localize, style: .default, handler: { (action) in
                    
                })
                cameraAction.setValue(UIColor.orange, forKey: "titleTextColor")
                alert.addAction(cameraAction)
                
                let libraryAction = UIAlertAction(title: "照片图库".localize, style: .destructive, handler: { (action) in
                    
                })
                libraryAction.setValue(UIColor.orange, forKey: "titleTextColor")
                alert.addAction(libraryAction)
                
                let cancleAction = UIAlertAction(title: "取消".localize, style: .cancel, handler: nil)
                cancleAction.setValue(UIColor.red, forKey: "titleTextColor")
                alert.addAction(cancleAction)
                self.superVC.present(alert, animated: true, completion: nil)
            }
        }
    }
   
}

