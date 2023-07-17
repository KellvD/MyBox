//
//  CDShareImageView.swift
//  Share
//
//  Created by cwx889303 on 2021/10/11.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

class CDShareImageView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var collectionView: UICollectionView!
    public var shareImageArr: [Any] = []
    override init(frame: CGRect) {
        super.init(frame: frame)

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 10, width: frame.width, height: frame.width + 30), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor.white
        collectionView.register(CDShareImageCell.self, forCellWithReuseIdentifier: "sharecollectionView_cellId")

        self.addSubview(collectionView)

        let sepertorbottom = UIView(frame: CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1))
        sepertorbottom.backgroundColor = UIColor(red: 243 / 255.0, green: 243 / 255.0, blue: 243 / 255.0, alpha: 1.0)
        self.addSubview(sepertorbottom)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shareImageArr.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if shareImageArr.count == 1 {
            return CGSize(width: collectionView.frame.width - 20, height: collectionView.frame.width - 20)
        } else {
            return CGSize(width: (collectionView.frame.width - 10 * 4) / 3.0, height: (collectionView.frame.width - 10 * 4) / 3.0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sharecollectionView_cellId", for: indexPath) as! CDShareImageCell
        let obj = shareImageArr[indexPath.item]
        cell.loadImageData(obj: obj)
        return cell
    }

    func loadImageData(obj: [Any]) {

        shareImageArr = obj
        collectionView.reloadData()
    }

}

private class CDShareImageCell: UICollectionViewCell {
    private var imageView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 2, y: 2, width: frame.width - 4, height: frame.height - 4))
        imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadImageData(obj: Any) {
        if obj is UIImage {
            self.imageView.image = (obj as! UIImage)
        } else {
            let url = obj as! URL
            let data = try? Data(contentsOf: url)
            if url.absoluteString.suffix.lowercased() == "gif" {
                self.imageView.image = UIImage.gif(data: data!)
            } else {
                self.imageView.image = UIImage(data: data!)
            }
        }
    }
}
