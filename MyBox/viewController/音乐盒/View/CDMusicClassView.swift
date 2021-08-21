//
//  CDMusicClassView.swift
//  MyRule
//
//  Created by changdong on 2019/4/19.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

@objc protocol CDMusicClassDelegate:NSObjectProtocol {

    @objc func onSelectedOneMusicClassWithClassInfo(classInfo:CDMusicClassInfo)
}
class CDMusicClassView: UICollectionView,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {



    var classArr:[CDMusicClassInfo] = []
    weak var classDelegate:CDMusicClassDelegate!

    init(frame: CGRect) {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: (frame.width-50)/4, height: (frame.width-50)/4 + 20)
        super.init(frame: frame, collectionViewLayout: layout)
        self.delegate = self
        self.dataSource = self
        self.showsHorizontalScrollIndicator = false
        self.register(CDClassCell.self, forCellWithReuseIdentifier: "musicClassIdentify")
        self.backgroundColor = UIColor.white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.classArr.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identies = "musicClassIdentify"
        let cell:CDClassCell = collectionView.dequeueReusableCell(withReuseIdentifier: identies, for: indexPath) as! CDClassCell
        let classInfo:CDMusicClassInfo = classArr[indexPath.item]
        cell.onUpdateClassInfo(classInfo: classInfo)

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let classInfo:CDMusicClassInfo = classArr[indexPath.item]
        self.classDelegate.onSelectedOneMusicClassWithClassInfo(classInfo: classInfo)
    }
}
