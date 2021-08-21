//
//  CDDeviceInfoViewController.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/12/9.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit
import CDIndicator
class CDDeviceInfoViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {
    private var optionTitleArr:[[String]] = [[]]
    private var optionValue:[String:String?] = [:]
    private var tableView:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableView.delegate = self;
        tableView.dataSource = self
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        tableView.register(CDSwitchCell.self, forCellReuseIdentifier: "deviceInfoCell")

        initOptionValue()
    }
    func initOptionValue(){
        optionTitleArr.removeAll()
        optionTitleArr = [[LocalizedString("Name"),LocalizedString("Software Version"),LocalizedString("Model Name"),LocalizedString("UUID")],
                          [LocalizedString("Run Time"),LocalizedString("Battery Power"),LocalizedString("Low Power Mode"),LocalizedString("CPU"),LocalizedString("RAM")],
                          [LocalizedString("Network"),LocalizedString("Carrier"),LocalizedString("IP")],[LocalizedString("Capacity"),LocalizedString("Available")]]
        
        CDHUDManager.shared.showWait(LocalizedString("checking... "))
        CDDeviceIndicatorAPI.share.startCheckDeviceInfo(indicatorArr: optionTitleArr) { (dict) in
            CDHUDManager.shared.hideWait()
            self.optionValue = dict
            self.tableView.reloadData()
            
            
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return optionTitleArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionTitleArr[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "deviceInfoCell"
        var cell:CDSwitchCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as? CDSwitchCell
        if cell == nil {
            cell = CDSwitchCell(style: .default, reuseIdentifier: cellId)
        }
        cell.swi.isHidden = true
        cell.selectionStyle = .none
        let optionTitle = optionTitleArr[indexPath.section][indexPath.row]
        var value = self.optionValue[optionTitle] ?? ""
        if (optionTitle == LocalizedString("UUID") || optionTitle == LocalizedString("IP")) && CDSignalTon.shared.loginType == .fake  {
            value = "******"
        }
        cell.titleLabel.text = optionTitle
        cell.valueLabel.text = value
        cell.valueLabel.isHidden = false
        
        //最后一个没有分割线
        cell.separatorLineIsHidden = indexPath.row == optionTitleArr[indexPath.section].count - 1
       return cell
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
