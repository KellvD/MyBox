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
        dataArr = CDSqlManager.shared.queryAllTextSafeFile()
        tabView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH), style: .plain)
        tabView.delegate = self
        tabView.dataSource = self
        tabView.separatorStyle = .none
        view.addSubview(tabView)
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count;
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "ReadCellIde")
        if cell == nil{
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ReadCellIde")
            let view = UIView()
            cell.selectedBackgroundView = view
            cell.selectedBackgroundView?.backgroundColor = LightBlueColor
   
            let headImage = UIImageView(frame: CGRect(x: 10, y: 10, width: 45, height: 45))
            headImage.tag = 101
            cell.contentView.addSubview(headImage)

            let fileNameL = UILabel(frame:CGRect(x: headImage.frame.maxX+10, y: 10, width: CDSCREEN_WIDTH-75, height: 25))
            fileNameL.textColor = TextBlackColor
            fileNameL.font = TextMidFont
            fileNameL.lineBreakMode = .byTruncatingMiddle
            fileNameL.textAlignment = .left
            fileNameL.tag = 102
            cell.contentView.addSubview(fileNameL)

            let detailLabel = UILabel(frame:CGRect(x: headImage.frame.maxX+10, y: fileNameL.frame.maxY, width: 150, height: 25))
            detailLabel.textColor = TextGrayColor
            detailLabel.textAlignment = .left
            detailLabel.font = TextSmallFont
            detailLabel.tag = 103
            cell.contentView.addSubview(detailLabel)
            
            let line = UIView(frame: CGRect(x: 5, y: 64, width: CDSCREEN_WIDTH-10, height: 1))
            line.backgroundColor = SeparatorGrayColor
            line.tag = 104
            cell.contentView.addSubview(line)
        }
        let headImage = cell.contentView.viewWithTag(101) as! UIImageView
        let fileNameL = cell.contentView.viewWithTag(102) as! UILabel
        let detailLabel = cell.contentView.viewWithTag(103) as! UILabel
        let line = cell.contentView.viewWithTag(104)
        
        let gfile = dataArr[indexPath.row]
        headImage.image = LoadImageByName(imageName: "file_txt_big", type: "png")
        fileNameL.text = gfile.fileName
        detailLabel.text = "%43"
        line?.isHidden = indexPath.row == dataArr.count - 1
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let gfile = dataArr[indexPath.row]
        
        let readVC = CDReaderPageViewController()
        readVC.hidesBottomBarWhenPushed = true
        readVC.resource = String.RootPath().appendingPathComponent(str: gfile.filePath)
        self.navigationController?.pushViewController(readVC, animated: true)
        
    }
    
    @available(iOS, introduced: 8.0, deprecated: 13.0)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let gfile = dataArr[indexPath.row]
        let detail = UITableViewRowAction(style: .normal, title: "删除") { (action, index) in
            
        }
        return [detail]
    }
    
    @available(iOS 11, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let gfile = dataArr[indexPath.row]
        
        let delete = UIContextualAction(style: .normal, title: "删除") { (action, view, handle) in
        }
        delete.backgroundColor = .red
        let action = UISwipeActionsConfiguration(actions: [delete])
        return action
    }
}



