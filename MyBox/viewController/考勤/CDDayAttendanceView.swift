//
//  CDDayAttendanceView.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

typealias CDDoneAttendanceHandle = (_ type:Int)->()
class CDDayAttendanceView: UIView {

    
    private var morningBtn:UIButton!
    private var afternoonBtn:UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1))
        line.backgroundColor = .separatorColor
        self.addSubview(line)
        
        let morningLabel = UILabel(frame: CGRect(x: 15, y: 15, width: 200, height: 45))
        morningLabel.text = "早打卡"
        morningLabel.font = .mid
        self.addSubview(morningLabel)
        
        morningBtn = UIButton(type: .custom)
        morningBtn.frame = CGRect(x: frame.width - 15 - 100, y: morningLabel.minY+4, width: 100, height: 40)
        morningBtn.addTarget(self, action: #selector(onDoneAttendance(sender:)), for: .touchUpInside)
        morningBtn.setTitle("未打卡", for: .normal)
        morningBtn.backgroundColor = .navgationBarColor
        morningBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        morningBtn.layer.cornerRadius = 20
        morningBtn.tag = 1
        self.addSubview(morningBtn)
        
        let line01 = UIView(frame: CGRect(x: 0, y: 76 , width: frame.width, height: 1))
        line01.backgroundColor = .separatorColor
        self.addSubview(line01)
        
        let afternoonLabel = UILabel(frame: CGRect(x: 15, y: morningLabel.maxY + 30, width: 200, height: 45))
        afternoonLabel.text = "晚打卡"
        afternoonLabel.font = .mid
        self.addSubview(afternoonLabel)
        
        afternoonBtn = UIButton(type: .custom)
        afternoonBtn.frame = CGRect(x: frame.width - 15 - 100, y: afternoonLabel.minY+4, width: 100, height: 40)
        afternoonBtn.addTarget(self, action: #selector(onDoneAttendance(sender:)), for: .touchUpInside)
        afternoonBtn.setTitle("未打卡", for: .normal)
        afternoonBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        afternoonBtn.backgroundColor = .navgationBarColor
        afternoonBtn.tag = 2
        afternoonBtn.layer.cornerRadius = 20
        self.addSubview(afternoonBtn)
        
        let line02 = UIView(frame: CGRect(x: 0, y: 152 , width: frame.width, height: 1))
        line02.backgroundColor = .separatorColor
        self.addSubview(line02)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func onDoneAttendance(sender:UIButton){
        if sender.isEnabled {
            sender.setTitle("已打卡", for: .normal)
            sender.backgroundColor = UIColor(250, 10, 32,0.5)
            sender.isEnabled = false
        }
    }

    func setAttendanceStatus(status:Bool,type:Int){
        let btn = self.viewWithTag(type) as! UIButton
        btn.setTitle(status ? "已打卡":"未打卡", for: .normal)
        btn.backgroundColor = status ? .navgationBarColor : UIColor(250, 10, 32,0.5)
        btn.isEnabled = !status
    }
    
}
