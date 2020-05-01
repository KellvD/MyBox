//
//  CDCameraTopBar.swift
//  MyRule
//
//  Created by changdong on 2019/5/24.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDCameraTopBar: UIView {

    var timeLabel:UILabel?

    
    init(frame:CGRect,isVideo:Bool) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.alpha = 0.3
        if isVideo{
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 15, y: 4, width: 40, height: 40);
            button.addTarget(self, action: #selector(flashFightClick), for: .touchUpInside)
            self.addSubview(button)


            timeLabel = UILabel(frame: CGRect(x: button.frame.maxX + 25, y: 4, width: frame.width - (button.frame.maxX + 25) * 2 , height: 40))
            timeLabel?.textColor = UIColor.white
            timeLabel?.font = TextMidFont
            timeLabel?.text = "00:00:00"
            timeLabel?.textAlignment = .center
            self.addSubview(timeLabel!)

            let formatLebel = UILabel(frame: CGRect(x: frame.width - 80, y: 4, width: 80, height: 40))
            formatLebel.textAlignment = .center
            formatLebel.font = TextMidFont
            formatLebel.textColor = UIColor.white
            self.addSubview(formatLebel)
        }
    }

    @objc func flashFightClick(){

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
