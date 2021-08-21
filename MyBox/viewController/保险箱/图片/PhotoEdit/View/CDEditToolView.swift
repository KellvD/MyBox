//
//  CDEditToolBar.swift
//  MyRule
//
//  Created by changdong on 2019/6/26.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit


class CDEditToolView: UIView,CDEditorsViewDelegate {
    var itemsView:CDEditorsView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.backgroundColor = .black
        
        
        itemsView = CDEditorsView(frame: CGRect(x: 0, y: 48, width: frame.width, height: 48))
        itemsView.backgroundColor = .black
        self.addSubview(itemsView)
        itemsView.bringSubviewToFront(self)


    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func setToolsStatus(){

//        UIView.animate(withDuration: 0.5, animations: {
//            var rect = self.frame
//            rect.origin.y = CDSCREEN_HEIGTH
//            self.frame = rect
//        }) { (flag) in
//            let view = self.viewWithTag(CDEditManager.shareInstance().editType.rawValue)!
//            self.itemsView.isHidden = !self.itemsView.isHidden
//            view.isHidden = !view.isHidden
//
//            UIView.animate(withDuration: 0.5, animations: {
//                var rect = self.frame
//                rect.origin.y = CDSCREEN_HEIGTH - 48
//                self.frame = rect
//            })
//        }


    }

}



