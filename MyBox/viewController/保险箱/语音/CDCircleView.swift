//
//  CDCircleView.swift
//  MyRule
//
//  Created by changdong on 2019/1/1.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import QuartzCore



class CDCircleView: UIView {
    var progress:Double!
    var shapLayer:CAShapeLayer!


    override init(frame: CGRect) {

        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        shapLayer = CAShapeLayer.init()
        progress = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let center_x = rect.width/2
        let center_y = rect.height/2
        let center = CGPoint(x: center_x, y: center_y)
        let radius = center_x - 4.0
        let circleWidth = 3.0
        let radian = -(M_PI_4 * 2 / 3) - M_PI * 2 * progress

        if shapLayer != nil {
            shapLayer.removeFromSuperlayer()
        }

        shapLayer.frame = CGRect(x: 0, y: 0, width: 132, height: 132)
        self.layer.addSublayer(shapLayer!)
        shapLayer.fillColor = UIColor.clear.cgColor
        shapLayer.backgroundColor = UIColor.clear.cgColor
        shapLayer.strokeColor = CustomBlueColor.cgColor
        shapLayer.opacity = 1.0
        shapLayer.lineCap = .round
        shapLayer.lineWidth = CGFloat(circleWidth)
        let path:UIBezierPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(-(M_PI_4 * 2 / 3)), endAngle: CGFloat(radian), clockwise: false)
        shapLayer.path = path.cgPath
        shapLayer.strokeEnd = 1
        self.layer.addSublayer(shapLayer)
    }

    public func changeProgress(progr:Double){
        progress = progr
        self.setNeedsDisplay()
    }

}
