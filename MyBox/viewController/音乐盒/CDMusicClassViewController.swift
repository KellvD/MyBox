//
//  CDMusicClassViewController.swift
//  MyRule
//
//  Created by changdong on 2019/4/19.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
enum Orientation:Int {
    case leftDown
    case leftUp
    case rightDown
    case rightUp
}
class CDMusicClassViewController: CDBaseAllViewController,CDPopMenuViewDelegate,CDMusicListViewDelegate {

    var classId:Int!
    var className:String!
    var tableView:CDMusicListView!
    var popView:CDPopMenuView!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = className


        tableView = CDMusicListView(frame: CGRect(x: 0, y:0, width: CDSCREEN_WIDTH, height: CDViewHeight))
        tableView.listViewDelegate = self;
        self.view.addSubview(tableView)

        let titleArr:[String] = [musicPopEditClass,musicPopEditSort]
        let imageArr:[String] = [musicPopEditClass,musicPopEditSort]

//        popView = CDPopMenuView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight), imageArr: imageArr, titleArr: titleArr, isLeft: false)
//        popView.popDelegate = self
//        self.view.addSubview(popView)
//
//        var rect = popView.tableBgView.frame
//        rect.size.height = 0
//        rect.size.width = 0
//        rect.origin.x = CDSCREEN_WIDTH
//        popView.tableBgView.frame = rect
//        popView.backGroundView.alpha = 0
//        popView.isHidden = false


        let editBtn = UIButton(type: .custom)
        editBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 45)
        editBtn.setImage(LoadImageByName(imageName: "editClass", type: "png"), for: .normal);
        editBtn.addTarget(self, action: #selector(presentedPopView), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editBtn)

        refleshListData()
    }

    func refleshListData() {

        let musicArr:[CDMusicInfo] = CDSqlManager.instance().queryAllMusicWithClassId(classId: classId)
        tableView.listDataArr = musicArr
        tableView.reloadData()
    }
    //TODO: popView Response
    @objc func presentedPopView(){

        var rect = popView.tableBgView.frame
        if rect.height  == 0 {
            self.view.bringSubviewToFront(popView)
            UIView.animate(withDuration: 0.15, animations: {
                self.popView.backGroundView.alpha = 0.3
                self.popView.isHidden = false
                rect.size.width = CGFloat(self.popView.tableBgViewWidth)
                rect.size.height = CGFloat(self.popView.tableBgViewHeight)
                rect.origin.x = CDSCREEN_WIDTH - rect.size.width - 10
                self.popView.tableBgView.frame = rect
            }) { (finished) in
            }
        }else{
            closePopMenuView()
        }

    }

    func closePopMenuView() {
        var rect = popView.tableBgView.frame
        UIView.animate(withDuration: 0.15, animations: {
            self.popView.backGroundView.alpha = 0.0
            self.popView.isHidden = false
            rect.size.width = 0
            rect.size.height = 0
            rect.origin.x = CDSCREEN_WIDTH - 25
            self.popView.tableBgView.frame = rect
        }) { (finished) in
            self.popView.isHidden = true
        }
    }
    func onSelectedPopMenu(title: String) {
        closePopMenuView()
        if title == musicPopEditClass {

        }else{

        }
    }
    //TODO:ListViewDelegate
    func onHandleOneMusicToDelete(musicInfo: CDMusicInfo) {
        let alertVC = UIAlertController(title: "提示", message: "确认要操作删除？", preferredStyle: .alert)
        let sureAc = UIAlertAction(title: "确定", style: .default) { (handle) in
            CDSqlManager.instance().deleteOneMusicInfoWith(musicId: musicInfo.musicId)
            self.refleshListData()
        }
        let cancleAc = UIAlertAction(title: "取消", style: .cancel) { (handle) in
        }
        alertVC.addAction(cancleAc)
        alertVC.addAction(sureAc)
        self.present(alertVC, animated: true, completion: nil)

    }
    func onHandleOneMusicToShare(musicInfo: CDMusicInfo) {
        presentShareActivityWith(dataArr: [musicInfo])
    }
}
