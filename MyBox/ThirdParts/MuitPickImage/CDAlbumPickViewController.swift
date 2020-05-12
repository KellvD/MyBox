//
//  CDImagePickViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/13.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos

class CDAlbumPickViewController: UITableViewController {
    var ablumList:[CDAlbum] = []
    var folderId = Int()
    var isSelectedVideo:Bool!
    var assetDelegate:CDAssetSelectedDelagete!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let cancle = UIBarButtonItem(barButtonSystemItem: .cancel, target: assetDelegate, action: #selector(cancleMediaPicker))
        self.navigationItem.rightBarButtonItem = cancle

        CDAssetTon.instance.authorizationStatusAuthorized(Result: { (result) in
            if !result{
                let alert = UIAlertController(title: "相册被拒绝访问", message: "请在“设置-隐私-相机”选项中，允许本应用访问你的手机相机。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                self.loadAllAlbum()
            }
        })

    }

    @objc func cancleMediaPicker(){

    }
    func loadAllAlbum() {
        CDAssetTon.instance.getAllAlbums { (albumArr) in
            self.ablumList.removeAll()
            self.ablumList = albumArr
            //排序降序
            self.ablumList.sort(by: { (photo1, photo2) -> Bool in
                return photo1.fetchResult.count > photo2.fetchResult.count
            })
            self.reloadTableView()
        }
    }
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.isSelectedVideo {
                self.navigationItem.title = "视频"
            }
            else{
                self.navigationItem.title = "图片"
            }
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ablumList.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentify = "imageListpickcell"
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentify)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentify)

            cell.backgroundColor = UIColor.init(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            let view = UIView()
            cell.selectedBackgroundView = view
            cell.selectedBackgroundView?.backgroundColor = LightBlueColor

            let imageView = UIImageView(frame: CGRect(x: 15, y: 15, width: 55, height: 55))
            imageView.tag = 101
            cell.addSubview(imageView)

            let titleLabel = UILabel(frame: CGRect(x: imageView.frame.maxX+15, y: imageView.frame.minY+5, width: 100, height: 30))
            titleLabel.tag = 102
            titleLabel.font = TextMidFont
            titleLabel.textColor = TextBlackColor
            cell.addSubview(titleLabel)

            let countlabel = UILabel(frame: CGRect(x: imageView.frame.maxX+15, y: titleLabel.frame.maxY, width: 100, height: 15))
            countlabel.tag = 103
            countlabel.font = TextMidSmallFont
            countlabel.textColor = TextLightBlackColor
            cell.addSubview(countlabel)

            let separatorLine = UILabel(frame: CGRect(x: 15, y: 84, width: CDSCREEN_WIDTH-15, height: 1))
            separatorLine.tag = 104
            separatorLine.backgroundColor = SeparatorGrayColor
            cell.addSubview(separatorLine)
        }

        let headImage = cell.viewWithTag(101) as! UIImageView
        let titleLabel = cell.viewWithTag(102) as! UILabel
        let countLabel = cell.viewWithTag(103) as! UILabel
        let separatorLine = cell.viewWithTag(104) as! UILabel


        let alum:CDAlbum = ablumList[indexPath.row]
        titleLabel.text = alum.title;
        countLabel.text = "\(alum.fetchResult.count) 张"
        headImage.image = alum.firstImage

        if indexPath.row == ablumList.count - 1 {
            separatorLine.isHidden = true
        }else{
            separatorLine.isHidden = false
        }
        return cell


    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let alum:CDAlbum = ablumList[indexPath.row]
        let imageItemVC = CDAssetPickViewController()
        imageItemVC.albumItem = alum
        imageItemVC.isVideo = isSelectedVideo
        imageItemVC.assetDelegate = assetDelegate
        self.navigationController?.pushViewController(imageItemVC, animated: true)

    }

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
