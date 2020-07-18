//
//  CDNavigationBar.swift
//  MyRule
//
//  Created by changdong on 2019/6/26.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

enum NSNavigationBarType:Int {
    case back = 1
    case backward = 2
    case save = 3
    case cancle = 4
    case done = 5
}
protocol CDNavigationBarDelegate {
    func onCDNavigationBarItemDidSelected(type: NSNavigationBarType)
}
class CDNavigationBar: UIImageView {

    var backItem:UIButton!
    var backwardItem:UIButton!
    var saveItem:UIButton!


    var cancleItem:UIButton!
    var doneItem:UIButton!
    var delegate:CDNavigationBarDelegate!


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.gray
        CDEditManager.shareInstance().naviBar = self

        backItem = UIButton(type: .custom)
        backItem.frame = CGRect(x: 15, y: 1.5 + 20, width: 45, height: 45)
        backItem.setImage(UIImage(named: "back_normal"), for: .normal)
        backItem.addTarget(self, action: #selector(onCDNavigationBarItemClick(sender:)), for: .touchUpInside)
        backItem.tag = NSNavigationBarType.back.rawValue
        self.addSubview(backItem)

        backwardItem = UIButton(type: .custom)
        backwardItem.frame = CGRect(x: frame.width/2 - 45/2, y: 1.5 + 20, width: 45, height: 45)
        backwardItem.setImage(UIImage(named: "backward"), for: .normal)
        backwardItem.setImage(UIImage(named: "backward_disable"), for: .disabled)
        backwardItem.addTarget(self, action: #selector(onCDNavigationBarItemClick(sender:)), for: .touchUpInside)
        backwardItem.tag = NSNavigationBarType.backward.rawValue
        self.addSubview(backwardItem)

        saveItem = UIButton(type: .custom)
        saveItem.frame = CGRect(x: frame.width - 15 - 45, y: 1.5 + 20, width: 45, height: 45)
        saveItem.setTitle("保存", for: .normal)
        saveItem.addTarget(self, action: #selector(onCDNavigationBarItemClick(sender:)), for: .touchUpInside)
        saveItem.tag = NSNavigationBarType.save.rawValue
        self.addSubview(saveItem)

        cancleItem = UIButton(type: .custom)
        cancleItem.frame = CGRect(x: 15, y: 1.5 + 20, width: 45, height: 45)
        cancleItem.setTitle("取消", for: .normal)
        cancleItem.addTarget(self, action: #selector(onCDNavigationBarItemClick(sender:)), for: .touchUpInside)
        cancleItem.tag = NSNavigationBarType.cancle.rawValue
        self.addSubview(cancleItem)

        doneItem = UIButton(type: .custom)
        doneItem.frame = CGRect(x: frame.width - 15 - 45, y: 1.5 + 20, width: 45, height: 45)
        doneItem.setTitle("完成", for: .normal)
        doneItem.addTarget(self, action: #selector(onCDNavigationBarItemClick(sender:)), for: .touchUpInside)
        doneItem.tag = NSNavigationBarType.done.rawValue
        self.addSubview(doneItem)
        self.cancleItem.isHidden = true
        self.backwardItem.isHidden = true
        self.doneItem.isHidden = true
        self.backItem.isHidden = false
        self.saveItem.isHidden = false
    }
    
    @objc func setNavigationsStatus(){
        if CDEditManager.shareInstance().editStep == NSEditStep.NOTEdit  {
            UIView.animate(withDuration: 0.5, animations: {
                var rect = self.frame
                rect.origin.y = rect.origin.y - rect.height
                self.frame = rect

            }) { (flag) in
                self.cancleItem.isHidden = true
                self.backwardItem.isHidden = true
                self.doneItem.isHidden = true
                self.backItem.isHidden = false
                self.saveItem.isHidden = false
                UIView.animate(withDuration: 1, animations: {
                    var rect = self.frame
                    rect.origin.y = rect.origin.y + rect.height
                    self.frame = rect
                }, completion: { (flag) in

                })
            }
        }else if CDEditManager.shareInstance().editStep == NSEditStep.WillEdit  {
            UIView.animate(withDuration: 0.5, animations: {
                var rect = self.frame
                rect.origin.y = rect.origin.y - rect.height
                self.frame = rect

            }) { (flag) in
                self.backItem.isHidden = true
                self.saveItem.isHidden = true
                self.cancleItem.isHidden = false
                self.backwardItem.isHidden = false
                self.backwardItem.isEnabled = false
                self.doneItem.isHidden = false

                UIView.animate(withDuration: 0.5, animations: {
                    var rect = self.frame
                    rect.origin.y = rect.origin.y + rect.height
                    self.frame = rect
                }, completion: { (flag) in

                })
            }



        }else if CDEditManager.shareInstance().editStep == NSEditStep.DidEdit  {
            backItem.isHidden = true
            saveItem.isHidden = true

            cancleItem.isHidden = false
            backwardItem.isHidden = false
            backwardItem.isEnabled = true
            doneItem.isHidden = false
        }
    }


    @objc func onCDNavigationBarItemClick(sender:UIButton){
        delegate.onCDNavigationBarItemDidSelected(type: NSNavigationBarType.init(rawValue: sender.tag)!)
    }




    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
