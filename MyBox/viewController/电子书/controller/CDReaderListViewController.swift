//
//  CDReaderViewController.swift
//  MyBox
//
//  Created by changdong  on 2020/6/10.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
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
        view.addSubview(tabView)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onLoadTextFile))
    }
    @objc func onLoadTextFile(){
        dataArr = CDSqlManager.shared.queryAllTextSafeFile()
        self.tabView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count;
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "ReadCellIde", for: indexPath)
        if cell == nil{
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ReadCellIde")
            let view = UIView()
            cell.selectedBackgroundView = view
            cell.selectedBackgroundView?.backgroundColor = LightBlueColor
   
            cell.textLabel?.textColor = TextBlackColor
            cell.textLabel?.font = TextMidFont
            cell.detailTextLabel?.textColor = TextGrayColor
            cell.detailTextLabel?.font = TextSmallFont
        }
        let gfile = dataArr[indexPath.row]
        cell.imageView?.image = LoadImageByName(imageName: "file_txt_big", type: "png")
        cell.textLabel?.text = gfile.fileName
        cell.detailTextLabel?.text = "%43"
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let readVC = CDReadDetailViewController()
//        readVC.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(readVC, animated: true)
        
    }
}
