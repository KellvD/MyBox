//
//  CDSetPwdViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/3.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
class CDSetPwdViewController: CDBaseAllViewController {
    var isFake:Bool = false
    var isModify:Bool = false
    
    private var oldPwdTextFiled:UITextField!
    private var newPwdTextFiled:UITextField!
    private var confirmPwdTextFiled:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        var _Y:CGFloat = 20
        if isModify {
            oldPwdTextFiled = UITextField(frame: CGRect(x: 0, y: _Y, width: CDSCREEN_WIDTH, height: 48))
            oldPwdTextFiled.backgroundColor = UIColor.white
            oldPwdTextFiled.contentVerticalAlignment = .center
            oldPwdTextFiled.isSecureTextEntry = true
            oldPwdTextFiled.placeholder = "请输入旧密码"
            view.addSubview(oldPwdTextFiled)
            oldPwdTextFiled.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
            oldPwdTextFiled.leftViewMode = .always
            _Y = oldPwdTextFiled.frame.maxY + 1
        }

        view.backgroundColor = SeparatorGrayColor
        newPwdTextFiled = UITextField(frame: CGRect(x: 0, y: _Y, width: CDSCREEN_WIDTH, height: 48))
        newPwdTextFiled.backgroundColor = UIColor.white
        newPwdTextFiled.contentVerticalAlignment = .center
        newPwdTextFiled.isSecureTextEntry = true
        newPwdTextFiled.placeholder = "请输入密码，6-12位数字字符"
        view.addSubview(newPwdTextFiled)
        newPwdTextFiled.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
        newPwdTextFiled.leftViewMode = .always
        
        confirmPwdTextFiled = UITextField(frame: CGRect(x: 0, y: newPwdTextFiled.frame.maxY+1, width: CDSCREEN_WIDTH, height: 48))
        confirmPwdTextFiled.backgroundColor = UIColor.white
        confirmPwdTextFiled.isSecureTextEntry = true
        confirmPwdTextFiled.placeholder = "请再次输入的密码"
        view.addSubview(confirmPwdTextFiled)
        confirmPwdTextFiled.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
        confirmPwdTextFiled.leftViewMode = .always
        

        let bottomView = UIView(frame: CGRect(x: 0, y: confirmPwdTextFiled.frame.maxY+20, width: CDSCREEN_WIDTH, height: CDViewHeight - confirmPwdTextFiled.frame.maxY-20))
        bottomView.backgroundColor = UIColor.white
        view.addSubview(bottomView);

        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 30, y: 50, width: CDSCREEN_WIDTH-60, height: 48)
        button.setBackgroundImage(UIImage(named: "上导航栏-背景"), for: .normal)
        button.layer.cornerRadius = 4.0
        button.clipsToBounds = true
        button.setTitle("确定", for: .normal)
        button.addTarget(self, action: #selector(onLoadPassWordClick), for: .touchUpInside)
        bottomView.addSubview(button)
    }

    @objc func onLoadPassWordClick() ->Void {

        let oldStr = oldPwdTextFiled?.text ?? ""
        let pwdStr = newPwdTextFiled.text!
        let confirmPwdStr = confirmPwdTextFiled.text

        if isModify && JudgeStringIsEmpty(string: oldStr){
            CDHUDManager.shared.showText(text: "请输入原始密码")
        }else if JudgeStringIsEmpty(string: pwdStr){
            CDHUDManager.shared.showText(text: "请输入新密码")
            return
        }else if pwdStr.count<6 || pwdStr.count>12{
            CDHUDManager.shared.showText(text: "密码长度不符，6-12位!")
            return
        }else if pwdStr != confirmPwdStr{
            CDHUDManager.shared.showText(text: "两次密码不一致,请重新输入")
            return
        }

        if isModify {
            if isFake {
                //数据库验证原始密码是否正确
                let fakePwd = CDSqlManager.instance().queryUserFakeKeyWithUserId(userId: CDUserId())
                if fakePwd != oldStr.md5 {
                    //验证错误，重新输入
                    CDHUDManager.shared.showText(text: "原始访客密码错误，请重新输入")
                    return
                }
                //验证通过，保存
                CDSqlManager.instance().updateUserFakePwdWith(pwd: oldStr.md5)
            }else{
                let realPwd = CDSqlManager.instance().queryUserRealKeyWithUserId(userId: CDUserId())
                if realPwd != pwdStr.md5 {
                    CDHUDManager.shared.showText(text: "原始密码错误，请重新输入")
                    return
                }
                CDSqlManager.instance().updateUserRealPwdWith(pwd: pwdStr.md5)
            }
            CDHUDManager.shared.showText(text: "密码修改成功")
            
        }else{
            if !isFake {
                CDSignalTon.shared.basePwd = pwdStr.md5
                CDSqlManager.instance().updateUserRealPwdWith(pwd: pwdStr.md5)
                CDSignalTon.shared.loginType = .real
//                CDConfigFile.setOjectToConfigWith(key: CD_IsLogin, value: "YES")
//                let ff = CDConfigFile.getValueFromConfigWith(key: CD_IsLogin)
            }else{
                CDSqlManager.instance().updateUserFakePwdWith(pwd: pwdStr.md5)
            }
            CDHUDManager.shared.showText(text: "密码设置成功")
        }
        navigationController?.popViewController(animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
