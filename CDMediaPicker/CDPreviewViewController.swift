//
//  CDPreviewViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/14.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos

let bottom_H:CGFloat = 85+48+1
class CDPreviewViewController: UIViewController,CDMainPreviewDelegate,CDFollowPreviewDelegate {

    public var assetArr:[CDPHAsset] = []
    public var isVideo:Bool!
    public var assetDelegate:CDAssetSelectedDelagete!

    private var mainCollectionView:CDPreviewView!
    private var followCollectionView:CDPreviewView!
    private var imageManager:PHCachingImageManager!
    private var editBtn:UIButton!
    private var sendBtn:UIButton!
    private var isHiddenBottom:Bool! = false

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController!.navigationBar.isTranslucent = false
        stopMainPreviewPlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.isTranslucent = true
    }
    
    override var prefersStatusBarHidden: Bool{
        return isHiddenBottom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController!.navigationBar.topItem?.title = ""
        let mainLayout = UICollectionViewFlowLayout()
        mainLayout.itemSize = CGSize(width:CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH)
        mainLayout.sectionInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        mainLayout.minimumLineSpacing = 0
        mainLayout.minimumInteritemSpacing = 0
        mainLayout.scrollDirection = .horizontal
        self.mainCollectionView = CDPreviewView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH), layout: mainLayout,isMain: true)

        self.mainCollectionView.assetArr = assetArr
        self.mainCollectionView.isVideo = isVideo
        self.mainCollectionView.itemW = CDSCREEN_WIDTH
        self.mainCollectionView.itemH = CDViewHeight
        self.mainCollectionView.mainDelegete = self
        self.mainCollectionView.backgroundColor = UIColor.black
        self.mainCollectionView.isPagingEnabled = true
        self.view.addSubview(self.mainCollectionView)
        
        self.bottomV.bringSubviewToFront(self.view)
        self.view.addSubview(self.bottomV)

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
        self.bottomV.addSubview(self.followCollectionView)

        let line = UIView(frame: CGRect(x: 0, y: self.followCollectionView.frame.maxY, width: CDSCREEN_WIDTH, height: 1))
        line.backgroundColor = UIColor(red:153/255.0,green:153/255.0,blue:153/255.0,alpha:1.0)
        self.bottomV.addSubview(line)

        self.sendBtn = UIButton(type: .custom)
        self.sendBtn .frame = CGRect(x: CDSCREEN_WIDTH-80, y: line.frame.maxY+4, width: 65, height: 40)
        self.sendBtn .setTitle("发送", for:.normal)
        self.sendBtn .setTitleColor(UIColor.white, for: .normal)
        self.sendBtn .addTarget(self, action: #selector(previewSendBtnClick), for: .touchUpInside)
        self.bottomV.addSubview(self.sendBtn)

    }
    
    lazy var bottomV: UIView = {
        let vv = UIView(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - BottomBarHeight - 85.0, width: CDSCREEN_WIDTH, height: BottomBarHeight + 85.0))
        vv.backgroundColor = UIColor.black
        return vv
    }()

    //MARK:预览发送
    @objc func previewSendBtnClick(){
        var selectArr:[CDPHAsset] = []
        self.assetArr.forEach { (asset) in
            if asset.isSelected == .CD_True {
                selectArr.append(asset)
            }
        }
        DispatchQueue.global().async {
            self.assetDelegate.selectedAssetsComplete(phAssets: selectArr)

        }
    }

    
    func selectFollowWith(indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.mainCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func scrollMainPreview(lastIndexPath: IndexPath, currentIndexPath: IndexPath) {

        self.followCollectionView.selectitem = currentIndexPath.item
        self.followCollectionView.reloadItems(at: [lastIndexPath,currentIndexPath])
        self.followCollectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: true)
        
        //如果缩略图隐藏，滑动主视图让他pop出来
        if bottomV.frame.minY >= CDViewHeight {
            self.hideOrPopBottomV()
        }
    }
    
    //点击主视图，隐藏/展示缩略图
    func selectMainPreview() {
        hideOrPopBottomV()
    }
    
    func hideOrPopBottomV() {
        self.isHiddenBottom = !self.isHiddenBottom
        var rect = self.bottomV.frame
        UIView.animate(withDuration: 0.25) {
            rect.origin.y = self.isHiddenBottom ? CDSCREEN_HEIGTH : (CDSCREEN_HEIGTH - BottomBarHeight - 85.0)
            self.bottomV.frame = rect
        }
        
        self.navigationController?.setNavigationBarHidden(self.isHiddenBottom, animated: true)
        self.setNeedsStatusBarAppearanceUpdate()
        
        
        
    }
    
    func stopMainPreviewPlay(){
        
        //离开本VC,当前mainCell停止播放
        let mainCell:CDPreviewCell = self.mainCollectionView.visibleCells.first as! CDPreviewCell
        mainCell.playerItemDidFinish()
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
