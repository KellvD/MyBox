//
//  CDMenuView.swift
//  MyRule
//
//  Created by changdong on 2019/4/18.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit

@objc protocol CDMusicMenuDelegate{
    
    @objc func onMusicMenuClickToShare()
    @objc func onMusicMenuClickToDelete()
    @objc func onDismissMenuView()
}

class CDMusicMenuView: UIView,UITableViewDelegate,UITableViewDataSource {

    weak var menuDelete:CDMusicMenuDelegate!
    var tableView:UITableView!
    var bgView:UIView!
    var collectionView:CDCollectionView!
    var musicInfo:CDMusicInfo!

    override init(frame:CGRect) {
        super.init(frame: frame)

        bgView = UIView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight))
        bgView.backgroundColor = UIColor.black
        bgView.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenuView))
        bgView.addGestureRecognizer(tap)
        self.addSubview(bgView)

        tableView = UITableView(frame: CGRect(x: 0, y: frame.height - 272, width: CDSCREEN_WIDTH, height: 272), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        self.addSubview(tableView)
        if #available(iOS 11.0, *) {
            tableView.layer.maskedCorners = CACornerMask(rawValue: (CACornerMask.layerMaxXMinYCorner.rawValue)|(CACornerMask.layerMinXMinYCorner.rawValue))
        } else {


        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        }
        return 48
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cellMenuIdenties_row1")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cellMenuIdenties_row1")
                cell.isSelected = false

                let imageV = UIImageView(frame: CGRect(x: 15, y: 15, width: 50, height: 50))
                imageV.layer.cornerRadius = 4
                imageV.tag = 101
                cell.addSubview(imageV)

                let musicnameL = UILabel(frame: CGRect(x: imageV.frame.maxX+15, y: 15, width: 200, height: 30))
                musicnameL.textColor = TextBlackColor
                musicnameL.font = TextMidFont
                musicnameL.tag = 102
                cell.addSubview(musicnameL)

                let singerL = UILabel(frame: CGRect(x: imageV.frame.maxX+15, y: musicnameL.frame.maxY, width: 200, height: 30))
                singerL.textColor = TextBlackColor
                singerL.font = TextMidFont
                singerL.tag = 103
                cell.addSubview(singerL)

                let sperateLine = UILabel(frame: CGRect(x: 15, y: 79, width: CDSCREEN_WIDTH-15, height: 1))
                sperateLine.backgroundColor = SeparatorLightGrayColor
                cell.addSubview(sperateLine)
            }

            let imageV = cell.viewWithTag(101) as! UIImageView
            let musicnameL = cell.viewWithTag(102) as! UILabel
            let singerL = cell.viewWithTag(103) as! UILabel

            if musicInfo != nil{
                let imagePath = String.RootPath().appendingPathComponent(str: musicInfo.musicImage)
                var image = UIImage(contentsOfFile: imagePath)
                if image == nil{
                    image = LoadImage("defaultMusicImage")
                }
                imageV.image = image
                musicnameL.text = musicInfo.musicName
                singerL.text = musicInfo.musicSinger
            }
            return cell
        }else{
            var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cellMenuIdenties_row2")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cellMenuIdenties_row2")
                let view = UIView()
                cell.selectedBackgroundView = view
                cell.selectedBackgroundView?.backgroundColor = LightBlueColor

                let imageV = UIImageView(frame: CGRect(x: 15, y: 9, width: 30, height: 30))
                imageV.tag = 101
                cell.addSubview(imageV)

                let titleL = UILabel(frame: CGRect(x: imageV.frame.maxX+15, y: 9, width: 200, height: 30))
                titleL.textColor = TextBlackColor
                titleL.font = TextMidFont
                titleL.tag = 102
                cell.addSubview(titleL)

                let sperateLine = UILabel(frame: CGRect(x: imageV.frame.maxX+15, y: 47, width: CDSCREEN_WIDTH - imageV.frame.maxX, height: 1))
                sperateLine.backgroundColor = SeparatorLightGrayColor
                sperateLine.tag = 103
                cell.addSubview(sperateLine)
            }

            let titleV = cell.viewWithTag(102) as! UILabel
            let imageV = cell.viewWithTag(101) as! UIImageView
            let sperateLine = cell.viewWithTag(103) as! UILabel
            if indexPath.row == 1{//下一曲
                titleV.text = "下一首播放"
                imageV.image = LoadImage("下一首播放")
            }else if indexPath.row == 2{//收藏到歌单
                titleV.text = "添加至歌单"
                imageV.image = LoadImage("添加至歌单")

            }else if indexPath.row == 3{//分享
                titleV.text = "分享"
                imageV.image = LoadImage("分享")

            }else if indexPath.row == 4{//删除
                titleV.text = LocalizedString("delete")
                imageV.image = LoadImage(LocalizedString("delete"))
            }

            if indexPath.row == 4{
                sperateLine.isHidden = true
            }else{
                sperateLine.isHidden = false
            }
            return cell
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 0{
            return
        }else if indexPath.row == 1{//下一曲
            self.menuDelete.onDismissMenuView()
            CDMusicManager.instance.currentPlayList.insert(musicInfo, at: 0)

        }else if indexPath.row == 2{//收藏到歌单
            collectionView = CDCollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight+64))
            collectionView.selectedMusicName = "光辉岁月"
            UIApplication.shared.keyWindow?.addSubview(collectionView)
        }else if indexPath.row == 3{//分享
            self.menuDelete.onDismissMenuView()
            self.menuDelete.onMusicMenuClickToShare()

        }else if indexPath.row == 4{//删除
            self.menuDelete.onDismissMenuView()
            menuDelete.onMusicMenuClickToDelete()

        }
    }

    @objc func dismissMenuView()
    {
        self.menuDelete.onDismissMenuView()
    }
}
