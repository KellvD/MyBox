//
//  CDTipsView.swift
//  MyBox
//
//  Created by changdong on 2021/9/17.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit

typealias CDTipsSelectedHandle = (_ tip:String)->()
class CDTipsView: UIView,
                  UICollectionViewDelegate,
                  UICollectionViewDataSource,
                  UICollectionViewDelegateFlowLayout {
    
    

    var selectedHandle:CDTipsSelectedHandle!
    private var gTips:[String] = []
    private var selectedIndex = 0
    init(frame:CGRect,tips:[String]) {
        gTips = tips
        super.init(frame: frame)
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.register(CDTipsCell.self, forCellWithReuseIdentifier: "CDTipCellId")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .baseBgColor
        self.addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gTips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDTipCellId", for:indexPath) as! CDTipsCell
        let title = gTips[indexPath.item]
        cell.setTitle(title: title)
        cell.isSelected(flag: selectedIndex == indexPath.item)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if gTips.count > 4 {
            let title = gTips[indexPath.item]
            let itemWidth=title.labelWidth(height: frame.height - 2, font: .large) + 20
            return CGSize(width: itemWidth, height: frame.height - 2)
        }else{
            return CGSize(width: (frame.width-40) / CGFloat(gTips.count), height: frame.height - 2)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let title = gTips[indexPath.item]
        
        selectedIndex = indexPath.item
        collectionView.reloadData()
        if (selectedHandle != nil) {
            selectedHandle(title)
        }
    }
}



private class CDTipsCell: UICollectionViewCell {
    
    private var titleLabel:UILabel!
    private var bottomLine:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width-1, height: frame.height - 2))
        titleLabel.font = .large
        titleLabel.textAlignment = .center
//        titleLabel.backgroundColor = .red
        self.contentView.addSubview(titleLabel)
    
        
        bottomLine = UIView(frame: CGRect(x: 3, y: frame.height - 1, width: frame.width-6, height: 1))
        bottomLine.backgroundColor = .navgationBarColor
        self.contentView.addSubview(bottomLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(title:String){
        titleLabel.text = title
    }
    
    func isSelected(flag:Bool){
        
        UIView.animate(withDuration: 0.25) {
            self.bottomLine.isHidden = !flag
        }
    }
}
