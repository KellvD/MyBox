//
//  CDCameraTopBar.swift
//  MyRule
//
//  Created by changdong on 2019/5/24.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit


enum CDCameraSetType:Int {
    case flash = 100
    case hdr = 101
    case delay = 102
}

protocol CDCameraTopBarDelete {
    func turnFlashModel(model:Int)
    func turnHDRModel(model:Int)
}
class CDCameraTopBar: UIView {

    private var timeLabel:UILabel?
    private var isVideo:Bool!
    private var space:CGFloat = 50
    private var width:CGFloat = 45
    private var optionBtnArr:[UIButton] = []
    private var funcBtnArr:[UIButton] = []
    var delegate:CDCameraTopBarDelete!
    private var setType:CDCameraSetType!
    init(frame:CGRect,isVideo:Bool) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        if !isVideo{
            
            let T = getFunctionBtnImageName()
            
            //闪光灯
            let flashBtn = UIButton(type: .custom)
            flashBtn.frame = CGRect(x: 15, y: 4, width: width, height: width);
            flashBtn.tag = CDCameraSetType.flash.rawValue
            flashBtn.setImage(UIImage(named: T[0]), for: .normal)
            flashBtn.addTarget(self, action: #selector(functionBtnClick(sender:)), for: .touchUpInside)
            self.addSubview(flashBtn)
            funcBtnArr.append(flashBtn)
            
            //Hdr
            let hdrBtn = UIButton(type: .custom)
            hdrBtn.frame = CGRect(x: 15 + width + space, y: 4, width: width, height: width);
            hdrBtn.tag = CDCameraSetType.hdr.rawValue
            hdrBtn.setImage(UIImage(named: T[1]), for: .normal)
            hdrBtn.addTarget(self, action: #selector(functionBtnClick(sender:)), for: .touchUpInside)
            self.addSubview(hdrBtn)
            funcBtnArr.append(hdrBtn)
            //延时
            let delayBtn = UIButton(type: .custom)
            delayBtn.frame = CGRect(x: 15 + width * 2 + space * 2, y: 4, width: width, height: width);
            delayBtn.tag = CDCameraSetType.delay.rawValue
            delayBtn.setImage(UIImage(named: T[2]), for: .normal)
            delayBtn.addTarget(self, action: #selector(functionBtnClick(sender:)), for: .touchUpInside)
            self.addSubview(delayBtn)
            funcBtnArr.append(delayBtn)
            
            
            let firstBtn = UIButton(type: .custom)
            firstBtn.frame = CGRect(x: flashBtn.frame.maxX + space, y: 4, width: width, height: width);
            firstBtn.addTarget(self, action: #selector(optionItemClick(sender:)), for: .touchUpInside)
            firstBtn.isHidden = true
            firstBtn.tag = 200
            firstBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            self.addSubview(firstBtn)
            optionBtnArr.append(firstBtn)
            
            let secondBtn = UIButton(type: .custom)
            secondBtn.frame = CGRect(x: firstBtn.frame.maxX + space, y: 4, width: width, height: width);
            secondBtn.addTarget(self, action: #selector(optionItemClick(sender:)), for: .touchUpInside)
            secondBtn.isHidden = true
            secondBtn.tag = 201
            secondBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            self.addSubview(secondBtn)
            optionBtnArr.append(secondBtn)
            
            let thirdBtn = UIButton(type: .custom)
            thirdBtn.frame = CGRect(x: secondBtn.frame.maxX + space, y: 4, width: width, height: width);
            thirdBtn.addTarget(self, action: #selector(optionItemClick(sender:)), for: .touchUpInside)
            thirdBtn.isHidden = true
            thirdBtn.tag = 202
            thirdBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            self.addSubview(thirdBtn)
            optionBtnArr.append(thirdBtn)
            
        }else{
            timeLabel = UILabel(frame: CGRect(x: frame.width/2 - 100, y: 4, width: 200 , height: 40))
            timeLabel?.textColor = UIColor.white
            timeLabel?.font = TextMidFont
            timeLabel?.text = "00:00:00"
            timeLabel?.textAlignment = .center
            self.addSubview(timeLabel!)
        }
    }

    @objc func functionBtnClick(sender:UIButton){
        setType = CDCameraSetType(rawValue:sender.tag)
        sender.isSelected = !sender.isSelected
        if sender.isSelected { //点击展开
            //点击按钮显示，其他的隐藏
            for btn in funcBtnArr {
                btn.isHidden = !(btn == sender)
            }
            let firstTitle = setType == .delay ? "关闭" : "自动"
            let secondTitle = setType == .delay ? "3秒" : "打开"
            let thirdTitle = setType == .delay ? "10秒" : "关闭"
            let titleArr = [firstTitle,secondTitle,thirdTitle]
            let key = setType == .flash ? FlashKey :
                      setType == .hdr ? HdrKey : DelayKey
            let state = UserDefaults.standard.integer(forKey: key)
            
            UIView.animate(withDuration: 0.25) {
                //按钮左移
                var rect = sender.frame
                rect.origin.x = 15
                sender.frame = rect
               
                for i in 0..<self.optionBtnArr.count {
                    let btn = self.optionBtnArr[i]
                    btn.isHidden = false
                    btn.setTitle(titleArr[i], for: .normal)
                    btn.setTitleColor((state == i) ? .red : .white, for: .normal)
                }

            }
        } else { //收起来
            //选项按钮全部隐藏
            self.optionBtnArr.forEach { (btn) in
                btn.isHidden = true
            }
            for i in 0..<funcBtnArr.count {
                let btn = funcBtnArr[i]
                btn.isHidden = false
                if btn == sender {
                    //功能位置归位
                    UIView.animate(withDuration: 0.25) {
                        var rect = sender.frame
                        rect.origin.x = CGFloat(15 + 50 * i + 45 * i)
                        sender.frame = rect
                    }
                }
            }
        }
    }
    
    @objc func optionItemClick(sender:UIButton){
        let key = setType == .flash ? FlashKey :
                  setType == .hdr ? HdrKey : DelayKey
        UserDefaults.standard.set(sender.tag - 200, forKey: key)
        //选项按钮全部隐藏
        self.optionBtnArr.forEach { (btn) in
            btn.isHidden = true
        }
        let T = getFunctionBtnImageName()
        for i in 0..<funcBtnArr.count {
            //图片替换
            let btn = funcBtnArr[i]
            btn.isHidden = false
            btn.setImage(UIImage(named: T[i]), for: .normal)
            if btn.tag == setType.rawValue {
                btn.isSelected = false
                //功能位置归位
                UIView.animate(withDuration: 0.25) {
                    var rect = btn.frame
                    rect.origin.x = CGFloat(15 + 50 * i + 45 * i)
                    btn.frame = rect
                }
            }
        }
        if setType == .flash {
            delegate.turnFlashModel(model: sender.tag - 200)
        } else if setType == .hdr {
            delegate.turnHDRModel(model: sender.tag - 200)
        }
    }
    
    func getFunctionBtnImageName() ->[String]{
        let optionImageArr = [["flash_auto","flash_on","flash_off"],
                              ["hdr_auto","hdr_on","hdr_off"],
                              ["delay_off","delay_on","delay_10"]]
        let flashState = UserDefaults.standard.integer(forKey: FlashKey)
        let hdrState = UserDefaults.standard.integer(forKey: HdrKey)
        let delayState = UserDefaults.standard.integer(forKey: DelayKey)
        let flashImageName = optionImageArr[0][flashState]
        let hdrImageName = optionImageArr[1][hdrState]
        let delayImageName = optionImageArr[2][delayState]
        return [flashImageName,hdrImageName,delayImageName]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //TODO:Time
    func updateTimeLabel(time:Int) {
        let hours = time / 3600
        let minutes = (time - hours * 3600) / 60
        let seconds = time - hours * 3600 - minutes * 60
        
        timeLabel?.text = String(format: "%02d:%02d:%02d", hours,minutes,seconds)
    }
}
