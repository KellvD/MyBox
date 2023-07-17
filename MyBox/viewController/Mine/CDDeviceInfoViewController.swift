//
//  CDDeviceInfoViewController.swift
//  MyBox
//
//  Created by changdong on 2020/12/9.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import CDIndicator
class CDDeviceInfoViewController: CDBaseAllViewController, UITableViewDelegate, UITableViewDataSource {
    private var optionTitleArr: [[String]] = [[]]
    private var optionValue: [String: String?] = [:]
    private var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        tableView.register(CDSwitchCell.self, forCellReuseIdentifier: "deviceInfoCell")

        initOptionValue()
    }
    func initOptionValue() {
        optionTitleArr.removeAll()
        optionTitleArr = [["名称", "软件版本", "型号名称", "UUID"],
                          ["运行时长", "电池电量", "省电模式", "CPU", "RAM"],
                          ["网络", "运营商", "IP"],
                          ["总容量", "可用容量"]]

        CDHUDManager.shared.showWait("检测中...".localize)
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
        var cell: CDSwitchCell! = tableView.dequeueReusableCell(withIdentifier: cellId) as? CDSwitchCell
        if cell == nil {
            cell = CDSwitchCell(style: .default, reuseIdentifier: cellId)
        }
        cell.swi.isHidden = true
        cell.selectionStyle = .none
        let optionTitle = optionTitleArr[indexPath.section][indexPath.row]
        var value = self.optionValue[optionTitle] ?? ""
        if (optionTitle == "UUID".localize || optionTitle == "IP".localize) && CDSignalTon.shared.loginType == .fake {
            value = "******"
        }
        cell.titleLabel.text = optionTitle.localize
        cell.valueLabel.text = value
        cell.valueLabel.isHidden = false

        // 最后一个没有分割线
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
