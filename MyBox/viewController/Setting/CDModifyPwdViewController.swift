//
//  CDModifyPwdViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/3.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDModifyPwdViewController: CDBaseAllViewController {


    var oldPwdTextFiled:UITextField!
    var newPwdTextFiled:UITextField!
    var confirmPwdTextFiled:UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改密码"
        self.view.backgroundColor = SeparatorGrayColor
        self.oldPwdTextFiled = UITextField(frame: CGRect(x: 0, y: 20, width: CDSCREEN_WIDTH, height: 48))
        self.oldPwdTextFiled.backgroundColor = UIColor.white
        self.oldPwdTextFiled.contentVerticalAlignment = .center
        self.oldPwdTextFiled.isSecureTextEntry = true
        self.oldPwdTextFiled.placeholder = "请输入旧密码"
        self.view.addSubview(self.oldPwdTextFiled)

        self.newPwdTextFiled = UITextField(frame: CGRect(x: 0, y: self.oldPwdTextFiled.frame.maxY+1, width: CDSCREEN_WIDTH, height: 48))
        self.newPwdTextFiled.backgroundColor = UIColor.white
        self.newPwdTextFiled.isSecureTextEntry = true
        self.newPwdTextFiled.placeholder = "请输入新的密码"
        self.view.addSubview(self.newPwdTextFiled)

        self.confirmPwdTextFiled = UITextField(frame: CGRect(x: 0, y: self.newPwdTextFiled.frame.maxY+1, width: CDSCREEN_WIDTH, height: 48))
        self.confirmPwdTextFiled.backgroundColor = UIColor.white
        self.confirmPwdTextFiled.isSecureTextEntry = true
        self.confirmPwdTextFiled.placeholder = "请再次输入新密码"
        self.view.addSubview(self.confirmPwdTextFiled)


        let bottomView = UIView(frame: CGRect(x: 0, y: self.confirmPwdTextFiled.frame.maxY+20, width: CDSCREEN_WIDTH, height: CDViewHeight - self.confirmPwdTextFiled.frame.maxY-20))
        bottomView.backgroundColor = UIColor.white
        self.view.addSubview(bottomView);

        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 30, y: 50, width: CDSCREEN_WIDTH-60, height: 48)
        button.setBackgroundImage(UIImage(named: "上导航栏-背景"), for: .normal)
        button.layer.cornerRadius = 4.0
        button.clipsToBounds = true
        button.setTitle("确定", for: .normal)
        button.addTarget(self, action: #selector(onLoadNewPassWordClick), for: .touchUpInside)
        bottomView.addSubview(button)




    }

    @objc func onLoadNewPassWordClick() ->Void {

        let inputOldPwd:String = self.oldPwdTextFiled.text!
        let inputNewPwd:String = self.newPwdTextFiled.text!
        let inputConfirmPwd:String = self.confirmPwdTextFiled.text!
        if JudgeStringIsEmpty(string: inputOldPwd) {
            CDHUD.showText(text: "请输入旧密码")
            return
        }else if JudgeStringIsEmpty(string: inputNewPwd){
            CDHUD.showText(text: "请输入新密码")
            return
        }else if (inputNewPwd.count < 6 || inputNewPwd.count > 12){
            CDHUD.showText(text: "密码长度不符，6-12位!")
            return
        }

        if CDSignalTon.shareInstance().CDLoginType == CDLoginReal {
            let oldPwdStr = CDSignalTon.shareInstance().basePwd
            if oldPwdStr != inputOldPwd {
                CDHUD.showText(text: "旧密码输入有误")
                return
            }
        }else{
            let oldPwdStr = CDSqlManager.instance().queryUserFakeKeyWithUserId(userId: CDUserId())
            if oldPwdStr != inputOldPwd {
                CDHUD.showText(text: "旧密码输入有误")
                return
            }

        }

        if inputOldPwd != inputConfirmPwd{
            CDHUD.showText(text: "两次密码输入不一致，请重新输入")
            return
        }

        let pwdMd5 = inputConfirmPwd.twoMd5()

        if CDSignalTon.shareInstance().CDLoginType == CDLoginReal {
            CDSqlManager.instance().updateUserRealPwdWith(pwd: pwdMd5)
            CDSignalTon.shareInstance().basePwd = pwdMd5
            CDConfigFile.setOjectToConfigWith(key: CD_IsLogin, value: "YES")
        }else{
            CDSqlManager.instance().updateUserFakePwdWith(pwd: pwdMd5)
        }
        CDHUD.showText(text: "密码修改成功！")
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
