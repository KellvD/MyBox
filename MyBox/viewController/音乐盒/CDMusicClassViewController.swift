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

//        let titleArr:[String] = [musicPopEditClass,musicPopEditSort]
//        let imageArr:[String] = [musicPopEditClass,musicPopEditSort]

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
        editBtn.setImage(LoadImage("editClass"), for: .normal);
        editBtn.addTarget(self, action: #selector(presentedPopView), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editBtn)

        refleshListData()
    }

    func refleshListData() {

        let musicArr:[CDMusicInfo] = CDSqlManager.shared.queryAllMusicWithClassId(classId: classId)
        tableView.listDataArr = musicArr
        tableView.reloadData()
    }
    //MARK: popView Response
    @objc func presentedPopView(){

//        popView

    }

    func closePopMenuView() {
        
    }
    func onSelectedPopMenu(title: String) {
        closePopMenuView()
        if title == musicPopEditClass {

        }else{

        }
    }
    //MARK:ListViewDelegate
    func onHandleOneMusicToDelete(musicInfo: CDMusicInfo) {
        let alertVC = UIAlertController(title: "提示", message: "确认要操作删除？", preferredStyle: .alert)
        let sureAc = UIAlertAction(title: LocalizedString("sure"), style: .default) { (handle) in
            CDSqlManager.shared.deleteOneMusicInfoWith(musicId: musicInfo.musicId)
            self.refleshListData()
        }
        let cancleAc = UIAlertAction(title: LocalizedString("cancel"), style: .cancel) { (handle) in
        }
        alertVC.addAction(cancleAc)
        alertVC.addAction(sureAc)
        self.present(alertVC, animated: true, completion: nil)

    }
    func onHandleOneMusicToShare(musicInfo: CDMusicInfo) {
//        presentShareActivityWith(dataArr: [musicInfo])
    }
}
