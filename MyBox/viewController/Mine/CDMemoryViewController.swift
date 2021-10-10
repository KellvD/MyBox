//
//  CDMemoryViewController.swift
//  MyBox
//
//  Created by changdong on 2020/11/12.
//  Copyright © 2020 changdong. All rights reserved.
//

import UIKit

class CDMemoryViewController: CDBaseAllViewController,UITableViewDelegate,UITableViewDataSource {
    
    var fileCountState:(imageCount:Int,videoCount:Int,audioCount:Int,otherCount:Int)!
    var optionArr:[String]!
    var tableView:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "文件存储"
        optionArr = ["文件数量","文件尺寸","文件操作"]
        fileCountState = CDSqlManager.shared.queryEveryFileCount()
    CDPrintManager.log("数据库存储情况:Image:\(fileCountState.imageCount),Video:\(fileCountState.videoCount),Audio:\(fileCountState.audioCount),Text:\(fileCountState.otherCount)", type: .InfoLog)
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), style: .grouped)
        tableView.delegate = self;
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        let size = CDSqlManager.shared.queryEveryFileTotalSize()
        print(size)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return optionArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .baseBgColor
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel(frame: CGRect(x: 15, y: 18, width: 150, height: 30))
        label.text = optionArr[section]
        label.font = .midSmall
        label.textColor = .textBlack
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identify = "memoryInfoCell"
        
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identify)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identify)
            cell.selectionStyle = .none
            if indexPath.section == 0 {
                let total = fileCountState.imageCount + fileCountState.videoCount + fileCountState.audioCount + fileCountState.otherCount
                let image = ShinePieItem(color: .red, value: CGFloat(fileCountState.imageCount)/CGFloat(total), title: "图片")
                let video = ShinePieItem(color: .blue, value: CGFloat(fileCountState.videoCount)/CGFloat(total),title: "视频")
                let audio = ShinePieItem(color: .purple, value: CGFloat(fileCountState.audioCount)/CGFloat(total),title: "音频")
                let text = ShinePieItem(color: .green, value: CGFloat(fileCountState.otherCount)/CGFloat(total),title: "其他")
                let pie = ShinePieChart(frame: CGRect(x: self.view.midX - 100, y: 50, width: 200, height: 200), items: [image,video,audio,text])
                pie.ringRadius = 20//内环半径
                pie.startAngle = 0.2 //开始方向
                pie.font = UIFont.systemFont(ofSize: 12)
                pie.duration = 3
                pie.center = CGPoint(x: self.view.frame.midX, y: 150)
                cell.contentView.addSubview(pie)
            }else if indexPath.section == 1{
                
            }else{
                
            }
            
        }
        return cell
        
    }

    
}

