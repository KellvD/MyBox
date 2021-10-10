//
//  CDCircleProcess.swift
//  MyRule
//
//  Created by changdong on 2019/1/1.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import QuartzCore



class CDCircleProcess: UIView {
    var gProgress:Double!
    var shapLayer:CAShapeLayer!
    var textLabel:UILabel!

    override init(frame: CGRect) {

        super.init(frame: frame)
        self.backgroundColor = .clear
        
        let imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.image = UIImage(named: "record_timeProgressBG")
        self.addSubview(imageView)
        
        self.textLabel = UILabel(frame: CGRect(x: (frame.width - 90)/2, y: (frame.height - 50)/2, width: 90.0, height: 50.0))
        textLabel.font = UIFont.systemFont(ofSize: 32.0)
        textLabel.textColor = UIColor(red: 120/225.0, green: 120/225.0, blue: 120/225.0, alpha: 1)
        textLabel.textAlignment = .center
        self.addSubview(textLabel)
        
        shapLayer = CAShapeLayer.init()
        gProgress = 0.0
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
        let radian = -(Double.pi/4 * 2 / 3) - Double.pi * 2 * gProgress

        if shapLayer != nil {
            shapLayer.removeFromSuperlayer()
        }

        shapLayer.frame = CGRect(x: 0, y: 0, width: 132, height: 132)
        self.layer.addSublayer(shapLayer!)
        shapLayer.fillColor = UIColor.clear.cgColor
        shapLayer.backgroundColor = UIColor.clear.cgColor
        shapLayer.strokeColor = UIColor.customBlue.cgColor
        shapLayer.opacity = 1.0
        shapLayer.lineCap = .round
        shapLayer.lineWidth = CGFloat(circleWidth)
        let path:UIBezierPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(-(Double.pi/4 * 2 / 3)), endAngle: CGFloat(radian), clockwise: false)
        shapLayer.path = path.cgPath
        shapLayer.strokeEnd = 1
        self.layer.addSublayer(shapLayer)
    }

    public func changeProgress(progress:Double,text:String){
        gProgress = progress
        textLabel.text = text
        self.setNeedsDisplay()
    }

}
