//
//  CDLogConfigViewController.swift
//  MyBox
//
//  Created by changdong  on 2020/7/6.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit

class CDLogConfigViewController: CDBaseAllViewController {

    private var segView:UISegmentedControl!
    private var logoPathField:UITextField!
    private var logoNameField:UITextField!
    var name:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "日志配置"
        func createLabel(text:String,frame:CGRect) ->UILabel{
            let label = UILabel(frame: frame)
            label.text = text
            label.textColor = TextBlackColor
            label.font = TextMidFont
            self.view.addSubview(label)
            return label
        }
        
        let logoLevelLabel = createLabel(text: "日志等级:", frame: CGRect(x: 10, y: 30, width: 90, height: 28))
        segView = UISegmentedControl(items: ["Debug","Info","Error"])
        segView.frame = CGRect(x: logoLevelLabel.frame.maxX + 10, y: logoLevelLabel.frame.minY-4, width: CDSCREEN_WIDTH - 10 - logoLevelLabel.frame.maxX - 10, height: 36)
        segView.tintColor = .black
        segView.selectedSegmentIndex = CDSignalTon.shared.logbBean.logLevel.rawValue
        if #available(iOS 13.0, *) {
            segView.selectedSegmentTintColor = .red
        }
        self.view.addSubview(segView)
        
        //
        let logoPathLabel = createLabel(text: "日志路径:", frame: CGRect(x: 10, y: 30 * 2 + 28, width: 90, height: 28))
        logoPathField = UITextField(frame: CGRect(x: logoPathLabel.frame.maxX + 10, y: logoPathLabel.frame.minY-4, width: CDSCREEN_WIDTH - 10 - logoPathLabel.frame.maxX - 10, height: 36))
        logoPathField.placeholder = "请输入日志路径"
        logoPathField.borderStyle = .roundedRect
        logoPathLabel.lineBreakMode = .byTruncatingHead
        self.view.addSubview(logoPathField)
        
        //
        let logoNameLabel = createLabel(text: "日志名称:", frame: CGRect(x: 10, y: 30 * 3 + 28 * 2, width: 90, height: 28))
        logoNameField = UITextField(frame: CGRect(x: logoNameLabel.frame.maxX + 10, y: logoNameLabel.frame.minY-4, width: CDSCREEN_WIDTH - 10 - logoNameLabel.frame.maxX - 10, height: 36))
        logoNameField.placeholder = "请输入日志名称"
        logoNameField.borderStyle = .roundedRect
        self.view.addSubview(logoNameField)
        
       
        logoPathField.text = CDSignalTon.shared.logbBean.logPath + "/"
        logoNameField.text = CDSignalTon.shared.logbBean.logName
        
        let sureButton = UIButton(type: .custom)
        sureButton.frame = CGRect(x: 15, y: logoNameLabel.frame.maxY + 30, width: CDSCREEN_WIDTH - 30, height: 48)
        sureButton.setTitle("确定", for: .normal)
        sureButton.setBackgroundImage(UIImage(named: "上导航栏-背景"), for: .normal)
        sureButton.layer.cornerRadius = 4.0
        sureButton.clipsToBounds = true
        sureButton.addTarget(self, action: #selector(sureButtonClick), for: .touchUpInside)
        self.view.addSubview(sureButton)
        
    }
    
    @objc func sureButtonClick(){
        if logoPathField.text!.isEmpty {
            CDHUDManager.shared.showText(text: "日志路径不能为空")
            return
        } else if logoNameField.text!.isEmpty {
            CDHUDManager.shared.showText(text: "日志名称不能为空")
        }
        
        
        CDLogBean.setLogConfig(isOn: true, logLevel: CDLogLevel(rawValue: segView.selectedSegmentIndex)!, logName: logoNameField.text!, logPath: logoPathField.text!)
        CDSignalTon.shared.logbBean = CDLogBean()
        
        
        self.navigationController?.popViewController(animated: true)
    }

    
}
