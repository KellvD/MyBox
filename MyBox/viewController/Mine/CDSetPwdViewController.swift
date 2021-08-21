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
            oldPwdTextFiled.placeholder = LocalizedString("Input the old password")
            view.addSubview(oldPwdTextFiled)
            oldPwdTextFiled.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
            oldPwdTextFiled.leftViewMode = .always
            _Y = oldPwdTextFiled.frame.maxY + 1
        }

        newPwdTextFiled = UITextField(frame: CGRect(x: 0, y: _Y, width: CDSCREEN_WIDTH, height: 48))
        newPwdTextFiled.backgroundColor = UIColor.white
        newPwdTextFiled.contentVerticalAlignment = .center
        newPwdTextFiled.isSecureTextEntry = true
        newPwdTextFiled.placeholder = LocalizedString("Input a new password, 6-12 digits and characters")
        view.addSubview(newPwdTextFiled)
        newPwdTextFiled.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
        newPwdTextFiled.leftViewMode = .always
        
        confirmPwdTextFiled = UITextField(frame: CGRect(x: 0, y: newPwdTextFiled.frame.maxY+1, width: CDSCREEN_WIDTH, height: 48))
        confirmPwdTextFiled.backgroundColor = UIColor.white
        confirmPwdTextFiled.isSecureTextEntry = true
        confirmPwdTextFiled.placeholder = LocalizedString("Input the password again")
        view.addSubview(confirmPwdTextFiled)
        confirmPwdTextFiled.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
        confirmPwdTextFiled.leftViewMode = .always
        

        let bottomView = UIView(frame: CGRect(x: 0, y: confirmPwdTextFiled.frame.maxY+20, width: CDSCREEN_WIDTH, height: CDViewHeight - confirmPwdTextFiled.frame.maxY-20))
        bottomView.backgroundColor = UIColor.white
        view.addSubview(bottomView);

        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 15, y: 50, width: CDSCREEN_WIDTH-30, height: 48)
        button.setBackgroundImage(UIImage(named: "上导航栏-背景"), for: .normal)
        button.layer.cornerRadius = 4.0
        button.clipsToBounds = true
        button.setTitle(LocalizedString("sure"), for: .normal)
        button.addTarget(self, action: #selector(onLoadPassWordClick), for: .touchUpInside)
        bottomView.addSubview(button)
        
        
        let tipLabel = UILabel(frame: CGRect(x: 15.0, y: bottomView.height - 15.0 - 80.0, width: bottomView.width - 15.0 * 2, height: 80.0))
        tipLabel.textColor = .baseBgColor
        tipLabel.numberOfLines = 0
        tipLabel.font = TextSmallFont
        tipLabel.text = isFake ? LocalizedString("Guest password can restrict third parties to view allowed file information. You can set whether to allow changed files to be viewed by third parties in file details and folder details."):LocalizedString("Set a password to protect your private files. You need to enter a password when logging in to prevent third parties from opening this application and viewing your data files.")
        bottomView.addSubview(tipLabel)
    }

    @objc func onLoadPassWordClick() ->Void {

        let oldStr = oldPwdTextFiled?.text ?? ""
        let pwdStr = newPwdTextFiled.text!
        let confirmPwdStr = confirmPwdTextFiled.text

        if isModify && oldStr.isEmpty{
            CDHUDManager.shared.showText(LocalizedString("Please enter the original password"))
        }else if pwdStr.isEmpty{
            CDHUDManager.shared.showText(LocalizedString("Please enter a new password"))
            return
        }else if pwdStr.count<6 || pwdStr.count>12{
            CDHUDManager.shared.showText(LocalizedString("The password length does not match, 6-12 digits!"))
            return
        }else if pwdStr != confirmPwdStr{
            CDHUDManager.shared.showText(LocalizedString("The two passwords are inconsistent, please reenter"))
            return
        }

        if isModify {
            if isFake {
                //数据库验证原始密码是否正确
                let fakePwd = CDSqlManager.shared.queryUserFakeKeyWithUserId(userId: CDUserId())
                if fakePwd != oldStr.md5 {
                    //验证错误，重新输入
                    CDHUDManager.shared.showText(LocalizedString("The original guest password is wrong, please reenter"))
                    return
                }
                //验证通过，保存
                CDSqlManager.shared.updateUserFakePwdWith(pwd: oldStr.md5)
            }else{
                let realPwd = CDSqlManager.shared.queryUserRealKeyWithUserId(userId: CDUserId())
                if realPwd != pwdStr.md5 {
                    CDHUDManager.shared.showText(LocalizedString("The original guest password is wrong, please reenter"))
                    return
                }
                CDSqlManager.shared.updateUserRealPwdWith(pwd: pwdStr.md5)
            }
            CDHUDManager.shared.showComplete(LocalizedString("Password reset complete"))
            CDPrintManager.log("密码修改成功", type: .InfoLog)
        }else{
            if !isFake {
                CDSignalTon.shared.basePwd = pwdStr.md5
                CDSqlManager.shared.updateUserRealPwdWith(pwd: pwdStr.md5)
                CDSignalTon.shared.loginType = .real
                CDPrintManager.log("超级密码设置成功", type: .InfoLog)
            }else{
                CDSqlManager.shared.updateUserFakePwdWith(pwd: pwdStr.md5)
                CDPrintManager.log("访客密码设置成功", type: .InfoLog)
            }
            CDHUDManager.shared.showComplete(LocalizedString("Password set complete"))
            CDConfigFile.setIntValueToConfigWith(key: .initPwd, intValue: HasInitPwd)
            
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
