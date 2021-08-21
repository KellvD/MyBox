//
//  CDMediaSlider.swift
//  MyBox
//
//  Created by cwx889303 on 2021/8/13.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit


class CDMediaSlider: UIView {
    
    var sliderValueChange:((_ value:Double) -> Void)!
    private var _timeLength:Double!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.hasPlayTimeLab)
        self.addSubview(self.remainTimeLab)
        
        self.sliderView.frame = CGRect(x: self.hasPlayTimeLab.maxX + 5, y: 14, width: self.remainTimeLab.minX - self.hasPlayTimeLab.maxX - 10, height: 20)
        self.addSubview(self.sliderView)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var hasPlayTimeLab: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 14, width: 35, height: 20))
        label.textColor = TextGrayColor
        label.backgroundColor = UIColor.clear
        label.font = TextSmallFont
        label.text = GetMMSSFromSS(second: 0)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var remainTimeLab: UILabel = {
        let label = UILabel(frame: CGRect(x: frame.width - 35.0 - 20.0, y: 14, width: 35, height: 20))
        label.textColor = TextGrayColor
        label.backgroundColor = UIColor.clear
        label.font = TextSmallFont
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var sliderView: UISlider = {
        let slider = UISlider()
        slider.setThumbImage(UIImage(named: "sliderPoint"), for: .normal)
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(onSliderChangePlayTime), for: .valueChanged)
        return slider
    }()
    
    var timeLength: Double {
        get {
            return _timeLength
        }
        set {
            _timeLength = newValue
            self.sliderView.maximumValue = Float(newValue)
            self.remainTimeLab.text = GetMMSSFromSS(second: newValue)
        }
    }
    
    
    func updateProcess(process:Double){
        DispatchQueue.main.async {
            self.sliderView.value = Float(process)
            self.hasPlayTimeLab.text = GetMMSSFromSS(second: process)
        }
        
    }
    
    
    @objc func onSliderChangePlayTime(){
        sliderValueChange(Double(sliderView.value))
        self.hasPlayTimeLab.text = GetMMSSFromSS(second: Double(sliderView.value))
        
        
    }
    
}
