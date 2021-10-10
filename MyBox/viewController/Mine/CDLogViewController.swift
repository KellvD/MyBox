//
//  CDLogConfigViewController.swift
//  MyBox
//
//  Created by changdong  on 2020/7/6.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit
class CDLogViewController: CDBaseAllViewController {

    private var segView:UISegmentedControl!
    private var logoPathField:UITextField!
    private var logoNameField:UITextField!
    var isSet:Bool! //true 设置 //false 预览
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "日志设置".localize
        self.view.backgroundColor = .baseBgColor
        if !isSet {
            readLog()
            return;
        }
        
        let level = CDLogBean.logLevel
        let logName = CDLogBean.logName.removeSuffix()
        let logFolder = CDLogBean.logFolder
        
        let logoLevelLabel = createLabel(text: "日志等级:".localize, frame: CGRect(x: 10, y: 30, width: 90, height: 28))
        segView = UISegmentedControl(items: ["Debug","Info","Error","Warn","All"])
        segView.frame = CGRect(x: logoLevelLabel.frame.maxX + 10, y: logoLevelLabel.frame.minY-4, width: CDSCREEN_WIDTH - 10 - logoLevelLabel.frame.maxX - 10, height: 36)
        segView.tintColor = .black
        segView.selectedSegmentIndex = level.rawValue
        if #available(iOS 13.0, *) {
            segView.selectedSegmentTintColor = .red
        } else {
            // Fallback on earlier versions
        }
        self.view.addSubview(segView)
        
        //
        let logoPathLabel = createLabel(text: "日志目录:".localize, frame: CGRect(x: 10, y: 30 * 2 + 28, width: 90, height: 28))
        logoPathField = UITextField(frame: CGRect(x: logoPathLabel.frame.maxX + 10, y: logoPathLabel.frame.minY-4, width: CDSCREEN_WIDTH - 10 - logoPathLabel.frame.maxX - 10, height: 36))
        logoPathField.placeholder = "请输入日志路径".localize
        logoPathLabel.lineBreakMode = .byTruncatingMiddle
        logoPathField.text = logFolder
        self.view.addSubview(logoPathField)
        
        //
        let logoNameLabel = createLabel(text: "日志名称".localize, frame: CGRect(x: 10, y: 30 * 3 + 28 * 2, width: 90, height: 28))
        logoNameField = UITextField(frame: CGRect(x: logoNameLabel.frame.maxX + 10, y: logoNameLabel.frame.minY-4, width: CDSCREEN_WIDTH - 10 - logoNameLabel.frame.maxX - 10, height: 36))
        logoNameField.placeholder = "请输入日志名称".localize
        logoNameField.borderStyle = .roundedRect
        logoNameField.text = logName
        self.view.addSubview(logoNameField)
        
        let sureButton = UIButton(type: .custom)
        sureButton.frame = CGRect(x: 10, y: logoNameLabel.frame.maxY + 30, width: CDSCREEN_WIDTH - 20, height: 48)
        sureButton.setTitle("确定".localize, for: .normal)
        sureButton.setBackgroundImage(UIImage(named: "上导航栏-背景"), for: .normal)
        sureButton.layer.cornerRadius = 4.0
        sureButton.clipsToBounds = true
        sureButton.addTarget(self, action: #selector(sureButtonClick), for: .touchUpInside)
        self.view.addSubview(sureButton)
        
    }
    lazy var textView: UITextView = {
        let tv = UITextView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight))
        tv.isEditable = false;
        tv.isSelectable = false;
        view.addSubview(tv)
        return tv
    }()
    
    private func readLog(){
        self.title = CDLogBean.logName
        var content  = "当前内容不可查看".localize
        do {
            content = try String(contentsOfFile: CDLogBean.logPath)
            content = content.isEmpty ? "暂无日志记录".localize : content
        } catch  {
            CDPrintManager.log("日志文件读取失败error:\(error.localizedDescription)", type: .ErrorLog)
        }
        
        textView.text = content;
        textView.scrollRangeToVisible(NSRange(location: content.count, length: 1))
        
    }
    private func createLabel(text:String,frame:CGRect) ->UILabel{
        let label = UILabel(frame: frame)
        label.text = text
        label.textColor = .textBlack
        label.font = .mid
        self.view.addSubview(label)
        return label
    }
    
    @objc func sureButtonClick(){
        let path = logoPathField.text!
        var name = logoNameField.text!
        if path.isEmpty {
            CDHUDManager.shared.showText("暂无日志记录".localize)
            return
        } else if logoNameField.text!.isEmpty {
            CDHUDManager.shared.showText("日志名称不能为空".localize)
        }
        if !name.hasSuffix(".log") {
            name.append(".log")
        }        

        CDLogBean.isOn = true
        CDLogBean.logLevel = CDLogLevel(rawValue: segView.selectedSegmentIndex)!
        CDLogBean.logFolder = path
        CDLogBean.logName = name
        CDLogBean.logPath = String.documentPath().appendingPathComponent(str: "/\(path)/\(name)")
        self.navigationController?.popViewController(animated: true)
    }

    
}
