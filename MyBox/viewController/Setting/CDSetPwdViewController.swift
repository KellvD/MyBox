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

    var pwdTextFiled:UITextField!
    var confirmPwdTextFiled:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isFake {
            self.title = "设置访客密码"
        }else{
            self.title = "设置密码"
        }
        self.view.backgroundColor = SeparatorGrayColor
        self.pwdTextFiled = UITextField(frame: CGRect(x: 0, y: 20, width: CDSCREEN_WIDTH, height: 48))
        self.pwdTextFiled.backgroundColor = UIColor.white
        self.pwdTextFiled.contentVerticalAlignment = .center
        self.pwdTextFiled.isSecureTextEntry = true
        self.pwdTextFiled.placeholder = "请输入密码"
        self.view.addSubview(self.pwdTextFiled)

        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
        self.pwdTextFiled.leftView = leftView
        self.pwdTextFiled.leftViewMode = .always

        self.confirmPwdTextFiled = UITextField(frame: CGRect(x: 0, y: self.pwdTextFiled.frame.maxY+1, width: CDSCREEN_WIDTH, height: 48))
        self.confirmPwdTextFiled.backgroundColor = UIColor.white
        self.confirmPwdTextFiled.isSecureTextEntry = true
        self.confirmPwdTextFiled.placeholder = "请再次输入的密码"
        self.view.addSubview(self.confirmPwdTextFiled)
        let leftViewq = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
        self.confirmPwdTextFiled.leftView = leftViewq;
        self.confirmPwdTextFiled.leftViewMode = .always

        let bottomView = UIView(frame: CGRect(x: 0, y: self.confirmPwdTextFiled.frame.maxY+20, width: CDSCREEN_WIDTH, height: CDViewHeight - self.confirmPwdTextFiled.frame.maxY-20))
        bottomView.backgroundColor = UIColor.white
        self.view.addSubview(bottomView);

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

        let pwdStr = self.pwdTextFiled.text!
        let confirmPwdStr = self.confirmPwdTextFiled.text

        if JudgeStringIsEmpty(string: pwdStr){
            CDHUD.showText(text: "密码不能为空")
            return
        }else if pwdStr.count<6 || pwdStr.count>16{
            CDHUD.showText(text: "密码长度，6-16位")
            return
        }else if pwdStr != confirmPwdStr{
            CDHUD.showText(text: "两次密码不一致,请重新输入")
            return
        }
        let md5Pwd = pwdStr.twoMd5()

        if !isFake {
            CDSignalTon.shareInstance().basePwd = md5Pwd
            CDConfigFile.setOjectToConfigWith(key: CD_IsLogin, value: "YES")
            CDSqlManager.instance().updateUserFakePwdWith(pwd: md5Pwd)
        }else{
            CDSqlManager.instance().updateUserFakePwdWith(pwd: md5Pwd)
        }
        CDHUD.showText(text: "密码设置成功")
        self.navigationController?.popViewController(animated: true)
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
