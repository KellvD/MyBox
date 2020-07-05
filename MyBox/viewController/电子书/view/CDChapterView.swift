//
//  CDReadListView.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/6/29.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

protocol CDChapterViewDelegate {
    func onSelectChapter(index:Int)
}
class CDChapterView: UITableView, UITableViewDelegate,UITableViewDataSource{
    
    var myDelegate:CDChapterViewDelegate!
    
    private var chapterArr:[CDChapterModel] = []
    init(frame:CGRect) {
        super.init(frame: frame, style: .plain)
        self.dataSource = self
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapterArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "chapterCellIde", for: indexPath)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "chapterCellIde")
            let view = UIView()
            cell.selectedBackgroundView = view
            cell.selectedBackgroundView?.backgroundColor = LightBlueColor
            
            let pointView = UIView(frame: CGRect(x: 10, y: cell.frame.height/2 - 15, width: 15, height: 15))
            pointView.layer.cornerRadius = 15 / 2
            pointView.backgroundColor = .white
            cell.addSubview(pointView)
            
            let label = UILabel(frame: CGRect(x: pointView.frame.maxX + 5, y: 3, width: frame.width - 30 - 60, height: 30))
            label.font = TextSmallFont
            label.numberOfLines = 0
            label.textColor = .black
            cell.addSubview(label)
            label.tag = 100
            
            let processLabel = UILabel(frame: CGRect(x: frame.maxX - 50, y: 3, width: 48, height: 30))
            processLabel.font = TextSmallFont
            processLabel.textColor = .black
            cell.addSubview(processLabel)
            processLabel.tag = 101
            
            let line = UIView(frame: CGRect(x: 0, y: cell.frame.height - 1, width: frame.width, height: 1))
            line.backgroundColor = .black
            cell.addSubview(line)
            line.tag = 102
            
        }
        let label = cell.viewWithTag(100) as! UILabel
        let processLabel = cell.viewWithTag(101) as! UILabel
        let line = cell.viewWithTag(102)!
        
        
        let model = chapterArr[indexPath.row]
        label.text = model.title
        processLabel.text = "\(model.process ?? 0)%"
        line.isHidden = indexPath.row == chapterArr.count - 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        myDelegate.onSelectChapter(index: indexPath.row)
    }
}
