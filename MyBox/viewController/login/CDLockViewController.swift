//
//  CDLockViewController.swift
//  MyRule
//
//  Created by changdong on 2018/11/12.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import CoreGraphics
import LocalAuthentication

class CDLockViewController:CDBaseAllViewController {
    var pwdTextFiled:UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        super.isShowBackBtn = false

        //头像
        let headImageView = UIImageView(frame: CGRect(x: (CDSCREEN_WIDTH-100)/2, y: 100, width: 100, height: 100))
        headImageView.image = LoadImageByName(imageName: "icon", type: "jpg")
        self.view.addSubview(headImageView);

        let leftLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 48))
        leftLabel.text = "密码  "
        leftLabel.textAlignment = .left

        //输入框
        self.pwdTextFiled = UITextField(frame: CGRect(x: 30, y:headImageView.frame.maxY+30, width: CDSCREEN_WIDTH-60, height: 48))
        self.pwdTextFiled.isSecureTextEntry = true;
        self.pwdTextFiled.placeholder = "请输入密码"
        self.pwdTextFiled.leftView = leftLabel
        self.pwdTextFiled.leftViewMode = .always
        self.view.addSubview(self.pwdTextFiled)

        let sparateLine = UIView(frame: CGRect(x: 30, y: (pwdTextFiled?.frame.maxY)! + 1, width: CDSCREEN_WIDTH-66, height: 1))
        sparateLine.backgroundColor = SeparatorGrayColor
        self.view.addSubview(sparateLine)

        //
        let loginBtn = UIButton(type: .custom)
        loginBtn.frame = CGRect(x: 30, y: (pwdTextFiled?.frame.maxY)!+30, width: (pwdTextFiled?.frame.width)!, height: 48.0)
        loginBtn.setTitle("登录", for: .normal)
        loginBtn.layer.cornerRadius = 4.0
        loginBtn.backgroundColor = UIColor.red
        loginBtn.addTarget(self, action: #selector(loginBtnClick), for: .touchUpInside)
        self.view.addSubview(loginBtn)
        
        
        
    }
//    func showTouchID(){
//        let lol = LAContext()
//        var error = NSError()
//        //lol 是否存在
//        if lol.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//            //开始运作
//            lol.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "解锁") { (success, err) in
//                if success {
//                    
//                } else {
//                    
//                }
//            }
//        }else{
//            
//        }
//    }
    
    @objc func loginBtnClick() -> Void {
        pwdTextFiled.resignFirstResponder()
//        let inputPwd = self.pwdTextFiled.text?.md5
//        let pwd = CDSqlManager.shared.queryUserRealKeyWithUserId(userId: CDUserId())
//
//        if JudgeStringIsEmpty(string:pwd) {
//           CDHUDManager.shared.showText(text: "请输入密码")
//            return
//        }else if inputPwd != pwd{
//            CDHUDManager.shared.showText(text: "密码输入有误")
//            return
//        }
        let settingVC = CDSafeViewController()
//        let settingVC = CDMusicViewController()

        self.navigationController?.pushViewController(settingVC, animated: true)

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pwdTextFiled?.resignFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
