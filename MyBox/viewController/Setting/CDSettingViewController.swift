//
//  CDSettingViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/3.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import LocalAuthentication
class CDSettingViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {
    var touchIdSwi:UISwitch! = UISwitch()
    var fakeSwi:UISwitch! = UISwitch()
    var gestureSwi:UISwitch! = UISwitch()
    var tableview:UITableView! = UITableView()
    var logSwi:UISwitch! = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableview = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .plain)
        tableview.separatorStyle = .none
        tableview.delegate = self
        tableview.dataSource = self
        self.view.addSubview(tableview)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            let cellID = "Touch ID"
            var cell = tableview.dequeueReusableCell(withIdentifier: cellID)
            if (cell == nil) {
                cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
                let view = UIView()
                cell?.selectedBackgroundView = view
                cell?.selectionStyle = .none
                cell?.textLabel?.text = "Touch ID"
                cell?.textLabel?.font = TextMidFont
                cell?.textLabel?.textColor = TextBlackColor

                self.touchIdSwi = UISwitch(frame: CGRect(x: CDSCREEN_WIDTH-65, y: 9, width: 50, height: 30))
                self.touchIdSwi.addTarget(self, action: #selector(onTouchIDSwitchClick(swi:)), for: .valueChanged)
                cell?.contentView.addSubview(touchIdSwi)

                let separatorLine = UIView(frame: CGRect(x: 15, y: 47, width: CDSCREEN_WIDTH-30, height: 1))
                separatorLine.backgroundColor = SeparatorGrayColor
                cell?.contentView.addSubview(separatorLine)
            }
            touchIdSwi.isOn = CDSignalTon.shareInstance().touchIDSwitch;
            return cell!
        }else if indexPath.row == 2 {
            let cellID = "fake Switch"
            var cell = tableview.dequeueReusableCell(withIdentifier: cellID)
            if (cell == nil) {
                cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
                let view = UIView()
                cell?.selectedBackgroundView = view
                cell?.selectionStyle = .none
                cell?.textLabel?.text = "访客模式"
                cell?.textLabel?.font = TextMidFont
                cell?.textLabel?.textColor = TextBlackColor

                self.fakeSwi = UISwitch(frame: CGRect(x: CDSCREEN_WIDTH-65, y: 9, width: 50, height: 30))
                self.fakeSwi.addTarget(self, action: #selector(onFakeSwitchClick(swi:)), for: .valueChanged)
                cell?.contentView.addSubview(fakeSwi)

                let separatorLine = UIView(frame: CGRect(x: 15, y: 47, width: CDSCREEN_WIDTH-30, height: 1))
                separatorLine.backgroundColor = SeparatorGrayColor
                cell?.contentView.addSubview(separatorLine)

            }


            touchIdSwi?.isOn = CDSignalTon.shareInstance().touchIDSwitch;

            return cell!
        }else{
            let cellID = "Other row"
            var cell = tableview?.dequeueReusableCell(withIdentifier: cellID)
            if (cell == nil) {
                cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
                let view = UIView()
                cell?.selectedBackgroundView = view
                cell?.selectionStyle = .none
                cell?.textLabel?.font = TextMidFont
                cell?.textLabel?.textColor = TextBlackColor
                let separatorLine = UIView(frame: CGRect(x: 15, y: 47, width: CDSCREEN_WIDTH-30, height: 1))
                separatorLine.backgroundColor = SeparatorGrayColor
                cell?.contentView.addSubview(separatorLine)
            }
            if indexPath.row == 0 {
                cell?.textLabel?.text = "修改密码"
            }else if indexPath.row == 3 {
                cell?.textLabel?.text = "访客密码"
                if fakeSwi.isOn {
                    cell?.textLabel?.textColor = TextLightBlackColor
                    cell?.accessoryView?.isHidden = true
                }else{
                    cell?.textLabel?.textColor = TextBlackColor
                    cell?.accessoryView?.isHidden = false
                }
            }
            return cell!
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let modifyPwdVC = CDModifyPwdViewController()
            self.navigationController?.pushViewController(modifyPwdVC, animated: true)
        }else if indexPath.row == 4 {
            let setPwdVC = CDSetPwdViewController()
            setPwdVC.isFake = true
            self.navigationController?.pushViewController(setPwdVC, animated: true)
        }
    }



    //响应
    @objc func onTouchIDSwitchClick(swi:UISwitch){

        if swi.isOn {
            if #available(iOS 8.0, *) {
                let ctx = LAContext()
                if ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){

                    CDConfigFile.setBoolValueToConfigWith(key: CD_TouchId, boolValue: true)
                    CDSignalTon.instance.fakeSwitch = true
                }else{
                    print("您的设备没有开启指纹或者您的设备不支持指纹功能")
                    CDSignalTon.instance.touchIDSwitch = false
                }

            }else{
                CDHUDManager.shareInstance().showText(text: "iOS8以上的系统才支持指纹解锁")
                let indexPath = IndexPath(row: 1, section: 0)
                let indexArr:[IndexPath] = [indexPath]
                tableview.reloadRows(at: indexArr, with: .none)

            }

        }else{
            CDConfigFile.setBoolValueToConfigWith(key: CD_TouchId, boolValue: false)
            CDSignalTon.instance.touchIDSwitch = false
        }

    }

    @objc func onFakeSwitchClick(swi:UISwitch){

        if swi.isOn {
            CDConfigFile.setBoolValueToConfigWith(key: CD_FakeType, boolValue: true)
            CDSignalTon.instance.fakeSwitch = false
            let fakePwdPath = IndexPath(row: 4, section: 0)
            let fakeGpPath = IndexPath(row: 5, section: 0)
            let indexArr:[IndexPath] = [fakePwdPath,fakeGpPath]
            tableview.reloadRows(at: indexArr, with: .none)
        }else{

            let alert = UIAlertController(title: nil, message: "关闭访客模式", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (param:UIAlertAction) in
                self.fakeSwi.isOn = true
            }))
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (param:UIAlertAction) in

                CDSqlManager.instance().updateUserFakePwdWith(pwd: "")
                self.fakeSwi.isOn = false
                CDSignalTon.instance.fakeSwitch = false
                CDConfigFile.setBoolValueToConfigWith(key: CD_FakeType, boolValue: false)
                let fakePwdPath = IndexPath(row: 4, section: 0)
                let indexArr:[IndexPath] = [fakePwdPath]
                self.tableview.reloadRows(at: indexArr, with: .none)

            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
