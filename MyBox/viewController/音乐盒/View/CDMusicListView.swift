//
//  CDMusicListView.swift
//  MyRule
//
//  Created by changdong on 2019/4/21.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
@objc protocol CDMusicListViewDelegate{
    @objc func onHandleOneMusicToShare(musicInfo:CDMusicInfo)
    @objc func onHandleOneMusicToDelete(musicInfo:CDMusicInfo)
}
class CDMusicListView: UITableView,UITableViewDelegate,UITableViewDataSource,CDMusicMenuDelegate,CDMusicPlayDelegate {
    func onUpdateMusicPlayCurrentTime(current: Float) {

    }

    var listDataArr:[CDMusicInfo] = []
    var collectionView:CDCollectionView!
    var menuView:CDMusicMenuView!
    var currentEditMusic:CDMusicInfo!
    weak var listViewDelegate:CDMusicListViewDelegate!

    init(frame:CGRect) {
        super.init(frame: frame, style: .plain)
        self.delegate = self
        self.dataSource = self
        self.separatorStyle = .none
        menuView = CDMusicMenuView(frame: CGRect(x: 0, y: CDViewHeight+64, width: CDSCREEN_WIDTH, height: CDViewHeight))
        menuView.menuDelete = self
        UIApplication.shared.keyWindow?.addSubview(menuView)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDataArr.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "musicListIdenties")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "musicListIdenties")
            let view = UIView()
            cell.selectedBackgroundView = view
            cell.selectedBackgroundView?.backgroundColor = LightBlueColor

            let nameLabel = UILabel(frame: CGRect(x: 15, y: 5, width: CDSCREEN_WIDTH-30-30, height: 30))
            nameLabel.textColor = TextBlackColor
            nameLabel.font = TextMidFont
            nameLabel.tag = 201
            cell.addSubview(nameLabel)

            let markName = UILabel(frame: CGRect(x: 15, y: nameLabel.frame.maxY, width: nameLabel.frame.width, height: 20))
            markName.textColor = TextLightBlackColor
            markName.font = TextMidSmallFont
            markName.tag = 202
            cell.addSubview(markName)

            let editBtn = UIButton(type: .custom)
            editBtn.frame = CGRect(x: CDSCREEN_WIDTH-55, y: 5, width: 40, height: 50)
            editBtn.setImage(LoadImageByName(imageName: "editMusic", type: "png"), for: .normal)
            editBtn.addTarget(self, action: #selector(onEditOneMusicClick(sender:)), for: .touchUpInside)
            editBtn.tag = indexPath.row + 100
            cell.contentView.addSubview(editBtn)

            let sperateLine:UIView = UIView(frame: CGRect(x: 15, y: 59, width: CDSCREEN_WIDTH-15, height: 1))
            sperateLine.backgroundColor = SeparatorLightGrayColor
            cell.addSubview(sperateLine)

        }

        let musicInfo:CDMusicInfo = listDataArr[indexPath.row]

        let nameLabel = cell.viewWithTag(201) as? UILabel
        let markLabel = cell.viewWithTag(202) as? UILabel

        nameLabel!.text = musicInfo.musicName
        markLabel!.text = musicInfo.musicMark
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let musicInfo:CDMusicInfo = listDataArr[indexPath.row]
        CDMusicManager.shareInstance().playWithMusic(musicInfo: musicInfo)
        CDMusicManager.shareInstance().musicPlayDelegate = self
        tableView.deselectRow(at: indexPath, animated: false)
    }

    @objc func onOpenMenuView(){
        let classCount = CDSqlManager.instance().queryMusicClassCount()
        var height = CGFloat((classCount + 1) * 64)
        if classCount > 6 {
            height = 7 * 64
        }
        collectionView = CDCollectionView(frame: CGRect(x: 15, y: (CDViewHeight - height)/2, width: CDSCREEN_WIDTH-30, height: height))
        UIApplication.shared.keyWindow?.addSubview(collectionView)
        UIApplication.shared.keyWindow?.bringSubviewToFront(collectionView)
    }

    @objc func onEditOneMusicClick(sender:UIButton){

        let row = sender.tag - 100
        print("音乐列表row = %d\(row)")
        currentEditMusic = listDataArr[row]
        menuView.musicInfo = currentEditMusic
        menuView.tableView.reloadData()
        let rect = menuView.frame
        if rect.minY >= CDViewHeight { //presented
            presentMusicMenuView()
        }else{
            dismissMenuView()
        }

    }

    func presentMusicMenuView() {
        var rect = menuView.frame
        UIView.animate(withDuration: 0.15, animations: {
            rect.origin.y = 64
            self.menuView.frame = rect
            self.menuView.bgView.alpha = 0.3
            self.menuView.isHidden = false

        }) { (finished) in

        }

    }

    func dismissMenuView(){
        UIView.animate(withDuration: 0.15, animations: {
            var rect = self.menuView.frame
            rect.origin.y = CDViewHeight + 64
            self.menuView.frame = rect
            self.menuView.bgView.alpha = 0.0
        }) { (finished) in
            self.menuView.isHidden = true
        }
    }

    //MARK:MenuView

    func onMusicMenuClickToShare() {
        listViewDelegate.onHandleOneMusicToShare(musicInfo: currentEditMusic)
    }

    func onMusicMenuClickToDelete() {
        

        listViewDelegate.onHandleOneMusicToDelete(musicInfo: currentEditMusic)
    }

    func onDismissMenuView() {
        dismissMenuView()
    }
    
}


