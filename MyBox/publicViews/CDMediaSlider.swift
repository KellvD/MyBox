//
//  CDMediaSlider.swift
//  MyBox
//
//  Created by changdong on 2021/8/13.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

protocol CDMediaSliderDelegate {
    func sliderDidChange(value:Float)
}

class CDMediaSlider: UIView {
    
    var delegate:CDMediaSliderDelegate!
    
    init(frame: CGRect,timeLength:Double) {
        super.init(frame: frame)
        self.addSubview(self.hasPlayTimeLab)
        self.addSubview(self.remainTimeLab)
        
        self.sliderView.frame = CGRect(x: self.hasPlayTimeLab.maxX + 5, y: 14, width: self.remainTimeLab.minX - self.hasPlayTimeLab.maxX - 10, height: 20)
        self.addSubview(self.sliderView)
        
        self.sliderView.maximumValue = Float(timeLength)
        self.remainTimeLab.text = GetMMSSFromSS(timeLength: timeLength)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var hasPlayTimeLab: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 14, width: 35, height: 20))
        label.textColor = .textGray
        label.backgroundColor = UIColor.clear
        label.font = .small
        label.text = GetMMSSFromSS(timeLength: 0)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var remainTimeLab: UILabel = {
        let label = UILabel(frame: CGRect(x: frame.width - 35.0 - 20.0, y: 14, width: 35, height: 20))
        label.textColor = .textGray
        label.backgroundColor = UIColor.clear
        label.font = .small
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var sliderView: UISlider = {
        let slider = UISlider()
        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(onSliderChangePlayTime), for: .valueChanged)
        return slider
    }()
    
    
    
    func updateProcess(process:Double){
        DispatchQueue.main.async {
            self.sliderView.value = Float(process)
            self.hasPlayTimeLab.text = GetMMSSFromSS(timeLength: process)
        }
        
    }
    
    
    @objc func onSliderChangePlayTime(){
        if delegate != nil{
            delegate.sliderDidChange(value: sliderView.value)
        }
        self.hasPlayTimeLab.text = GetMMSSFromSS(timeLength: Double(sliderView.value))
        
        
    }
    
}
