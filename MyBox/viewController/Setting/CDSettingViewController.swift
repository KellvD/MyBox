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
    private var touchIdSwi:UISwitch!
    private var fakeSwi:UISwitch!
    private var waterSwi:UISwitch!
    
    private var tableview:UITableView! = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableview = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableview.separatorStyle = .none
        tableview.delegate = self
        tableview.dataSource = self
//        tableview
        self.view.addSubview(tableview)

    }

    lazy var optionArr: [[String]] = {
        let arr = [["修改密码","Touch ID","访客模式","访客密码"],["水印模式","水印信息"]]
        return arr
    }()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.optionArr.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.optionArr[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2)) ||
            (indexPath.section == 1 && indexPath.row == 0){
            let cellID = "switch_cell"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
            if (cell == nil) {
                cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
                let view = UIView()
                cell?.selectedBackgroundView = view
                cell?.selectionStyle = .none
                cell?.textLabel?.font = TextMidFont
                cell?.textLabel?.textColor = TextBlackColor
                if indexPath.section == 0 {
                    if indexPath.row == 1 {
                        self.touchIdSwi = UISwitch(frame: CGRect(x: CDSCREEN_WIDTH-65, y: 9, width: 50, height: 30))
                        self.touchIdSwi.addTarget(self, action: #selector(onTouchIDSwitchClick(swi:)), for: .valueChanged)
                        cell?.contentView.addSubview(touchIdSwi)
                    } else {
                        self.fakeSwi = UISwitch(frame: CGRect(x: CDSCREEN_WIDTH-65, y: 9, width: 50, height: 30))
                        self.fakeSwi.addTarget(self, action: #selector(onFakeSwitchClick(swi:)), for: .valueChanged)
                        cell?.contentView.addSubview(fakeSwi)
                    }
                } else if indexPath.section == 0  && indexPath.row == 0{
                    self.waterSwi = UISwitch(frame: CGRect(x: CDSCREEN_WIDTH-65, y: 9, width: 50, height: 30))
                    self.waterSwi.addTarget(self, action: #selector(onWaterSwitchClick(swi:)), for: .valueChanged)
                    cell?.contentView.addSubview(self.waterSwi)
                    
                }
                let separatorLine = UIView(frame: CGRect(x: 15, y: 47, width: CDSCREEN_WIDTH-30, height: 1))
                separatorLine.backgroundColor = SeparatorGrayColor
                cell?.contentView.addSubview(separatorLine)
            }
            cell?.textLabel?.text = optionArr[indexPath.section][indexPath.row]
            if indexPath.section == 0 {
                if indexPath.row == 1 {
                    self.touchIdSwi.isOn = CDSignalTon.shared.touchIDSwitch;
                } else {
                    self.fakeSwi.isOn = CDSignalTon.shared.fakeSwitch;
                }
            } else if indexPath.section == 0 {
                self.waterSwi.isOn = CDSignalTon.shared.waterSwitch;
            }
            return cell!
        }else{
            let cellID = "Other row"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
            if (cell == nil) {
                cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
                cell?.accessoryType = .disclosureIndicator
                let view = UIView()
                cell?.selectedBackgroundView = view
                cell?.selectionStyle = .none
                cell?.textLabel?.font = TextMidFont
                cell?.textLabel?.textColor = TextBlackColor
                
                let separatorLine = UIView(frame: CGRect(x: 15, y: 47, width: CDSCREEN_WIDTH-30, height: 1))
                separatorLine.backgroundColor = SeparatorGrayColor
                cell?.contentView.addSubview(separatorLine)
            }
            cell?.textLabel?.text = optionArr[indexPath.section][indexPath.row]
            if indexPath.section == 0 && indexPath.row == 3 {
                if fakeSwi.isOn {
                    cell?.textLabel?.textColor = TextBlackColor
                    cell?.accessoryType = .disclosureIndicator
                }else{
                    cell?.textLabel?.textColor = TextLightBlackColor
                    cell?.accessoryType = .none
                }
            } else if indexPath.section == 1 && indexPath.row == 1 {
                if waterSwi?.isOn ?? false{
                    cell?.textLabel?.textColor = TextBlackColor
                    cell?.accessoryType = .disclosureIndicator
                }else{
                    cell?.textLabel?.textColor = TextLightBlackColor
                    cell?.accessoryType = .none
                }
            }
            return cell!
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let setPwdVC = CDSetPwdViewController()
                setPwdVC.isFake = false
                setPwdVC.isModify = !JudgeStringIsEmpty(string: CDSignalTon.shared.basePwd)
                setPwdVC.title = JudgeStringIsEmpty(string: CDSignalTon.shared.basePwd) ? "设置密码" : "修改密码"
                self.navigationController?.pushViewController(setPwdVC, animated: true)
            }else if indexPath.row == 3 {
                if CDSignalTon.shared.fakeSwitch {
                    let fakePwd = CDSqlManager.instance().queryUserFakeKeyWithUserId(userId: CDUserId())
                    let setPwdVC = CDSetPwdViewController()
                    setPwdVC.isFake = true
                    setPwdVC.isModify = !JudgeStringIsEmpty(string: fakePwd)
                    setPwdVC.title = JudgeStringIsEmpty(string: fakePwd) ? "设置访客密码" : "修改访客密码"
                    self.navigationController?.pushViewController(setPwdVC, animated: true)
                    
                }
            }
        } else {
            if indexPath.row == 1 {
            
            }
        }
    }



    //响应
    @objc func onTouchIDSwitchClick(swi:UISwitch){

        if swi.isOn {
            let ctx = LAContext()
            if ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){

                CDConfigFile.setBoolValueToConfigWith(key: CD_TouchIdSwi, boolValue: true)
                CDSignalTon.shared.touchIDSwitch = true
            }else{
                CDHUDManager.shared.showText(text: "您的设备没有开启指纹或者您的设备不支持指纹功能")
                CDSignalTon.shared.touchIDSwitch = false
            }
        }else{
            CDConfigFile.setBoolValueToConfigWith(key: CD_TouchIdSwi, boolValue: false)
            CDSignalTon.shared.touchIDSwitch = false
        }

    }

    @objc func onFakeSwitchClick(swi:UISwitch){

        if swi.isOn {
            CDConfigFile.setBoolValueToConfigWith(key: CD_FakeSwi, boolValue: true)
            CDSignalTon.shared.fakeSwitch = true
            let fakePwdPath = IndexPath(row: 3, section: 0)
            let indexArr:[IndexPath] = [fakePwdPath]
            tableview.reloadRows(at: indexArr, with: .none)
        }else{

            let alert = UIAlertController(title: nil, message: "关闭访客模式", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (param:UIAlertAction) in
                self.fakeSwi.isOn = true
            }))
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (param:UIAlertAction) in

                CDSqlManager.instance().updateUserFakePwdWith(pwd: "")
                self.fakeSwi.isOn = false
                CDSignalTon.shared.fakeSwitch = false
                CDConfigFile.setBoolValueToConfigWith(key: CD_FakeSwi, boolValue: false)
                let fakePwdPath = IndexPath(row: 3, section: 0)
                let indexArr:[IndexPath] = [fakePwdPath]
                self.tableview.reloadRows(at: indexArr, with: .none)

            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func onWaterSwitchClick(swi:UISwitch){

        if swi.isOn {
            CDConfigFile.setBoolValueToConfigWith(key: CD_WaterSwi, boolValue: true)
            CDSignalTon.shared.waterSwitch = true
            let waterPath = IndexPath(row: 1, section: 1)
            tableview.reloadRows(at: [waterPath], with: .none)
            let myDelegate = UIApplication.shared.delegate as! CDAppDelegate
            CDSignalTon.shared.addWartMarkToWindow(appWindow: myDelegate.window!)
        }else{

            let alert = UIAlertController(title: nil, message: "确定关闭水印？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (param:UIAlertAction) in
                self.waterSwi.isOn = true
            }))
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (param:UIAlertAction) in
                self.waterSwi.isOn = false
                CDConfigFile.setBoolValueToConfigWith(key: CD_WaterSwi, boolValue: false)
                CDSignalTon.shared.waterSwitch = false
                let waterPath = IndexPath(row: 1, section: 1)
                self.tableview.reloadRows(at: [waterPath], with: .none)
                let myDelegate = UIApplication.shared.delegate as! CDAppDelegate
                CDSignalTon.shared.removeWaterMarkFromWindow(window: myDelegate.window!)

            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
