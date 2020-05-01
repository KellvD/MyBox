//
//  CDCropBar.swift
//  PhotoEdit
//
//  Created by changdong on 2019/5/15.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit


enum CorpBarItem:Int {
    case cancle = 1
    case restore = 2
    case save = 3
}

enum CorpBarView:Int {
    case One_One = 1     //1:1
    case Four_Three = 2  //4:3
    case Three_Four = 3  //3:4
    case Nine_Sixthree = 4  //9:16
    case Sixthree_Nine = 5  //16:9
}
protocol CDCorpToolsViewDelegate {
    func onSelectCorpView(barItem:CorpBarView)
    func onSelectCorpToolBar(barItem:CorpBarItem)

}
let toolsBarHeight:CGFloat = 40.0

class CDCropToolsBar: UIView {

    var delegate:CDCorpToolsViewDelegate!
    var toolViewArr:[toolView] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.green

        let itemW:CGFloat = 48
        let marginViewSpace = (frame.width - 48.0 * 5)/6
        let itemTitles = ["1:1","4:3","3:4","16:9","9:16"]
        for i in 0..<5{
            let scale = scaleFromTitle(title: itemTitles[i])

            let item = toolView(frame: CGRect(x: marginViewSpace + CGFloat(i) * (itemW + marginViewSpace), y: 5, width: itemW, height: 90), title: itemTitles[i], scale: scale)
            item.tag = i + 1
            item.isUserInteractionEnabled = true
            self.addSubview(item)
            let tap = UITapGestureRecognizer(target: self, action: #selector(onSelectedToolView(tap:)))
            item.addGestureRecognizer(tap)
            toolViewArr.append(item)
        }
        let lineV = UIView(frame: CGRect(x: 0, y: 99, width: frame.width, height: 1))
        lineV.backgroundColor = UIColor.gray
        lineV.alpha = 0.8
        self.addSubview(lineV)

        let marginX:CGFloat = 15.0
        let btnWidth:CGFloat = 40
        let marginBtnSpace:CGFloat = (frame.width - marginX * 2 - 120) / 2
        let buttonTitles = ["取消","还原","保存"]

        for i in 0..<3 {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: marginX + CGFloat(i) * (marginBtnSpace + btnWidth), y: 100, width: btnWidth, height: btnWidth)
            button.addTarget(self, action: #selector(btnClickResponce(button:)), for: .touchUpInside)
            button.tag = i + 1
            button.setTitle(buttonTitles[i], for: .normal)
            self.addSubview(button)
        }


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func btnClickResponce(button:UIButton){
        delegate.onSelectCorpToolBar(barItem: CorpBarItem(rawValue: button.tag)!)
    }

    func scaleFromTitle(title:String) -> CGFloat {
        let titleArr:[String] = title.components(separatedBy: ":")

        let width = (titleArr.first! as NSString).floatValue
        let height = (titleArr.last! as NSString).floatValue

        return CGFloat(width/height)

    }
    @objc func onSelectedToolView(tap:UITapGestureRecognizer){
        delegate.onSelectCorpView(barItem: CorpBarView(rawValue: tap.view!.tag)!)

        for item:toolView in toolViewArr {
            item.selected(flag: false)
        }

        let item = tap.view as! toolView
        item.selected(flag: true)

    }

}


class toolView: UIView {

    var label:UILabel!
    var borderView:UIView!


    init(frame:CGRect,title:String,scale:CGFloat) {
        super.init(frame: frame)
        var height = frame.height - 20
        var width = frame.width

        height = width / scale
        if height > frame.height - 20{
            height = frame.height - 20
            width = scale * height
        }
        borderView = UIView(frame: CGRect(x: (frame.width - width)/2, y: (frame.height - 20 - height)/2 + 5, width: width, height: height))
        borderView.layer.borderWidth = 1.5
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.isUserInteractionEnabled = true
        self.addSubview(borderView)


        label = UILabel(frame: CGRect(x: 0, y: frame.height - 15, width: frame.width, height: 15))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.blue
        label.text = title
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func selected(flag:Bool) {

        borderView.layer.borderWidth = flag == true ? 3.0 : 1.5
    }
}
