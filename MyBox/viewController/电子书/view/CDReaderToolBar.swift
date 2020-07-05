//
//  CDReaderToolBar.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/6/29.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

enum CDReaderBgModel:Int {
    case day = 1001
    case night = 1002
    case eye = 1003
}
protocol CDReaderToolBarDelegate {
    func onPopChapterView()
    func onChangeChapters(index:Int)
    func onChangeBgModel(model:CDReaderBgModel)
}
class CDReaderToolBar: UIView {

    var chapterLabel:UILabel!
    var chapterSlider:UISlider!  //章节slider
    var bgModel:CDReaderBgModel! //护眼模式
    var chapterTotalCount:Int = 0 //总章节数
    var chapterCurrentCount:Int = 0 //当前章节数
    var delegate:CDReaderToolBarDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //显示章节名称
        chapterLabel = UILabel(frame: CGRect(x: 30, y: 15, width: frame.width - 60, height: 48))
        chapterLabel.font = TextMidFont
        chapterLabel.textAlignment = .center
        chapterLabel.textColor = .white
        self.addSubview(chapterLabel)
        
        //章节—
        let chapterReduceBtn = UIButton(type: .custom)
        chapterReduceBtn.frame = CGRect(x: 15, y: chapterLabel.frame.maxY + 15, width: 30, height: 30)
        chapterReduceBtn.setImage(LoadImageByName(imageName: "", type: "png"), for: .normal)
        chapterReduceBtn.tag = 101
        chapterReduceBtn.addTarget(self, action: #selector(changeChapter(_:)), for: .touchUpInside)
        self.addSubview(chapterReduceBtn)
        
        //章节+
        let chapterAddBtn = UIButton(type: .custom)
        chapterAddBtn.frame = CGRect(x: frame.width - 15 - 30, y: chapterLabel.frame.maxY + 15, width: 30, height: 30)
        chapterAddBtn.setImage(LoadImageByName(imageName: "", type: "png"), for: .normal)
        chapterAddBtn.tag = 102
        chapterAddBtn.addTarget(self, action: #selector(changeChapter(_:)), for: .touchUpInside)
        self.addSubview(chapterAddBtn)
        
        //章节进度
        chapterSlider = UISlider(frame: CGRect(x: chapterReduceBtn.frame.maxX + 10, y: chapterReduceBtn.frame.minX, width: frame.width - 55 * 2, height: 30))
        chapterSlider.addTarget(self, action: #selector(dragToChangeChapter(_:)), for: .valueChanged)
        self.addSubview(chapterSlider)
        chapterSlider.minimumValue = 0.0
        chapterSlider.maximumValue = Float(chapterTotalCount)
        chapterSlider.value = Float(chapterCurrentCount)
        //字体-
        let fontReduceBtn = UIButton(type: .custom)
        fontReduceBtn.frame = CGRect(x: 15, y: chapterSlider.frame.maxY + 15, width: 50, height: 30)
        fontReduceBtn.setImage(LoadImageByName(imageName: "", type: "png"), for: .normal)
        fontReduceBtn.tag = 301
        fontReduceBtn.addTarget(self, action: #selector(changeChapter(_:)), for: .touchUpInside)
        self.addSubview(fontReduceBtn)
        
        //字体+
        let fontAddBtn = UIButton(type: .custom)
        fontAddBtn.frame = CGRect(x: frame.width - 15 - 30, y: chapterLabel.frame.maxY + 15, width: 30, height: 30)
        fontAddBtn.setImage(LoadImageByName(imageName: "", type: "png"), for: .normal)
        fontAddBtn.tag = 102
        fontAddBtn.addTarget(self, action: #selector(changeChapter(_:)), for: .touchUpInside)
        self.addSubview(fontAddBtn)
        
        //章节
        let chapterBtn = UIButton(type: .custom)
        chapterBtn.frame = CGRect(x: frame.minX - 100, y: frame.maxY - 50, width: 48, height: 48)
        chapterBtn.setImage(LoadImageByName(imageName: "", type: "png"), for: .normal)
        chapterBtn.addTarget(self, action: #selector(popChapterView), for: .touchUpInside)
        self.addSubview(chapterBtn)
        
        //模式：白天=1001，夜晚=1002，护眼=1003
        let modelName = bgModel == .day ? "白天模式-黑" : bgModel == .night ? "夜晚模式-白" : "护眼模式"
        let bgBtn = UIButton(type: .custom)
        bgBtn.frame = CGRect(x: frame.minX + 52, y: chapterBtn.frame.minY, width: 48, height: 48)
        bgBtn.setImage(LoadImageByName(imageName: modelName, type: "png"), for: .normal)
        bgBtn.addTarget(self, action: #selector(changeBgModel(_:)), for: .touchUpInside)
        self.addSubview(bgBtn)
    }
    
    @objc private func changeChapter(_ sender:UIButton) {
        
        if chapterCurrentCount <= 0 || chapterTotalCount > chapterTotalCount {
            return
        }
        if sender.tag == 101 {
            chapterCurrentCount -= 1
        } else {
            chapterCurrentCount += 1
        }
        chapterSlider.value = Float(chapterCurrentCount)
        delegate!.onChangeChapters(index: chapterCurrentCount)
    }
    
    @objc private func dragToChangeChapter(_ sender:UISlider) {
        chapterCurrentCount = Int(sender.value)
        delegate!.onChangeChapters(index: chapterCurrentCount)
    }
    
    @objc private func popChapterView(){
        
        delegate!.onPopChapterView()
    }
    
    @objc private func changeBgModel(_ sender:UIButton) {
        if bgModel == .day {
            bgModel = .night
        } else if bgModel == .night {
            bgModel = .eye
        } else if bgModel == .eye {
            bgModel = .day
        }
        let modelName = bgModel == .day ? "白天模式-黑" : bgModel == .night ? "夜晚模式-白" : "护眼模式"
        sender.setImage(LoadImageByName(imageName: modelName, type: "png"), for: .normal)
        CDConfigFile.setIntValueToConfigWith(key: CD_ReaderBgModel, intValue: sender.tag)
        delegate!.onChangeBgModel(model: bgModel)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
