//
//  CDPhotoEditToolBar.swift
//  PhotoEdit
//
//  Created by changdong on 2019/5/13.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit

@objc protocol CDEditorsViewDelegate {
    @objc optional func onSelectEditorWith(model:CDEditorsModel)->Void
}

class CDEditorsView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource {
    private var tools:[CDEditorsModel] = []
    weak var mDelegate:CDEditorsViewDelegate?

    init(frame:CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:(frame.width - 30)/5 , height: 48)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .horizontal
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = UIColor.black
        self.delegate = self
        self.dataSource = self
        self.register(CDPhotoEditCell.self, forCellWithReuseIdentifier: "PhotoEditCellIdentify")
        let titleArr = ["裁剪","滤镜","亮度","旋转","马赛克","水印","文字"]
        for i in 0..<titleArr.count {
            let model = CDEditorsModel()
            model.title = titleArr[i]
            model.type = CDEditorsType(rawValue: i)
            tools.append(model)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tools.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoEditCellIdentify", for: indexPath) as! CDPhotoEditCell
        let item = tools[indexPath.item]
        cell.loadData(itemStr: item.title)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        CDEditManager.shareInstance().editStep = .WillEdit
//        CDEditManager.shareInstance().editType = CDEditorsType(rawValue: indexPath.item + 1)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didSelectedEdtors"), object: "\(indexPath.item + 1)", userInfo: nil)

        let item = tools[indexPath.item]
        mDelegate?.onSelectEditorWith?(model: item)

    }

}

class CDPhotoEditCell: UICollectionViewCell {

    private var itemLabel:UILabel!
    private var imageView:UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: frame.width/2 - 9, y: 9, width: 18, height: 14))
        imageView.isUserInteractionEnabled = true
        self.addSubview(imageView)

        itemLabel = UILabel(frame: CGRect(x: 2, y: 28, width: frame.width - 4, height: 16))
        itemLabel.font = UIFont.systemFont(ofSize: 12)
        itemLabel.textColor = UIColor.white
        itemLabel.textAlignment = .center
        self.addSubview(itemLabel)

    }

    func loadData(itemStr:String){
        itemLabel.text = itemStr
        imageView.image = UIImage(named: itemStr)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
