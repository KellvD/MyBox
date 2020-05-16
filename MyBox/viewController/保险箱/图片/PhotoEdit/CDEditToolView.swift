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
        
        itemsView = CDEditorsView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.addSubview(itemsView)

//        let cropBar = CDCropView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
//        cropBar.tag = CDEditorsType.Crop.rawValue
//        self.addSubview(cropBar)
//        cropBar.isHidden = true
//
//        let filterBar = CDFilterView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
//        filterBar.tag = CDEditorsType.Filter.rawValue
//        self.addSubview(filterBar)
//        filterBar.isHidden = true
//
//        let brightView = CDBrightView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
//        brightView.tag = CDEditorsType.Bright.rawValue
//        self.addSubview(brightView)
//        brightView.isHidden = true
//
//        let rotateBar = CDRotateView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
//        rotateBar.tag = CDEditorsType.Rotate.rawValue
//        self.addSubview(rotateBar)
//        rotateBar.isHidden = true
//
//        let mosaicBar = CDMosaicView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
//        mosaicBar.tag = CDEditorsType.Mosaic.rawValue
//        self.addSubview(mosaicBar)
//        mosaicBar.isHidden = true
//
//        let waterBar = CDWatermarkView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
//        waterBar.tag = CDEditorsType.Watermark.rawValue
//        self.addSubview(waterBar)
//        waterBar.isHidden = true
//
//        let textBar = CDTextView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
//        textBar.tag = CDEditorsType.Text.rawValue
//        self.addSubview(textBar)
//        textBar.isHidden = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func setToolsStatus(){

        UIView.animate(withDuration: 0.5, animations: {
            var rect = self.frame
            rect.origin.y = CDSCREEN_HEIGTH
            self.frame = rect
        }) { (flag) in
            let view = self.viewWithTag(CDEditManager.shareInstance().editType.rawValue)!
            self.itemsView.isHidden = !self.itemsView.isHidden
            view.isHidden = !view.isHidden

            UIView.animate(withDuration: 0.5, animations: {
                var rect = self.frame
                rect.origin.y = CDSCREEN_HEIGTH - 48
                self.frame = rect
            })
        }


    }

}
