//
//  CDDirListBar.swift
//  MyRule
//
//  Created by changdong on 2020/4/19.
//  Copyright © 2020 changdong. All rights reserved.
//

import UIKit

@objc protocol CDDirNavBarDelegate {
    @objc func onSelectedDirWithFolderId(folderId: Int)
}
class CDDirNavBar: UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    weak var dirDelegate:CDDirNavBarDelegate!
    var collectionView:UICollectionView!
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: 2, y: 0, width: frame.width - 4, height: frame.height - 1), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CDDirListBarCell.self, forCellWithReuseIdentifier: "CDDirListBarCell")
        collectionView.backgroundColor = .white
        self.addSubview(collectionView)
        let line = UIView(frame: CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1))
        line.backgroundColor = TextLightGrayColor
        self.addSubview(line)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func reloadBarData() {
        
        self.collectionView.reloadData()
        self.collectionView.scrollToItem(at: IndexPath(item: CDSignalTon.shared.dirNavArr.count-1, section: 0), at: .centeredHorizontally, animated: true)
    }
    func numberOfItemsInSection(collectionView:UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CDSignalTon.shared.dirNavArr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identies = "CDDirListBarCell"
        let cell:CDDirListBarCell = collectionView.dequeueReusableCell(withReuseIdentifier: identies, for: indexPath) as! CDDirListBarCell
        var titleName = String()
        let folder = CDSignalTon.shared.dirNavArr[indexPath.item] as! CDSafeFolder
        titleName = folder.folderName
        if indexPath.item ==  CDSignalTon.shared.dirNavArr.count - 1{
            cell.titleLabel.text = titleName
            cell.bottomLine.isHidden = false
            cell.titleLabel.textColor = CustomBlueColor
        }else{
            cell.titleLabel.text = titleName + " > "
            cell.bottomLine.isHidden = true
            cell.titleLabel.textColor = TextLightGrayColor
        }
        var frame = cell.titleLabel.frame
        frame.size.width = cell.frame.width
        cell.titleLabel.frame = frame
        
        frame = cell.bottomLine.frame
        frame.size.width = cell.frame.width
        cell.bottomLine.frame = frame
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let folder = CDSignalTon.shared.dirNavArr[indexPath.item] as! CDSafeFolder
        let titleName = folder.folderName
        let width:CGFloat = CDGeneralTool.getStringWidth(string: titleName + " > ", height: 40, font: TextMidFont)
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let folder = CDSignalTon.shared.dirNavArr[indexPath.item] as! CDSafeFolder
        CDSignalTon.shared.dirNavArr.removeObjects(in: NSRange(location: indexPath.item + 1,length: CDSignalTon.shared.dirNavArr.count - 1 -  indexPath.item))
        self.reloadBarData()
        self.dirDelegate.onSelectedDirWithFolderId(folderId: folder.folderId)
    }
    
}

class CDDirListBarCell: UICollectionViewCell {
    var titleLabel:UILabel!
    var bottomLine:UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel = UILabel(frame: CGRect(x: 0, y: 2, width: frame.width, height: 40))
        titleLabel.font = TextMidFont
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        
        bottomLine = UIView(frame: CGRect(x: 0, y: 45, width: frame.width, height: 1.5))
        bottomLine.backgroundColor = .black
        self.addSubview(bottomLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
