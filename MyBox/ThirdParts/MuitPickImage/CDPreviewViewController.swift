//
//  CDPreviewViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/14.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos

class CDPreviewViewController: UIViewController,CDMainPreviewDelegate,CDFollowPreviewDelegate {

    public var assetArr:[CDPHAsset] = []
    public var isVideo:Bool!
    public var assetDelegate:CDAssetSelectedDelagete!

    private let bottom_H:CGFloat = 85+48+1
    private var mainCollectionView:CDPreviewView!
    private var followCollectionView:CDPreviewView!
    private var imageManager:PHCachingImageManager!
    private var editBtn:UIButton!
    private var sendBtn:UIButton!
    private var bottomV:UIView!


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopMainPreviewPlay()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let mainLayout = UICollectionViewFlowLayout()
        mainLayout.itemSize = CGSize(width:CDSCREEN_WIDTH, height: CDViewHeight - 64)
        mainLayout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        mainLayout.minimumLineSpacing = 2
        mainLayout.minimumInteritemSpacing = 2
        mainLayout.scrollDirection = .horizontal
        self.mainCollectionView = CDPreviewView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), layout: mainLayout,isMain: true)

        self.mainCollectionView.assetArr = assetArr
        self.mainCollectionView.isVideo = isVideo
        self.mainCollectionView.itemW = CDSCREEN_WIDTH
        self.mainCollectionView.itemH = CDViewHeight
        self.mainCollectionView.mainDelegete = self
        self.mainCollectionView.backgroundColor = UIColor.black
        self.mainCollectionView.isPagingEnabled = true
        self.view.addSubview(self.mainCollectionView)


        bottomV = UIView(frame: CGRect(x: 0, y: CDViewHeight-bottom_H, width: CDSCREEN_WIDTH, height: bottom_H))
        bottomV.backgroundColor = UIColor.black
        bottomV.bringSubviewToFront(self.view)
        self.view.addSubview(bottomV)

        let followLayout = UICollectionViewFlowLayout()
        followLayout.itemSize = CGSize(width:65 , height: 65)
        followLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10,right: 10)
        followLayout.minimumLineSpacing = 10
        followLayout.minimumInteritemSpacing = 10
        followLayout.scrollDirection = .horizontal
        self.followCollectionView = CDPreviewView(frame: CGRect(x: 0, y: 0, width: bottomV.frame.width, height: 85), layout: followLayout, isMain: false)
        self.followCollectionView.followDelegete = self
        self.followCollectionView.itemW = 65
        self.followCollectionView.itemH = 65
        self.followCollectionView.isVideo = isVideo
        self.followCollectionView.assetArr = self.assetArr
        self.followCollectionView.backgroundColor = UIColor.black
        bottomV.addSubview(self.followCollectionView)

        let line = UIView(frame: CGRect(x: 0, y: self.followCollectionView.frame.maxY, width: CDSCREEN_WIDTH, height: 1))
        line.backgroundColor = SeparatorLightGrayColor
        bottomV.addSubview(line)

        self.sendBtn = UIButton(type: .custom)
        self.sendBtn .frame = CGRect(x: CDSCREEN_WIDTH-80, y: line.frame.maxY+4, width: 65, height: 40)
        self.sendBtn .setTitle("发送", for:.normal)
        self.sendBtn .setTitleColor(UIColor.white, for: .normal)
        self.sendBtn .addTarget(self, action: #selector(previewSendBtnClick), for: .touchUpInside)
        bottomV.addSubview(self.sendBtn)

    }

    //TODO:预览发送
    @objc func previewSendBtnClick(){
        var selectArr:[CDPHAsset] = []
        for asset:CDPHAsset in self.assetArr {
            if asset.isSelected == "true" {
                selectArr.append(asset)
            }
        }
        DispatchQueue.global().async {
            self.assetDelegate.selectedAssetsComplete(assets: selectArr)

        }
    }

    
    func selectFollowWith(indexPath: IndexPath) {
        stopMainPreviewPlay()
        self.mainCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.mainCollectionView.reloadData()
    }
    func scrollMainPreview(indexPath: IndexPath) {
        
        self.followCollectionView.selectitem = indexPath.item
        self.followCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.followCollectionView.reloadData()

    }
    func selectMainPreview() {
        var rect = bottomV.frame
        if rect.origin.y < CDViewHeight {
            UIView.animate(withDuration: 0.25) {
                rect.origin.y = CDViewHeight+64
                self.bottomV.frame = rect
            }
        }else{

            UIView.animate(withDuration: 0.25) {
                rect.origin.y = CDViewHeight-self.bottom_H
                self.bottomV.frame = rect
            }
        }


    }

    func stopMainPreviewPlay(){
        //暂停上次播放的
        let offet = self.mainCollectionView.contentOffset.x/self.mainCollectionView.frame.width
        let index = Int(roundf(Float(offet)))
        let cell:CDPreviewCell = self.mainCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! CDPreviewCell
        cell.stopPlayer()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
