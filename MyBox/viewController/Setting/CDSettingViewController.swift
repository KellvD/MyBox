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
    private var tableview:UITableView! = UITableView()
    
    override func viewWillAppear(_ animated: Bool) {
        let waterPath = IndexPath(row: 0, section: 1)
        let logPath = IndexPath(row: 0, section: 2)
        self.tableview.reloadRows(at: [waterPath,logPath], with: .none)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置"
        self.tableview = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableview.separatorStyle = .none
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")
        self.view.addSubview(tableview)

    }

    lazy var optionArr: [[String]] = {
        let arr = [["修改密码","Touch ID","访客模式"],["水印模式"],["日志模式"]]
        return arr
    }()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.optionArr.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.optionArr[section].count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = BaseBackGroundColor
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = BaseBackGroundColor
        return view
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cellId = "SwitchCell"
        var cell:SwitchCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as? SwitchCell
        if cell == nil {
            cell = SwitchCell(style: .value1, reuseIdentifier: cellId)
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                cell.swi.isOn = CDSignalTon.shared.touchIDSwitch
            } else {
                cell.swi.isOn = CDSignalTon.shared.fakeSwitch
            }
        } else if indexPath.section == 1{
            cell.swi.isOn = CDSignalTon.shared.waterBean.isOn
        } else if indexPath.section == 2{
            cell.swi.isOn = CDSignalTon.shared.logbBean.isOn
        }
        cell.swiBlock = {(swi) in
            if indexPath.section == 0 {
                if indexPath.row == 1 {
                    self.onTouchIDSwitchClick(swi: swi)
                } else {
                    self.onFakeSwitchClick(swi: swi)
                }
            } else if indexPath.section == 1{
                self.onWaterSwitchClick(swi: swi)
            } else if indexPath.section == 2{
               self.onLogSwiSwitchClick(swi: swi)
            }
        }
        cell?.textLabel?.text = optionArr[indexPath.section][indexPath.row]
        cell.swi.isHidden = indexPath.section == 0 && indexPath.row == 0
        cell.accessoryType = indexPath.section == 0 && indexPath.row == 0 ? .disclosureIndicator : .none
        cell.line.isHidden = indexPath.section == optionArr.count - 1 && indexPath.row == optionArr[indexPath.section].count - 1
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let setPwdVC = CDSetPwdViewController()
                setPwdVC.isFake = false
                setPwdVC.isModify = !CDSignalTon.shared.basePwd.isEmpty
                setPwdVC.title = CDSignalTon.shared.basePwd.isEmpty ? "设置密码" : "修改密码"
                self.navigationController?.pushViewController(setPwdVC, animated: true)
            }else if indexPath.row == 2 {
                if CDSignalTon.shared.fakeSwitch {
                    let fakePwd = CDSqlManager.shared.queryUserFakeKeyWithUserId(userId: CDUserId())
                    let setPwdVC = CDSetPwdViewController()
                    setPwdVC.isFake = true
                    setPwdVC.isModify = !fakePwd.isEmpty
                    setPwdVC.title = fakePwd.isEmpty ? "设置访客密码" : "修改访客密码"
                    self.navigationController?.pushViewController(setPwdVC, animated: true)
                    
                }
            }
        } else if indexPath.section == 1 {
            if CDSignalTon.shared.waterBean.isOn {
                let water = CDMarkFileViewController()
                water.hidesBottomBarWhenPushed = true
                water.title = "水印配置"
                water.maxTextCount = 12
                water.markInfo = CDSignalTon.shared.waterBean.text
                water.markType = .waterInfo
                self.navigationController?.pushViewController(water, animated: true)
            }
        } else if indexPath.section == 2 {
            if CDSignalTon.shared.logbBean.isOn {
                let logVC = CDLogConfigViewController()
                logVC.hidesBottomBarWhenPushed = true
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
                } else {
                    print(error?.localizedDescription ?? "")
                    CDHUDManager.shared.showText(text: "您的设备没有开启指纹或者您的设备不支持指纹功能")
                    CDSignalTon.shared.touchIDSwitch = false
                }
            }
            
        }else{
            CDConfigFile.setBoolValueToConfigWith(key: .touchIdSwi, boolValue: false)
            CDSignalTon.shared.touchIDSwitch = false
        }

    }

    private func onFakeSwitchClick(swi:UISwitch){

        if swi.isOn {
            CDConfigFile.setBoolValueToConfigWith(key: .fakeSwi, boolValue: true)
            CDSignalTon.shared.fakeSwitch = true
        }else{

            let alert = UIAlertController(title: nil, message: "关闭访客模式", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (param:UIAlertAction) in
               swi.isOn = true
            }))
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (param:UIAlertAction) in
                CDSqlManager.shared.updateUserFakePwdWith(pwd: "")
                CDSignalTon.shared.fakeSwitch = false
                CDConfigFile.setBoolValueToConfigWith(key: .fakeSwi, boolValue: false)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    private func onWaterSwitchClick(swi:UISwitch){

        if swi.isOn {
            let water = CDMarkFileViewController()
            water.hidesBottomBarWhenPushed = true
            water.title = "水印配置"
            water.maxTextCount = 12
            water.markInfo = CDSignalTon.shared.waterBean.text
            water.markType = .waterInfo
            self.navigationController?.pushViewController(water, animated: true)
            
        }else{

            let alert = UIAlertController(title: nil, message: "确定关闭水印？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (param:UIAlertAction) in
                swi.isOn = true
            }))
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (param:UIAlertAction) in
                let myDelegate = UIApplication.shared.delegate as! CDAppDelegate
                CDSignalTon.shared.removeWaterMarkFromWindow(window: myDelegate.window!)
                
                CDWaterBean.setWaterConfig(isOn: false, text: getAppName())
                CDSignalTon.shared.waterBean = CDWaterBean()
                let waterPath = IndexPath(row: 0, section: 1)
                self.tableview.reloadRows(at: [waterPath], with: .none)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    private func onLogSwiSwitchClick(swi:UISwitch){

        if swi.isOn {
            let logVC = CDLogConfigViewController()
            logVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(logVC, animated: true)
            
        }else{

            let alert = UIAlertController(title: nil, message: "确定关闭日志？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (param:UIAlertAction) in
                swi.isOn = true
            }))
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (param:UIAlertAction) in
                CDLogBean.setLogConfig(isOn: false, logLevel: .Debug, logName: "log \(timestampTurnString(timestamp: getCurrentTimestamp()))", logPath: String.documentPath())
                CDSignalTon.shared.logbBean = CDLogBean()
                let logPath = IndexPath(row: 0, section: 2)
                self.tableview.reloadRows(at: [logPath], with: .none)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func showTouchId(block:@escaping(Bool,Error?)->Void) {
        let lol = LAContext()
        var error:NSError? = nil
        if lol.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            lol.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "解锁") { (success, error) in
                block(success,error)
            }
        } else {
             block(false,error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

typealias SwitchBlock = (_ swi:UISwitch) -> Void
class SwitchCell: UITableViewCell {
    var swi:UISwitch!
    var titleLabel:UILabel!
    var line:UIView!
    var swiBlock:SwitchBlock!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let view = UIView()
        self.selectedBackgroundView = view
        self.selectedBackgroundView?.backgroundColor = LightBlueColor
        
        titleLabel = UILabel(frame:CGRect(x: 15, y: 9, width: 100, height: 30))
        titleLabel.textColor = TextBlackColor
        titleLabel.font = TextMidFont
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.textAlignment = .left
        self.contentView.addSubview(titleLabel)
        
        swi = UISwitch(frame: CGRect(x: CDSCREEN_WIDTH-65, y: 9, width: 50, height: 30))
        swi.addTarget(self, action: #selector(onSwitchClick(swi:)), for: .valueChanged)

        self.contentView.addSubview(swi)
        
        line = UIView(frame: CGRect(x: 15, y: 47, width: CDSCREEN_WIDTH-30, height: 1))
        line.backgroundColor = SeparatorGrayColor
        self.contentView.addSubview(line)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func onSwitchClick(swi:UISwitch){
        swiBlock(swi)
    }
}
