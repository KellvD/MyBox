//
//  CDPreviewView.swift
//  MyRule
//
//  Created by changdong on 2018/12/15.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos
@objc protocol CDFollowPreviewDelegate {
    @objc optional func selectFollowWith(indexPath:IndexPath)->Void
}
@objc protocol CDMainPreviewDelegate {
    @objc optional func scrollMainPreview(indexPath:IndexPath)
    @objc optional func selectMainPreview()
}
class CDPreviewView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource {

    
    var assetArr:[CDPHAsset] = []
    var itemW:CGFloat = 0
    var itemH:CGFloat = 0
    var _isMian:Bool = false
    var isVideo:Bool!
    var identify:String!
    var selectitem = 0
    var currentOffset = 0.0




    weak var followDelegete:CDFollowPreviewDelegate?
    weak var mainDelegete:CDMainPreviewDelegate?
    init(frame:CGRect, layout:UICollectionViewFlowLayout,isMain:Bool) {
        super.init(frame: frame, collectionViewLayout: layout)
        _isMian = isMain
        self.delegate = self
        self.dataSource = self
        if isMain {
            identify = "mainPreviewIdentify"
        }else{
            identify = "followPreviewIdentify"
        }
        self.register(CDPreviewCell.self, forCellWithReuseIdentifier: identify)
 
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.assetArr.count

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identify, for: indexPath) as! CDPreviewCell



        if selectitem == indexPath.row &&
            !_isMian{
            cell.isShow = true
        }else{
            cell.isShow = false
        }
        let asset:CDPHAsset = self.assetArr[indexPath.item]
        if isVideo{
            cell.setVideoToView(cdAsset: asset, isMain: _isMian)
        }else{
            cell.setImageToView(cdAsset: asset, isMain: _isMian)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if !_isMian {
            selectitem = indexPath.item
            self.followDelegete?.selectFollowWith!(indexPath: indexPath)
            self.reloadData()

        }else{
            self.mainDelegete?.selectMainPreview!()
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if _isMian {
            let offet = scrollView.contentOffset.x/itemW
            let index = Int(roundf(Float(offet)))
            let indexPath:IndexPath = IndexPath(item: index, section: 0)
            self.mainDelegete?.scrollMainPreview!(indexPath: indexPath)

        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if _isMian {
        //暂停上次播放的
        let offet = scrollView.contentOffset.x/itemW
        let index = Int(roundf(Float(offet)))
        let cell:CDPreviewCell = self.cellForItem(at: IndexPath(item: index, section: 0)) as! CDPreviewCell
        cell.stopPlayer()
        }
    }


}
