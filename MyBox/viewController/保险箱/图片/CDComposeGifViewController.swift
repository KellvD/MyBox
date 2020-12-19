//
//  CDComposeGifViewController.swift
//  MyRule
//
//  Created by changdong on 2019/6/18.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import CoreServices
import AVFoundation

enum CDComposeType {
    case Gif
    case Video
}
class CDComposeGifViewController: CDBaseAllViewController,UICollectionViewDelegate,UICollectionViewDataSource{


    public var fileArr:[CDSafeFileInfo] = []
    public var composeHandle:CDComposeHandle?
    public var folderId:Int!
    public var composeType:CDComposeType!
    
    private var imageArr:[UIImage] = []
    private var thumpArr:[UIImage] = []
    private var collectionView:UICollectionView!
    private var cancleBtn:UIButton!
    private var sureBtn:UIButton!
    private var composeBtn:UIButton!
    private var preview:UIImageView!
    private var gifPath:String!
    private var videoPath:String!
    private var nowTime:Int!
    private var isCompose:Bool = false
    private var gifDelaySlider:CDGifDelayView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if composeType == .Gif{
            self.title = NSLocalizedString("合成GIF", comment: "")
        }else{
            self.title = NSLocalizedString("合成视频", comment: "")
        }
        
        fileLoadImage()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:(CDSCREEN_WIDTH-20)/4 , height: (CDSCREEN_WIDTH-20)/4)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_WIDTH), collectionViewLayout: layout)
        collectionView.register(CDImageCell.self, forCellWithReuseIdentifier: "gifImageCellIdrr")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView!)

        let tap = UILongPressGestureRecognizer(target: self, action: #selector(dragCellResponse(dragTap:)))
        collectionView.addGestureRecognizer(tap)

        preview = UIImageView(frame: CGRect(x: 0, y: (CDSCREEN_HEIGTH - CDSCREEN_WIDTH)/2 - 48, width: CDSCREEN_WIDTH, height: CDSCREEN_WIDTH))
        self.view.addSubview(preview)
        preview.isHidden = true

        gifDelaySlider = CDGifDelayView(frame: CGRect(x: 0, y: CDViewHeight - 48 * 2, width: CDSCREEN_WIDTH, height: 48))
        self.view.addSubview(gifDelaySlider)
        
        
        let bgView = UIImageView(frame: CGRect(x: 0, y: CDViewHeight - 48, width: CDSCREEN_WIDTH, height: 48))
        bgView.isUserInteractionEnabled = true
        bgView.image = UIImage(named: "下导航-bg")
        self.view.addSubview(bgView)

        cancleBtn = UIButton(type: .custom)
        cancleBtn.frame = CGRect(x: 15, y: 0, width: 45, height: 45)
        cancleBtn.setImage(LoadImage(imageName: "chexiao", type: "png"), for: .normal)
        cancleBtn.setImage(LoadImage(imageName: "chexiao-grey", type: "png"), for: .disabled)
        cancleBtn.addTarget(self, action: #selector(cancleBtnClick), for: .touchUpInside)
        bgView.addSubview(cancleBtn)
        cancleBtn.isEnabled = false

        composeBtn = UIButton(type: .custom)
        composeBtn.frame = CGRect(x: (CDSCREEN_WIDTH - 45)/2, y: 0, width: 45, height: 45)
        composeBtn.setImage(LoadImage(imageName: "hecheng", type: "png"), for: .normal)
        composeBtn.addTarget(self, action: #selector(composeBtnClick), for: .touchUpInside)
        bgView.addSubview(composeBtn)

        sureBtn = UIButton(type: .custom)
        sureBtn.frame = CGRect(x: CDSCREEN_WIDTH - 15 - 45, y: 0, width: 45, height: 45)
        sureBtn.setImage(LoadImage(imageName: "sure", type: "png"), for: .normal)
        sureBtn.setImage(LoadImage(imageName: "sure-grey", type: "png"), for: .disabled)
        sureBtn.setTitleColor(UIColor.black, for: .normal)
        sureBtn.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        bgView.addSubview(sureBtn)
        sureBtn.isEnabled = false
    }

    private func fileLoadImage() {
        for i in 0..<fileArr.count {
            let fileInfo:CDSafeFileInfo = fileArr[i]

            let lPath = String.RootPath().appendingFormat("%@",fileInfo.thumbImagePath)
            var lImgage:UIImage! = UIImage(contentsOfFile: lPath)
            if lImgage == nil {
                lImgage = LoadImage(imageName: "小图解密失败", type:"png")
            }
            thumpArr.append(lImgage)

            let tmpPath = String.ImagePath().appendingFormat("/%@",fileInfo.filePath.lastPathComponent())
            var mImgage:UIImage! = UIImage(contentsOfFile: tmpPath)
            if mImgage == nil {
                mImgage = LoadImage(imageName: "小图解密失败", type:"png")
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
    
    @objc private func dragCellResponse(dragTap:UILongPressGestureRecognizer){
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
            sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in }))

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
            if self.composeType == .Gif{
                CDSignalTon.shared.saveSafeFileInfo(fileUrl:URL(fileURLWithPath: self.gifPath) , folderId: self.folderId, subFolderType: .ImageFolder,isFromDocment: false)
                
                self.composeHandle!(true)
            }else{
                
            }
            
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(sheet, animated: true, completion: nil)
        
    }

    @objc func cancleBtnClick(){
        cancleBtn.isEnabled = false
        sureBtn.isEnabled = false
        collectionView.isHidden = false
        preview.isHidden = true
        gifDelaySlider.isHidden = false
        composeBtn.isEnabled = true
        collectionView.reloadData()
        isCompose = false

    }
    @objc func composeBtnClick(){
        if composeType == .Gif {
            onComposeGif()
        }else{
            onComposeVideo()
        }
    }
    
    private func onComposeGif(){
        nowTime = GetTimestamp()
        let delay = gifDelaySlider.value
        print(delay)
        gifPath = String.ImagePath().appendingPathComponent(str: String(format: "%lld.gif", nowTime))
        let url:CFURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, gifPath! as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
        let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, imageArr.count, nil)

        //每帧之间播放的时间间隔
        let frameDic = ["kCGImagePropertyGIFDelayTime" : ["kCGImagePropertyGIFDelayTime":1]]
        
        let gifdic:NSMutableDictionary = NSMutableDictionary()
        gifdic.setValue(NSNumber(value: true), forKey: "kCGImagePropertyGIFHasGlobalColorMap")
        gifdic.setValue(kCGImagePropertyColorModelRGB, forKey: "kCGImagePropertyColorModel")
        //颜色深度
        gifdic.setValue(16, forKey: "kCGImagePropertyDepth")
        //是否重复 0无限
        gifdic.setValue(1, forKey: "kCGImagePropertyGIFLoopCount")

        let gifproperty = ["kCGImagePropertyGIFDictionary" : gifdic]

        for image in imageArr {

            CGImageDestinationAddImage(destination!, image.cgImage!, frameDic as CFDictionary)
        }
        CGImageDestinationSetProperties(destination!, gifproperty as CFDictionary)
        CGImageDestinationFinalize(destination!)
        if FileManager.default.fileExists(atPath: gifPath){
            let gifData = NSData(contentsOfFile: gifPath)!
            if gifData.length > 0{
                collectionView.isHidden = true
                gifDelaySlider.isHidden = true
                preview.isHidden = false
                
                sureBtn.isEnabled = true
                composeBtn.isEnabled = false
                cancleBtn.isEnabled = true
                isCompose = true
                preview.image = UIImage.gif(data: gifData as Data)
                
            }

        }
    }
    private func onComposeVideo(){
//        nowTime = getCurrentTimestamp()
//        videoPath = String.VideoPath().appendingPathComponent(str: String(format: "%lld.MOV", nowTime))
//        //视频大小320，480倍数
//        let size = CGSize(width: 320, height: 480)
////        unlink([videoPath.utf8])
//        do {
//            let write = try AVAssetWriter(url: URL(fileURLWithPath: videoPath), fileType: .mov)
//            let input = AVAssetWriterInput(mediaType: .video, outputSettings: ["AVVideoWidthKey":size.width,"AVVideoHeightKey":size.height,"AVVideoCodecType" :AVVideoCodecType.h264])
//            var frmae = 0
//            if write.canAdd(input) {
//                write.add(input)
//                write.startWriting()
//                write.startSession(atSourceTime: .zero)
//
//                let queue = DispatchQueue(label: "medeiaQueue")
//                input.requestMediaDataWhenReady(on: queue) {
//                    while input.isReadyForMoreMediaData {
//                        frmae += 1
//                        if frmae >= self.imageArr.count * 10 {
//                            input.markAsFinished()
//                            write.finishWriting {
//                                DispatchQueue.main.async {
//                                    print("合成成功")
//                                }
//                            }
//                            break
//                        }
//                    }
//                }
//
//            }else{
//                print("无法合成")
//            }
//
//            let buffer = (CVPixelBuffer)
//
//        } catch  {
//            print(error.localizedDescription)
//        }
//
//
//        func pixelBufferFromCGImage(image:CGImage,size:CGSize){
//            let options = ["kCVPixelBufferCGImageCompatibilityKey":true,"kCVPixelBufferCGBitmapContextCompatibilityKey":true]
//            let pxbuffer:CVPixelBuffer
//            let status:CVReturn = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pxbuffer)
//        }
//
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


//MARK:Gif 间隔设置
class CDGifDelayView: UIView {
    
    var sliderLabel:UILabel!
    var value:Float = 0.5
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let gifDelaySlider = UISlider(frame: CGRect(x: 30, y: 12, width: CDSCREEN_WIDTH - 60 - 40, height: 20))
        gifDelaySlider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        gifDelaySlider.minimumValue = 0.1
        gifDelaySlider.maximumValue = 5.0
        gifDelaySlider.value = 0.5
        gifDelaySlider.addTarget(self, action: #selector(onSliderChangeGifDelay(slider:)), for: .valueChanged)
        self.addSubview(gifDelaySlider)
        
        
        sliderLabel = UILabel(frame: CGRect(x: gifDelaySlider.frame.maxX + 15, y: 10, width: 40, height: 28))
        sliderLabel.textColor = TextGrayColor
        sliderLabel.backgroundColor = UIColor.clear
        sliderLabel.font = TextSmallFont
        sliderLabel.text = "\(gifDelaySlider.value)"
        sliderLabel.textAlignment = .center
        self.addSubview(sliderLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onSliderChangeGifDelay(slider:UISlider){
        sliderLabel.text = String.init(format: "%0.f", slider.value)
        value = slider.value
    }
}




