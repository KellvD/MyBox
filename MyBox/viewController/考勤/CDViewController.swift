//
//  CDAttendanceViewController.swift
//  MyBox
//
//  Created by changdong on 2021/8/21.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

class CDAttendanceDetailViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {

    var tableblew:UITableView!
    var dataArr:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableblew = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight-48), style: .plain)
        tableblew.delegate = self
        tableblew.dataSource = self
        tableblew.separatorStyle = .none
        view.addSubview(tableblew)
        tableblew.register(CDFileTableViewCell.self, forCellReuseIdentifier: "AttendanceCellId")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellId = "audioCellId"
        var cell:CDFileTableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? CDFileTableViewCell
        if cell == nil {
            cell = CDFileTableViewCell(style: .default, reuseIdentifier: cellId)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    

}
