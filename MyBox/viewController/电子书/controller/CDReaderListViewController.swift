//
//  CDReaderViewController.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/6/10.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

class CDReaderListViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {
    
    

    private var tabView:UITableView!
    private var dataArr:[CDSafeFileInfo] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hiddBackbutton()
       
        tabView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH), style: .plain)
        tabView.delegate = self
        tabView.dataSource = self
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count;
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "ReadCellIde", for: indexPath)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "ReadCellIde")
            let view = UIView()
            cell.selectedBackgroundView = view
            cell.selectedBackgroundView?.backgroundColor = LightBlueColor
        }
        cell.textLabel?.text = ""
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let readVC = CDReadDetailViewController()
//        readVC.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(readVC, animated: true)
        
    }
}
