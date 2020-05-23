//
//  CDHUD.swift
//  MyBox
//
//  Created by changdong on 2020/5/8.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import MBProgressHUD
let HUD_DELAY = 2.0
class CDHUDManager: NSObject,MBProgressHUDDelegate {
    
    private var HUD:MBProgressHUD!
    private var bgView:UIView!
    private var porgressView:UIProgressView!
    private var porgressLabel:UILabel!
    
    
    
    static let instance:CDHUDManager = CDHUDManager()
    class func shareInstance()->CDHUDManager {
        return instance
    }
    
    func getAppWindow() -> UIWindow {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first!
        }else{
            return UIApplication.shared.keyWindow!
        }
    }
    func isKeyboardVisible() -> Bool {
        let window = getAppWindow()
        if window.findFirstResponse() == nil {
            return false
        }
        return true
    }
    func showTextAtMidBottom(text:String,isShowShortTime:Bool){
        let hud = MBProgressHUD.showAdded(to: getAppWindow(), animated: true)
        hud.mode = .text
        hud.margin = 10.0
        hud.offset = CGPoint(x: 0.0, y: 130)
        hud.removeFromSuperViewOnHide = true
        hud.isUserInteractionEnabled = false
        if isShowShortTime {
            hud.hide(animated: true, afterDelay: HUD_DELAY)
        }else{
            hud.hide(animated: true, afterDelay: 10.0)
        }
    }
    private func showComplete(text:String,imageName:String) {
        let hud = MBProgressHUD.showAdded(to: getAppWindow(), animated: true)
        hud.mode = .customView
        hud.customView = UIImageView(image: UIImage(named: imageName))
        hud.label.text = text
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: HUD_DELAY)
    }
    
    func showText(text:String){
        let hud = MBProgressHUD.showAdded(to: getAppWindow(), animated: true)
        hud.mode = .text
        hud.margin = 10.0
        hud.label.text = text
        if !isKeyboardVisible() {
            hud.offset = CGPoint(x: 0.0, y: 0.0)
        }else{
            hud.offset = CGPoint(x: 0.0, y: -100)
        }
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: HUD_DELAY)
    }
    
    func showWait(text:String){
        if (HUD != nil) {
            HUD.removeFromSuperview()
            HUD.delegate = nil
            HUD = nil
        }
        HUD = MBProgressHUD.showAdded(to: getAppWindow(), animated: true)
        HUD.delegate = self
        HUD.label.text = text
        HUD.show(animated: true)
        HUD.superview?.bringSubviewToFront(HUD)
    }
    func hideWait(){
        if HUD == nil {
            return
        }
        HUD.hide(animated: true)
    }
    
    func showComplete(text:String){
        showComplete(text: text, imageName: "37x-Checkmark.png")
    }
    
    func showFail(text:String){
        showComplete(text: text, imageName: "37x-Error.png")
    }
    
    
    
    func showProgress(text:String){
        
        bgView = UIView(frame: UIScreen.main.bounds)
        bgView.backgroundColor = UIColor(white: 0.333, alpha: 0.8)
        getAppWindow().addSubview(bgView)
        
        porgressView = UIProgressView()
        porgressView.progress = 0
        porgressView.frame = CGRect(x: UIScreen.main.bounds.width/2 - 120, y: UIScreen.main.bounds.height/2, width: 240 , height: 15)
        porgressView.progressViewStyle = .default
        porgressView.progressTintColor = .red
        porgressView.backgroundColor = .white
        bgView.addSubview(porgressView)
        
        porgressLabel = UILabel(frame: CGRect(x: porgressView.frame.origin.x, y: porgressView.frame.origin.y - 30, width: 240, height: 21))
        porgressLabel.backgroundColor = UIColor.clear
        porgressLabel.textColor = .black
        porgressLabel.textAlignment = .center
        porgressLabel.text = text
        bgView.addSubview(porgressLabel)
        bgView.superview?.bringSubviewToFront(bgView)
    }
    
    func updateProgress(num:Float,text:String) {
        if bgView != nil {
            porgressLabel.text = text
            porgressView.setProgress(num, animated: true)
        }
    }
    func hideProgress() {
        bgView.removeFromSuperview()
        bgView = nil
        porgressLabel = nil
        porgressView = nil
    }
    
    func hudWasHidden(_ hud: MBProgressHUD) {
        HUD.removeFromSuperview()
        HUD.delegate = nil
        HUD = nil
    }
    
    func showHUDAddedToView(view:UIView,animated:Bool) {
        MBProgressHUD.showAdded(to: view, animated: animated)
    }
    
    func hideHUDAddedToView(view:UIView,animated:Bool) {
        MBProgressHUD.hide(for: view, animated: animated)
    }
    
    func showAnimated(animated:Bool) {
        MBProgressHUD().show(animated: animated)
    }
    
    func hideAnimated(animated:Bool) {
        MBProgressHUD().hide(animated: animated)
    }
    
    func hideAnimatedAfterDelay(animated:Bool,delay:TimeInterval) {
        MBProgressHUD().hide(animated: animated, afterDelay: delay)
    }
}



extension UIWindow {
    
    func findFirstResponse() -> UIView? {
        return findFirstResponderInView(topView: self)
    }
    
    func findFirstResponderInView(topView:UIView) -> UIView? {
        if topView.isFirstResponder {
            return topView
        }
        
        for subView in topView.subviews {
            if subView.isFirstResponder {
                return subView
            }
            let firstResponderCheckView = findFirstResponderInView(topView: subView)
            if firstResponderCheckView != nil{
                return firstResponderCheckView
            }
        }
        return nil
    }
    
}
