//
//  CDThemeViewController.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2021/2/4.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

class CDThemeViewController: CDBaseAllViewController, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
    }

    lazy var tableView: UITableView = {
        let tableV = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableV.separatorStyle = .none
        tableV.delegate = self
        tableV.dataSource = self
        tableV.isScrollEnabled = false
        tableV.register(CDSwitchCell.self, forCellReuseIdentifier: "ThemeSwitchCell01")
        tableV.translatesAutoresizingMaskIntoConstraints = false
        return tableV
    }()
    
    lazy var optionArr: [[String]] = {
        if #available(iOS 13.0, *){
            return [[LocalizedString("Follow the system")],[LocalizedString("Normal Mode"),LocalizedString("Dark Mode")]]
        }
        return [[LocalizedString("Normal Mode"),LocalizedString("Dark Mode")]]
    }()

    func numberOfSections(in tableView: UITableView) -> Int {
        if #available(iOS 13.0, *){
            return GetAppThemeSwi() ? 1 : 2
        }
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 64.0 : 48.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.01 : 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView()
        let label = UILabel(frame: CGRect(x: 15, y: 10, width: 100, height: 20))
        label.textColor = TextLightGrayColor
        label.font = TextSmallFont
        label.text = LocalizedString("Manual selection")
        headView .addSubview(label)
        return section == 0 ? nil : headView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cellId = "ThemeSwitchCell01"
            var cell:CDSwitchCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as? CDSwitchCell
            if cell == nil {
                cell = CDSwitchCell(style: .default, reuseIdentifier: cellId)
            }
            cell.valueLabelIsAtBottom()
            cell.titleLabel.text = LocalizedString("Follow the system")
            cell.valueLabel.text = LocalizedString("After it is turned on, dark mode will be turned on or off following the system")
            
            cell.swi.isHidden = false
            cell.swi.isOn = GetAppThemeSwi()
            cell.swiBlock = {[weak self](swi) in
                CDConfigFile.setBoolValueToConfigWith(key: .darkSwi, boolValue: swi.isOn)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeAppTheme"), object: nil)

                self!.tableView.reloadData()
            }
            cell.separatorLineIsHidden = true
            
            return cell
        }else{
            let cellId = "ThemeSwitchCell02"
            var cell:CDSwitchCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as? CDSwitchCell
            if cell == nil {
                cell = CDSwitchCell(style: .default, reuseIdentifier: cellId)
            }
            cell.titleLabel.text = indexPath.row == 0 ? LocalizedString("Normal Mode") : LocalizedString("Dark Mode")
            cell.isHidden = GetAppThemeSwi()
            cell.accessoryType = GetThemeMode().rawValue == indexPath.row ? .checkmark : .none
            cell.separatorLineIsHidden = indexPath.row == 1
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            CDConfigFile.setIntValueToConfigWith(key: .themeMode, intValue: indexPath.row)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeAppTheme"), object: nil)
            tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
    }
   
   
}
