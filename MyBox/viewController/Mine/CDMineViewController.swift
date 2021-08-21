//
//  CDMineViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/3.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

class CDMineViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {
    private var tableview:UITableView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let waterPath = IndexPath(row: 0, section: 3)
//        let darkPath = IndexPath(row: 0, section: 4)
//        tableview.reloadRows(at: [waterPath,darkPath], with: .automatic)
        tableview.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hiddBackbutton()
        tableview = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableview.separatorStyle = .none
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(CDSwitchCell.self, forCellReuseIdentifier: "MineSwitchCell")
        self.view.addSubview(tableview)

    }

    lazy var optionArr: [[String]] = {
        let arr:[[String]] = [[LocalizedString("About")],[LocalizedString("Storage")],[LocalizedString("Privacy")],[LocalizedString("Watermark")],[LocalizedString("Theme")],[LocalizedString("Log")],[LocalizedString("Sport")]]
        return arr
    }()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.optionArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.optionArr[section].count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECTION_SPACE
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cellId = "MineSwitchCell"
        var cell:CDSwitchCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as? CDSwitchCell
        if cell == nil {
            cell = CDSwitchCell(style: .default, reuseIdentifier: cellId)
        }
        let option = optionArr[indexPath.section][indexPath.row]
        cell.titleLabel.text = option
        cell.swi.isHidden = option != LocalizedString("Watermark")
        cell.accessoryType = option != LocalizedString("Watermark") ? .disclosureIndicator : .none
        cell.selectionStyle =  option != LocalizedString("Watermark") ? .default : .none
        if option == LocalizedString("Watermark") {
            cell.swi.isOn = CDSignalTon.shared.waterBean.isOn
            cell.swiBlock = {(swi) in
                self.onWaterSwitchClick(swi: swi)
            }
        }
        //最后一个没有分割线
        cell.separatorLineIsHidden = indexPath.row == optionArr[indexPath.section].count - 1
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = optionArr[indexPath.section][indexPath.row]
        switch option {
        case LocalizedString("About"):
            let device = CDDeviceInfoViewController()
            device.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(device, animated: true)
            
        case LocalizedString("Storage"):
            let mem  = CDMemoryViewController()
            mem.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(mem, animated: true)
        case LocalizedString("Privacy"):
            let privacy = CDOptionViewController()
            privacy.hidesBottomBarWhenPushed = true
            privacy.title = LocalizedString("Privacy")
            privacy.optionArr = [.ChangePwd,.TouchID,.FakeSet]
            self.navigationController?.pushViewController(privacy, animated: true)
            
        case LocalizedString("Watermark"):
            if CDSignalTon.shared.waterBean.isOn {
                self.pushSetWatermaek()
            }
        case LocalizedString("Log"):
            let logVC = CDOptionViewController()
            logVC.hidesBottomBarWhenPushed = true
            logVC.title = LocalizedString("Log")
            logVC.optionArr = [.LogSet,.LogPreview]
            self.navigationController?.pushViewController(logVC, animated: true)
        case LocalizedString("Sport"):
            let mapVC = CDMapViewController()
            mapVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(mapVC, animated: true)
        case LocalizedString("Theme"):
            let themeVC = CDThemeViewController()
            themeVC.hidesBottomBarWhenPushed = true
            themeVC.title = LocalizedString("Theme")
            self.navigationController?.pushViewController(themeVC, animated: true)
        default:
            break
        }
        
    }
    
    private func pushSetWatermaek(){
        let water = CDMarkFileViewController()
        water.hidesBottomBarWhenPushed = true
        water.title = LocalizedString("Watermark")
        water.maxTextCount = CDMaxWatermarkLength
        water.oldContent = CDSignalTon.shared.waterBean.text
        water.markType = .waterInfo
        water.markHandle = {(newContent) in
            CDWaterBean.setWaterConfig(isOn: true, text: newContent!)
            CDSignalTon.shared.waterBean = CDWaterBean()
            let myDelegate = UIApplication.shared.delegate as! CDAppDelegate
            CDSignalTon.shared.addWartMarkToWindow(appWindow: myDelegate.window!)
            CDPrintManager.log("水印内容设置:\(newContent!)", type: .InfoLog)
        }
        self.navigationController?.pushViewController(water, animated: true)
    }
    
    private func onWaterSwitchClick(swi:UISwitch){
        if swi.isOn {
            self.pushSetWatermaek()
        }else{
            let alert = UIAlertController(title: nil, message: LocalizedString("Are you sure to turn off the watermark?"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizedString("cancel"), style: .cancel, handler: { (param:UIAlertAction) in
                swi.isOn = true
            }))
            alert.addAction(UIAlertAction(title: LocalizedString("sure"), style: .default, handler: { (param:UIAlertAction) in
                let myDelegate = UIApplication.shared.delegate as! CDAppDelegate
                CDSignalTon.shared.removeWaterMarkFromWindow(window: myDelegate.window!)
                CDWaterBean.setWaterConfig(isOn: false, text: GetAppName())
                CDSignalTon.shared.waterBean = CDWaterBean()
                let wartSet = [LocalizedString("Watermark")]
                let index = self.optionArr.firstIndex(of: wartSet)!
                let waterPath = IndexPath(row: 0, section: index)
                self.tableview.reloadRows(at: [waterPath], with: .none)
                CDPrintManager.log("水印开关关闭", type: .InfoLog)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

