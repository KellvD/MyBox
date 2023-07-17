//
//  CDImagePickViewController.swift
//  MyRule
//
//  Created by changdong on 2018/12/13.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Photos

class CDAlbumPickViewController: UITableViewController, PHPhotoLibraryChangeObserver {

    private var ablumList: [CDAlbum] = []
    private var folderId = Int()
    var isSelectedVideo: Bool!
    weak var assetDelegate: CDAssetSelectedDelagete!

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if status == .limited {
                PHPhotoLibrary.shared().unregisterChangeObserver(self)
            }

        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        self.navigationController!.navigationBar.topItem?.title = ""
        let cancle = UIBarButtonItem(barButtonSystemItem: .cancel, target: assetDelegate, action: #selector(cancleMediaPicker))
        self.navigationItem.rightBarButtonItem = cancle

        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if status == .limited {
                self.loadAllAlbum()
                PHPhotoLibrary.shared().register(self)
                return
            }

        }
        loadAllAlbum()
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.loadAllAlbum()
        }

    }

    @objc func cancleMediaPicker() {}

    func loadAllAlbum() {
        CDAssetTon.shared.getAllAlbums { (albumArr) in
            self.ablumList.removeAll()
            self.ablumList = albumArr
            // 排序降序
            self.ablumList.sort(by: { (photo1, photo2) -> Bool in
                return photo1.fetchResult.count > photo2.fetchResult.count
            })
            self.reloadTableView()
        }
    }
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.navigationItem.title = self.isSelectedVideo ? "视频" : "图片"
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
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentify)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentify)

            cell.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            let view = UIView()
            cell.selectedBackgroundView = view
            cell.selectedBackgroundView?.backgroundColor = UIColor(red: 213.0/255.0, green: 230.0/255.0, blue: 244.0/255.0, alpha: 1.0)

            let imageView = UIImageView(frame: CGRect(x: 15, y: 15, width: 55, height: 55))
            imageView.tag = 101
            cell.addSubview(imageView)

            let titleLabel = UILabel(frame: CGRect(x: imageView.frame.maxX+15, y: imageView.frame.minY+5, width: 100, height: 30))
            titleLabel.tag = 102
            titleLabel.font = UIFont.systemFont(ofSize: 17)
            titleLabel.textColor = UIColor(red: 61/255.0, green: 81/255.0, blue: 97/255.0, alpha: 1.0)
            cell.addSubview(titleLabel)

            let countlabel = UILabel(frame: CGRect(x: imageView.frame.maxX+15, y: titleLabel.frame.maxY, width: 100, height: 15))
            countlabel.tag = 103
            countlabel.font = UIFont.systemFont(ofSize: 12)
            countlabel.textColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
            cell.addSubview(countlabel)

            let separatorLine = UILabel(frame: CGRect(x: 15, y: 84, width: CDSCREEN_WIDTH-15, height: 1))
            separatorLine.tag = 104
            separatorLine.backgroundColor = .white
            cell.addSubview(separatorLine)
        }

        let headImage = cell.viewWithTag(101) as! UIImageView
        let titleLabel = cell.viewWithTag(102) as! UILabel
        let countLabel = cell.viewWithTag(103) as! UILabel
        let separatorLine = cell.viewWithTag(104) as! UILabel

        let alum: CDAlbum = ablumList[indexPath.row]
        titleLabel.text = alum.title
        countLabel.text = "\(alum.fetchResult.count) 张"
        headImage.image = alum.coverImage
        separatorLine.isHidden = indexPath.row == ablumList.count - 1
        return cell

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let alum: CDAlbum = ablumList[indexPath.row]
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
