//
//  CDPrivacyViewController.swift
//  MyBox
//
//  Created by changdong on 2020/11/12.
//  Copyright © 2020 changdong. All rights reserved.
//

import UIKit
import LocalAuthentication
enum CDPrivatyAndLogOption:String {
    case ChangePwd = "修改密码"
    case TouchID = "Touch ID"
    case FakeSet = "访客模式"
    case LogSet  = "日志设置"
    case LogPreview = "日志预览"
}
class CDOptionViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {
    
    public var optionArr: [CDPrivatyAndLogOption]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if optionArr.contains(.LogSet) {
            self.tableView.reloadData()
        }
    }
    lazy var tableView: UITableView = {
        let tableV = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .plain)
        tableV.separatorStyle = .none
        tableV.delegate = self
        tableV.dataSource = self
        tableV.isScrollEnabled = false
        tableV.register(CDSwitchCell.self, forCellReuseIdentifier: "optionSwitchCell")
        tableV.translatesAutoresizingMaskIntoConstraints = false
        return tableV
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.optionArr.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cellId = "optionSwitchCell"
        var cell:CDSwitchCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as? CDSwitchCell
        if cell == nil {
            cell = CDSwitchCell(style: .default, reuseIdentifier: cellId)
        }
        let option = optionArr[indexPath.row]
        cell.titleLabel.text = option.rawValue      
        cell.swi.isHidden = (option == .ChangePwd || option == .LogPreview)
        cell.accessoryType = (option == .ChangePwd || option == .LogPreview) ? .disclosureIndicator : .none

        if option == .TouchID {
            cell.swi.isOn = CDSignalTon.shared.touchIDSwitch
            cell.swiBlock = {(swi) in
                self.onTouchIDSwitchClick(swi: swi)
            }
        }else if option == .FakeSet{
            cell.swi.isOn = CDSignalTon.shared.fakeSwitch
            cell.swiBlock = {(swi) in
                self.onFakeSwitchClick(swi: swi)
            }
        }else if option == .LogSet{
            cell.swi.isOn = CDLogBean.isOn
            cell.swiBlock = {(swi) in
                self.onLogSwiSwitchClick(swi: swi)
            }
        }
        
        cell.separatorLineIsHidden = indexPath.row == optionArr.count - 1

    
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = optionArr[indexPath.row]
        if option == .ChangePwd {
            let setPwdVC = CDSetPwdViewController()
            setPwdVC.isFake = false
            setPwdVC.isModify = !CDSignalTon.shared.basePwd.isEmpty
            setPwdVC.title = CDSignalTon.shared.basePwd.isEmpty ? "设置密码".localize : "修改密码".localize
            self.navigationController?.pushViewController(setPwdVC, animated: true)
        }else if option == .FakeSet {
            if CDSignalTon.shared.fakeSwitch {
                let fakePwd = CDSqlManager.shared.queryUserFakeKeyWithUserId(userId: CDUserId())
                let setPwdVC = CDSetPwdViewController()
                setPwdVC.isFake = true
                setPwdVC.isModify = !fakePwd.isEmpty
                setPwdVC.title = fakePwd.isEmpty ? "设置访客密码".localize : "修改访客密码".localize
                self.navigationController?.pushViewController(setPwdVC, animated: true)
                
            }
        }else if option == .LogSet || option == .LogPreview {
            if CDLogBean.isOn {
                let logVC = CDLogViewController()
                logVC.isSet = option == .LogSet
                self.navigationController?.pushViewController(logVC, animated: true)
                
            }
        }
    }
    //响应
    private func onTouchIDSwitchClick(swi:UISwitch){

        if swi.isOn {
            showTouchId { (success, error) in
                if success{
                    CDConfigFile.setBoolValueToConfigWith(key: .touchIdSwi, boolValue: true)
                    CDSignalTon.shared.touchIDSwitch = true
                    CDPrintManager.log("指纹密码打开", type: .InfoLog)
                } else {
                    DispatchQueue.main.async {
                        CDHUDManager.shared.showText("您的设备没有开启指纹或者您的设备不支持指纹功能".localize)
                        CDSignalTon.shared.touchIDSwitch = false
                    }
                    
                }
            }
            
        }else{
            CDConfigFile.setBoolValueToConfigWith(key: .touchIdSwi, boolValue: false)
            CDSignalTon.shared.touchIDSwitch = false
            CDPrintManager.log("指纹密码关闭", type: .InfoLog)
        }

    }

    private func onFakeSwitchClick(swi:UISwitch){

        if swi.isOn {
            CDConfigFile.setBoolValueToConfigWith(key: .fakeSwi, boolValue: true)
            CDSignalTon.shared.fakeSwitch = true
            CDPrintManager.log("访客模式打开", type: .InfoLog)
        }else{

            let alert = UIAlertController(title: nil, message: "关闭访客模式".localize, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: { (param:UIAlertAction) in
               swi.isOn = true
            }))
            alert.addAction(UIAlertAction(title: "确定".localize, style: .default, handler: { (param:UIAlertAction) in
                CDSqlManager.shared.updateUserFakePwdWith(pwd: "")
                CDSignalTon.shared.fakeSwitch = false
                CDConfigFile.setBoolValueToConfigWith(key: .fakeSwi, boolValue: false)
                CDPrintManager.log("访客模式关闭", type: .InfoLog)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showTouchId(block:@escaping(Bool,Error?)->Void) {
        let lol = LAContext()
        var error:NSError? = nil
        if lol.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            lol.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "解锁".localize) { (success, error) in
                block(success,error)
            }
        } else {
             block(false,error)
        }
    }
    
    private func onLogSwiSwitchClick(swi:UISwitch){

        if swi.isOn {
            let logVC = CDLogViewController()
            logVC.isSet = true
            self.navigationController?.pushViewController(logVC, animated: true)
        }else{

            let alert = UIAlertController(title: nil, message: "确定关闭日志？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消".localize, style: .cancel, handler: { (param:UIAlertAction) in
                swi.isOn = true
            }))
            alert.addAction(UIAlertAction(title: "确定".localize, style: .default, handler: { (param:UIAlertAction) in
                CDLogBean.closeLogConfig()
                self.tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .none)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func onSwitchClick(swi:UISwitch){
        self.onLogSwiSwitchClick(swi: swi)
    }
}
