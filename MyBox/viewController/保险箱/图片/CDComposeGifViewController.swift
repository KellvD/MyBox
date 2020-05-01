//
//  CDComposeGifViewController.swift
//  MyRule
//
//  Created by changdong on 2019/6/18.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import CoreServices

protocol CDComposeGifViewControllerDelegate {
    func onComposeGifSuccess()
}
class CDComposeGifViewController: CDBaseAllViewController,UICollectionViewDelegate,UICollectionViewDataSource{


    var fileArr:[CDSafeFileInfo] = []
    var imageArr:[UIImage] = []
    var thumpArr:[UIImage] = []
    var collectionView:UICollectionView!
    var cancleBtn:UIButton!
    var sureBtn:UIButton!
    var preview:UIImageView!
    var gifPath:String!
    var nowTime:Int!
    var folderId:Int!
    var isCompose:Bool!
    var delegate:CDComposeGifViewControllerDelegate!



    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("合成GIF", comment: "")
        fileLoadImage()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 48))
        label.backgroundColor = BaseBackGroundColor
        label.font = TextMidSmallFont
        label.text = "   拖动图片可更换位置"

        label.textColor = TextLightBlackColor
        self.view.addSubview(label)

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:(CDSCREEN_WIDTH-20)/4 , height: (CDSCREEN_WIDTH-20)/4)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 50, width: CDSCREEN_WIDTH, height: CDSCREEN_WIDTH), collectionViewLayout: layout)
        collectionView.register(CDImageCell.self, forCellWithReuseIdentifier: "gifImageCellIdrr")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView!)

        let tap = UILongPressGestureRecognizer(target: self, action: #selector(dragCellResponse(dragTap:)))
        collectionView.addGestureRecognizer(tap)

        preview = UIImageView(frame: CGRect(x: 0, y: 50, width: CDSCREEN_WIDTH, height: CDSCREEN_WIDTH))
        self.view.addSubview(preview)
        preview.isHidden = true

        let bgView = UIImageView(frame: CGRect(x: 0, y: CDViewHeight - 48, width: CDSCREEN_WIDTH, height: 48))
        bgView.isUserInteractionEnabled = true
        bgView.image = UIImage(named: "下导航-bg")
        self.view.addSubview(bgView)

        cancleBtn = UIButton(type: .custom)
        cancleBtn.frame = CGRect(x: 15, y: 0, width: 45, height: 45)
        cancleBtn.setImage(LoadImageByName(imageName: "chexiao", type: "png"), for: .normal)
        cancleBtn.setImage(LoadImageByName(imageName: "chexiao-grey", type: "png"), for: .disabled)
        cancleBtn.addTarget(self, action: #selector(cancleBtnClick), for: .touchUpInside)
        bgView.addSubview(cancleBtn)
        cancleBtn.isEnabled = false

        let composeBtn = UIButton(type: .custom)
        composeBtn.frame = CGRect(x: (CDSCREEN_WIDTH - 45)/2, y: 0, width: 45, height: 45)
        composeBtn.setImage(LoadImageByName(imageName: "hecheng", type: "png"), for: .normal)
        composeBtn.addTarget(self, action: #selector(composeBtnClick), for: .touchUpInside)
        bgView.addSubview(composeBtn)

        sureBtn = UIButton(type: .custom)
        sureBtn.frame = CGRect(x: CDSCREEN_WIDTH - 15 - 45, y: 0, width: 45, height: 45)
        sureBtn.setImage(LoadImageByName(imageName: "sure", type: "png"), for: .normal)
        sureBtn.setImage(LoadImageByName(imageName: "sure-grey", type: "png"), for: .disabled)
        sureBtn.setTitleColor(UIColor.black, for: .normal)
        sureBtn.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        bgView.addSubview(sureBtn)
        sureBtn.isEnabled = false
    }

    func fileLoadImage() {
        for i in 0..<fileArr.count {
            let fileInfo:CDSafeFileInfo = fileArr[i]

            let lPath = String.ImagePath().appendingFormat("/%@",fileInfo.filePath.lastPathComponent())
            var lImgage:UIImage! = UIImage(contentsOfFile: lPath)
            if lImgage == nil {
                lImgage = LoadImageByName(imageName: "小图解密失败", type:"png")
            }
            thumpArr.append(lImgage)

            let tmpPath = String.thumpImagePath().appendingFormat("/%@",fileInfo.filePath.lastPathComponent())
            var mImgage:UIImage! = UIImage(contentsOfFile: tmpPath)
            if mImgage == nil {
                mImgage = LoadImageByName(imageName: "小图解密失败", type:"png")
            }
            imageArr.append(mImgage)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumpArr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gifImageCellIdrr", for: indexPath) as! CDImageCell
        let image:UIImage = thumpArr[indexPath.item]
        cell.backgroundView?.layer.borderWidth = 1
        cell.backgroundView?.layer.borderColor = TextLightBlackColor.cgColor
        cell.backgroundView = UIImageView(image: image)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        thumpArr.swapAt(sourceIndexPath.item, destinationIndexPath.item)
        imageArr.swapAt(sourceIndexPath.item, destinationIndexPath.item)
        collectionView.reloadData()
    }
    @objc func dragCellResponse(dragTap:UILongPressGestureRecognizer){
        cancleBtn.isEnabled = true
        switch dragTap.state {
        case .began:
            let indexPath = collectionView.indexPathForItem(at: dragTap.location(in: collectionView))
            if indexPath != nil{
                collectionView.beginInteractiveMovementForItem(at: indexPath!)

            }
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(dragTap.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    @objc override func backButtonClick() {
        if isCompose{
            let sheet = UIAlertController(title: nil, message: "是否确定放弃合成GIF操作？", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            }))

            sheet.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(sheet, animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func sureBtnClick(){

        let sheet = UIAlertController(title: nil, message: "是否确认保存该gif吗？", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
        }))

        sheet.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            let gifData = NSData(contentsOfFile: self.gifPath)! as Data
            let thumbPath = String.thumpImagePath().appendingPathComponent(str:String(format: "%lld.jpg", self.nowTime))
            let gifImage = UIImage(data: gifData)!

            let thumbImage = scaleImageAndCropToMaxSize(image: gifImage, newSize: CGSize(width: 200, height: 200))
            let tmpData:Data = thumbImage.jpegData(compressionQuality: 1.0)! as Data

            do {
                try tmpData.write(to: URL(fileURLWithPath: thumbPath))
            } catch  {

            }
            let fileInfo:CDSafeFileInfo = CDSafeFileInfo()
            fileInfo.folderId = self.folderId
            fileInfo.fileName = "未命名"
            fileInfo.filePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: self.gifPath)
            fileInfo.thumbImagePath = String.changeFilePathAbsoluteToRelectivepPath(absolutePath: thumbPath)
            fileInfo.fileSize = getFileSizeAtPath(filePath: self.gifPath)
            fileInfo.fileWidth = Double(gifImage.size.width)
            fileInfo.fileHeight = Double(gifImage.size.height)
            fileInfo.createTime = self.nowTime
            fileInfo.fileType = .GifType
            fileInfo.userId = CDUserId()
            CDSqlManager.instance().addSafeFileInfo(fileInfo: fileInfo)
            
            self.delegate.onComposeGifSuccess()
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(sheet, animated: true, completion: nil)
        
    }

    @objc func cancleBtnClick(){
        if isCompose{
            cancleBtn.isEnabled = false
            sureBtn.isEnabled = false
            collectionView.isHidden = false
            preview.isHidden = true
            collectionView.reloadData()
            isCompose = false
        }else{
            collectionView.cancelInteractiveMovement()
        }

    }
    @objc func composeBtnClick(){

        nowTime = getCurrentTimestamp()

        gifPath = String.ImagePath().appendingPathComponent(str: String(format: "%lld.gif", nowTime))
        let url:CFURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, gifPath! as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
        let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, imageArr.count, nil)

        //相关属性
        let frameDic = [kCGImagePropertyGIFDelayTime as String : [
            kCGImagePropertyGIFDelayTime as String : NSNumber(value: 0.3)
            ]] //延时

        let gifdic:NSMutableDictionary = NSMutableDictionary()
        gifdic.setValue(NSNumber(value: true), forKey: kCGImagePropertyGIFHasGlobalColorMap as String)
        gifdic.setValue(kCGImagePropertyColorModelRGB as String, forKey: kCGImagePropertyColorModel as String)
        gifdic.setValue(NSNumber(value: 16), forKey: kCGImagePropertyDepth as String) //颜色深度
        gifdic.setValue(NSNumber(value: 0), forKey: kCGImagePropertyGIFLoopCount as String) //是否重复 0无限

        let gifproperty = [kCGImagePropertyGIFDictionary as String : gifdic]

        for i in 0..<imageArr.count {
            let dimage:UIImage = imageArr[i]

            CGImageDestinationAddImage(destination!, dimage.cgImage!, frameDic as CFDictionary)
        }
        CGImageDestinationSetProperties(destination!, gifproperty as CFDictionary)
        CGImageDestinationFinalize(destination!)
        if FileManager.default.fileExists(atPath: gifPath){
            let gifData = NSData(contentsOfFile: gifPath)!
            if gifData.length > 0{
                collectionView.isHidden = true
                preview.isHidden = false
                sureBtn.isEnabled = true
                isCompose = true
                cancleBtn.isEnabled = true
                preview.image = UIImage.gif(data: gifData as Data)
                
            }

        }

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
