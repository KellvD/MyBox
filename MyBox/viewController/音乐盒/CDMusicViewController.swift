//
//  CDMusicViewController.swift
//  MyRule
//
//  Created by changdong on 2019/4/18.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import AVFoundation

class CDMusicViewController: CDBaseAllViewController,CDMusicClassDelegate {

    var classView:CDMusicClassView!
    var listView:CDMusicListView!

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "音乐盒"
        self.hiddBackbutton()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshClick))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white

       
        classView = CDMusicClassView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 120))
        classView.classDelegate = self
        self.view.addSubview(classView)

        listView = CDMusicListView(frame: CGRect(x: 0, y: classView.frame.maxY+20, width: CDSCREEN_WIDTH, height: CDViewHeight-classView.frame.maxY))
        
        self.view.addSubview(listView)

        reloadUIData()

    }
    @objc func refreshClick(){
        if #available(iOS 8, *) {
            let documentTypes = ["public.audio"]
            let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .fullScreen
            if #available(iOS 11.0, *) {
                documentPicker.allowsMultipleSelection = true
            }
            self.present(documentPicker, animated: true, completion: nil)
        }
    }
    func reloadUIData() {
        let classArr = CDSqlManager.instance().queryAllMusicClass()
        classView.classArr = classArr
        classView .reloadData()

        let musicArr = CDSqlManager.instance().queryAllMusicWithClassId(classId: 1)
        listView.listDataArr = musicArr
        listView.reloadData()

    }
    //TODO:CDMusicClassDelegate
    func onSelectedOneMusicClassWithClassInfo(classInfo: CDMusicClassInfo) {

        let classVC = CDMusicClassViewController()
        classVC.classId = classInfo.classId
        classVC.className = classInfo.className
        self.navigationController?.pushViewController(classVC, animated: true)

    }

//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        DispatchQueue.global().async {
//            DispatchQueue.main.async {
//                CDHUD.showInfo(text: "加载中。。。")
//            }
//            for url:URL in urls {
//                let fileUrlAuthozied = url.startAccessingSecurityScopedResource()
//                if fileUrlAuthozied {
//                    let fileCoordinator = NSFileCoordinator()
//                    fileCoordinator.coordinate(readingItemAt: url, options: [], error: nil) { (newUrl) in
//
//
//
//                        let urlStr = newUrl.absoluteString
//                        var fileName = urlStr.getFileNameFromPath()
//                        fileName = fileName.removingPercentEncoding()
//                        let suffix = urlStr.pathExtension()
//
//                        let musicPath = String.MusicPath().appendingPathComponent(str: "\(fileName).\(suffix)")
//                        if !FileManager.default.fileExists(atPath: musicPath){
//                            do{
//                                let data = try Data(contentsOf: newUrl)
//                                try data.write(to: URL(fileURLWithPath: musicPath))
//                            }catch{
//
//                            }
//                            let muiscInfo = CDSignalTon.shareInstance().getMusicInfoFromMusicFile(filePath: musicPath)
//
//                            let imagePath = String.MusicImagePath().appendingPathComponent(str: "\(fileName).png")
//                            let imageData = muiscInfo.image.pngData()
//
//                            do{
//                                try imageData?.write(to: URL(fileURLWithPath: imagePath))
//                            }catch{
//
//                            }
//                            let info = CDMusicInfo()
//                            info.musicName = fileName
//                            info.musicSinger = muiscInfo.artist
//                            info.musicPath =  String.changeFilePathAbsoluteToRelectivepPath(absolutePath: musicPath)
//                            info.musicImage = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: imagePath)
//                            info.musicClassId = 3
//                            info.musicTimeLength = muiscInfo.length
//                            CDSqlManager.instance().addOneMusicInfoWith(musicInfo: info)
//
//                        }
//                    }
//
//                    url.stopAccessingSecurityScopedResource()
//                }else{
//                    let alert = UIAlertController(title: nil, message: "申请访问受限", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                    return
//                }
//            }
//            DispatchQueue.main.async {
//                CDHUD.hide()
//                CDHUD.showText(text: "加载完成")
//            }
//        }
//        let musicArr = CDSqlManager.instance().queryAllMusic()
//        listView.listDataArr = musicArr
//        listView.reloadData()
//    }
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        
//    }

}
