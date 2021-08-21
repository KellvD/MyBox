//
//  CDColorPicker.swift
//  CDTextViewDemo
//
//  Created by changdong cwx889303 on 2020/9/10.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit
//本界面复用的样式     前三个对应CDTextTools
enum CDPickerType:Int {
    case textColor = 7    //字体颜色选择界面
    case textBgColor = 8  //字体背景颜色选择界面
    case symbol = 12       //段落符号选择
    case viewBgColor = 13  //背景颜色选择界面
}

class CDPickerView: UIView,UICollectionViewDelegate,
UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    private var collectionView:UICollectionView!
    private var gIndexPath:IndexPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = BaseBackGroundColor
        let layout = UICollectionViewFlowLayout()
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height -  48), collectionViewLayout: layout)
        collectionView.register(CDBaseCollectionViewCell.self, forCellWithReuseIdentifier: "CDPickerCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = BaseBackGroundColor
        self.addSubview(collectionView!)
        
        let button = UIButton(type: .custom)
        button.setTitle(LocalizedString("sure"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(onDismissView), for: .touchUpInside)
        button.layer.cornerRadius = 10
        self.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalTo(frame.width/2 )
            make.size.equalTo(CGSize(width: 60, height: 48))
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy private var fontColorArr: [UIColor] = {
        let arr:[UIColor] = [.white,.lightGray,.gray,.darkGray,.red,.green,.blue,.cyan,.yellow,.magenta,.orange,.purple,.brown,.black]
        return arr
    }()
    
    lazy private var viewColorArr: [UIColor] = {
        let arr:[UIColor] = [.white,.lightGray,.gray,.darkGray,.red,.green,.blue,.cyan,.yellow,.magenta,.orange,.purple,.brown,.black]
        return arr
    }()
    
    lazy private var symbolArr: Array<String> = {
        var arr = Array<String>()
        for i in 0..<8{
            arr.append("项目符号0\(i)")
        }
        return arr
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if CDTextViewConfig.share.pickType == .viewBgColor {
            return viewColorArr.count
        }else if CDTextViewConfig.share.pickType == .symbol{
            return symbolArr.count
        }else{
            return fontColorArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDPickerCell", for: indexPath) as! CDBaseCollectionViewCell
        cell.contentView.layer.borderColor = PickFalgColor.cgColor
        if indexPath == gIndexPath{
            cell.contentView.layer.borderWidth = 2
        }else{
            cell.contentView.layer.borderWidth = 0
        }
        cell.contentView.backgroundColor = BaseBackGroundColor
        
        
        
        if CDTextViewConfig.share.pickType == .viewBgColor {
            cell.contentView.backgroundColor = viewColorArr[indexPath.item]
        }else if CDTextViewConfig.share.pickType == .symbol{
            cell.loadOption(optionName: symbolArr[indexPath.item])
        }else{
            cell.contentView.backgroundColor = fontColorArr[indexPath.item]
        }
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if CDTextViewConfig.share.pickType == .viewBgColor {
            return CGSize(width:(frame.width - 25)/3 , height: frame.height - 48 - 20)
        }else if CDTextViewConfig.share.pickType == .symbol{
            return CGSize(width:48 , height: 48)
        }else{
            let itemW = (frame.width - 25)/6
            return CGSize(width:itemW , height: itemW)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if CDTextViewConfig.share.pickType == .symbol{
            return 10
        }else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if CDTextViewConfig.share.pickType == .symbol{
            return 10
        }else{
            return 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if CDTextViewConfig.share.pickType == .viewBgColor {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }else if CDTextViewConfig.share.pickType == .symbol{
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }else{
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if CDTextViewConfig.share.pickType == .viewBgColor {
            let itemColor = viewColorArr[indexPath.item];
            CDTextViewConfig.share.textViewBgColor = itemColor
        }else if CDTextViewConfig.share.pickType == .textColor{
            CDTextViewConfig.share.fontColor = fontColorArr[indexPath.item]
        }else if CDTextViewConfig.share.pickType == .textBgColor{
            CDTextViewConfig.share.fontbgColor = fontColorArr[indexPath.item]
        }else{
            CDTextViewConfig.share.paragraphSymbol = UIImage(named: symbolArr[indexPath.item])
        }
        
        CDTextViewConfig.share.updateTextView()
        gIndexPath = indexPath
        collectionView.reloadData()
    }
    
    
    @objc private func onDismissView(){
        
        CDTextViewConfig.share.removeInputView(view: self)
        if CDTextViewConfig.share.pickType != .viewBgColor {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changePickerValue"), object: nil)
        }
    }
    
    
    func reloadView(){
        collectionView.reloadData()
    }
    
}
