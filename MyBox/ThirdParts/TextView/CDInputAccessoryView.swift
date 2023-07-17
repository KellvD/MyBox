//
//  CDInputAccessoryView.swift
//  CDTextViewDemo
//
//  Created by changdong on 2020/9/9.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

class CDInputAccessoryView: UIView, UICollectionViewDelegate,
UICollectionViewDataSource {

    private var collectionView: UICollectionView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .baseBgColor
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: frame.height, height: frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal

        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: frame.height), collectionViewLayout: layout)
        collectionView.register(CDBaseCollectionViewCell.self, forCellWithReuseIdentifier: "CDInputAccessoryViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .baseBgColor
        self.addSubview(collectionView!)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy private var imageArr: [String] = {
        let arr = ["背", "样式", "图库", "涂鸦"]
        return arr
    }()

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return imageArr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CDInputAccessoryViewCell", for: indexPath) as! CDBaseCollectionViewCell
        let optionName = imageArr[indexPath.item]
        cell.loadOption(optionName: optionName)
        return cell

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        CDTextViewConfig.share.handleAccessoryOption(item: indexPath.item)

    }
}

class CDBaseCollectionViewCell: UICollectionViewCell {

    private var imageView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView(frame: CGRect(x: 8, y: 8, width: 32, height: 32))
        imageView.isHidden = true
        self.contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadOption(optionName: String) {
        imageView.isHidden = false
        imageView.image = UIImage(named: optionName)
    }
}
