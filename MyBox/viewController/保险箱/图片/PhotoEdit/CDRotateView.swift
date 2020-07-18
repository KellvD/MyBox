//
//  CDRotateBar.swift
//  MyRule
//
//  Created by changdong on 2019/6/26.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

enum NSRotateType :Int{
    case left = 1
    case right = 2
    case vertical = 3
    case horizontal = 4
}

protocol CDRotateBarDelegate {
    func onRoateBarDidSelected(rotate:NSRotateType)
}
class CDRotateView: UIImageView {

    var delegate:CDRotateBarDelegate!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.image = UIImage(named: "下导航-bg")

        let spqce0 = (frame.width - 4 * 45) / 5;

        //逆时针
        let leftRoate = UIButton(type:.custom)
        leftRoate.frame = CGRect(x: spqce0 , y: 1.5, width: 45, height: 45)
        leftRoate.setImage(UIImage(named: "逆时针旋转"), for: .normal)
        leftRoate.addTarget(self, action: #selector(onRoateClick(sender:)), for: .touchUpInside)
        leftRoate.tag = NSRotateType.left.rawValue
        self.addSubview(leftRoate)

        //顺时针
        let rightRoate = UIButton(type:.custom)
        rightRoate.frame = CGRect(x: spqce0 * 2 + 45 , y: 1.5, width: 45, height: 45)
        rightRoate.setImage(UIImage(named: "顺时针旋转"), for: .normal)
        rightRoate.addTarget(self, action: #selector(onRoateClick(sender:)), for: .touchUpInside)
        rightRoate.tag = NSRotateType.right.rawValue
        self.addSubview(rightRoate)

        //水平镜像
        let horizontal = UIButton(type:.custom)
        horizontal.frame = CGRect(x: spqce0 * 3 + 45 * 2 , y: 1.5, width: 45, height: 45)
        horizontal.setImage(UIImage(named: "水平镜像"), for: .normal)
        horizontal.addTarget(self, action: #selector(onRoateClick(sender:)), for: .touchUpInside)
        horizontal.tag = NSRotateType.horizontal.rawValue
        self.addSubview(horizontal)

        //垂直镜像
        let vertical = UIButton(type:.custom)
        vertical.frame = CGRect(x: spqce0 * 4 + 45 * 3 , y: 1.5, width: 45, height: 45)
        vertical.setImage(UIImage(named: "垂直镜像"), for: .normal)
        vertical.addTarget(self, action: #selector(onRoateClick(sender:)), for: .touchUpInside)
        vertical.tag = NSRotateType.vertical.rawValue
        self.addSubview(vertical)

    }

    @objc func onRoateClick(sender:UIButton){
        CDEditManager.shareInstance().editStep = NSEditStep.DidEdit    
        CDEditManager.shareInstance().onRoateBarDidSelected(rotate: NSRotateType(rawValue: sender.tag)!)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
