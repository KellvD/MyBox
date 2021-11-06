//
//  CDShareViewController.swift
//  Share
//
//  Created by cwx889303 on 2021/10/9.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

@available(iOSApplicationExtension, unavailable, message: "This method is NS_EXTENSION_UNAVAILABLE.")
class CDShareViewController: UIViewController {

    private var container:UIView!
    private var topBar:UIImageView!
    private var shareType:String = "None"
    private var shareContent:String!
    private var imageArr:[Any] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print("sdsdsds")
        container = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 20))
        container.backgroundColor = UIColor.white
        container.isUserInteractionEnabled = true
        view.addSubview(container)
        
        topBar = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        topBar.image = UIImage(named: "上导航栏-背景")
        topBar.isUserInteractionEnabled = true
        container.addSubview(topBar)
        
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.frame = CGRect(x: 10, y: 10, width: 65, height: 40)
        cancelBtn.addTarget(self, action: #selector(onCancleShare), for: .touchUpInside)
        container.addSubview(cancelBtn)

        let sureBtn = UIButton(type: .system)
        sureBtn.setTitle("发送", for: .normal)
        sureBtn.frame = CGRect(x: container.frame.width - 10 - 65, y: 10, width: 65, height: 40)
        sureBtn.addTarget(self, action: #selector(onSureShare), for: .touchUpInside)
        topBar.addSubview(sureBtn)

        let label = UILabel(frame: CGRect(x: topBar.frame.width / 2 - 50, y: 10, width: 100, height: 40))
        label.text = "MyBox"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        topBar.addSubview(label)

        let separatorImage = UIView(frame: CGRect(x: 0, y: 59, width: topBar.frame.width, height: 1))
        separatorImage.backgroundColor = UIColor(red: 243 / 255.0, green: 243 / 255.0, blue: 243 / 255.0, alpha: 1.0)
        topBar.addSubview(separatorImage)
//
        
    
        for obj in self.extensionContext!.inputItems {
            let extensionItem = obj as! NSExtensionItem
            for itemProvider:NSItemProvider in extensionItem.attachments! {
                if itemProvider.hasItemConformingToTypeIdentifier("public.image") {
                    container.addSubview(self.shareImageView)
                    DispatchQueue.global().async {
                        itemProvider.loadItem(forTypeIdentifier: "public.image", options: nil) { item, error in
                            if (item as! NSObject) is URL{
                                //从相册中分享，此时图片已经在相册中，取到的是路径Url
                                let imageUrl = item as! URL
                                self.imageArr.append(imageUrl)
                            }else{
                                //截屏后点击分享，此时图片还未入库，所以拿到的是Image
                                let image = item as! UIImage
                                self.imageArr.append(image)
                            }
                            DispatchQueue.main.async {
                                if self.imageArr.count > 0 {
                                    self.shareType = "public.image"
                                    self.shareImageView.loadImageData(obj: self.imageArr)
                                    
                                }
                            }
                            
                        }
                    }
                }else if itemProvider.hasItemConformingToTypeIdentifier("public.movie"){
                    container.addSubview(self.shareMoveView)
                    DispatchQueue.global().async {
                        itemProvider.loadItem(forTypeIdentifier: "public.movie", options: nil) { item, error in
                            if (item as! NSObject) is URL{
                                //从相册中分享，此时图片已经在相册中，取到的是路径Url
                                let movieUrl = item as! URL
                                DispatchQueue.main.async {
                                    self.shareContent = movieUrl.absoluteString
                                    self.shareType = "public.movie"
                                    self.shareMoveView.loadMoveData(url: movieUrl)
                                    return
                                }
                            }
                        }
                    }
                }else if itemProvider.hasItemConformingToTypeIdentifier("public.file-url"){
                    container.addSubview(self.shareFileView)
                    DispatchQueue.global().async {
                        itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
                            if (item as! NSObject) is URL{
                                let fileUrl = item as! URL

                                DispatchQueue.main.async {
                                    self.shareContent = fileUrl.absoluteString
                                    self.shareType = "public.file-url"
                                    self.shareFileView.loadFileData(fileName: fileUrl.absoluteString.fileName)
                                    
                                    return
                                }
                            }
                        }
                    }
                }else if itemProvider.hasItemConformingToTypeIdentifier("public.url"){
                    container.addSubview(self.shareUrlView)
                    DispatchQueue.global().async {
                        itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { item, error in
                            if (item as! NSObject) is URL{

                                let url = item as! URL
                                DispatchQueue.main.async {
                                    self.shareContent = url.absoluteString
                                    self.shareType = "public.url"
                                    self.shareUrlView.loadUrlData(url: url)
                                    return
                                }
                            }
                        }
                    }
                }else if itemProvider.hasItemConformingToTypeIdentifier("public.plain-text"){
                    container.addSubview(self.shareTextView)
                    DispatchQueue.global().async {
                        itemProvider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { item, error in
                            if (item as! NSObject) is String{
                                let content = item as! String
                                DispatchQueue.main.async {
                                    self.shareContent = content
                                    self.shareType = "public.plain-text"
                                    self.shareTextView.loadTextData(content: content)
                                    return
                                }
                            }
                        }
                    }
                }
            }

        }
        
        
    }
    
    
    @objc func onCancleShare(){
        let error = NSError(domain: "CustomShareError", code: NSUserCancelledError, userInfo: nil )
        self.extensionContext?.cancelRequest(withError: error)
    }
   
    @objc func onSureShare(){
        let fileManager = FileManager.default
        let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.hw.swiftDemo")
        let fileUrl = groupUrl!.appendingPathComponent("shareContent.txt")
        switch self.shareType {
        case "public.url":
            let urlTitle = self.shareUrlView.titleContent
            if urlTitle != nil {
                shareContent.append("|--myBox--|")
                shareContent.append(urlTitle!)
            }
            try? shareContent.write(to: fileUrl, atomically: true, encoding: .utf8)
        case "public.plain-text":
            try? shareContent.write(to: fileUrl, atomically: true, encoding: .utf8)
        case "public.file-url","public.movie":
            let data = try? Data(contentsOf: URL(string: shareContent)!)
            let fileName = shareContent.fileName
            let desPath = "\(groupUrl!.path)/\(fileName)"
            fileManager.createFile(atPath: desPath, contents: data, attributes: nil)
            try? fileName.write(to: fileUrl, atomically: true, encoding: .utf8)
            
        case "public.image":
            var destImageArr:[String] = []
            for obj in self.imageArr {
                var imageName = ""
                var data = Data()
                if obj is UIImage {
                    data = (obj as! UIImage).pngData()!
                    imageName = .random
                }else if obj is URL{
                    let imageURL = (obj as! URL)
                    data = try! Data(contentsOf: imageURL)
                    imageName = imageURL.absoluteString.fileName
                }
                let desPath = "\(groupUrl!.path)/\(imageName)"
                fileManager.createFile(atPath: desPath, contents: data, attributes: nil)
                destImageArr.append(imageName)
            }
            let imageTotalStr = destImageArr.joined(separator: ",")
            try? imageTotalStr.write(to: fileUrl, atomically: true, encoding: .utf8)
            
        default:
            break
        }
        
        let openUrl = URL(string: "MoLingFen://shareExtension//\(shareType)")!
        if UIApplication.shared.canOpenURL(openUrl) {
            UIApplication.shared.open(openUrl, options: [:], completionHandler: nil)
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
        
    }
    
    
    lazy var shareUrlView :CDShareUrlView = {
        let urlView = CDShareUrlView(frame: CGRect(x: 0, y: 70, width: container.frame.width, height: 150))
//        container.addSubview(urlView)
        return urlView
    }()
    
    lazy var shareTextView :CDShareTextView = {
        let textView = CDShareTextView(frame: CGRect(x: 0, y: 70, width: container.frame.width, height: 120))
//        container.addSubview(textView)
        return textView
    }()
    
    lazy var shareFileView :CDShareFileView = {
        let fileView = CDShareFileView(frame: CGRect(x: 0, y: 70, width: container.frame.width, height: 80))
//        container.addSubview(fileView)
        return fileView
    }()
    
    lazy var shareImageView :CDShareImageView = {
        let imageView = CDShareImageView(frame: CGRect(x: 0, y: 70, width: container.frame.width, height: container.frame.width + 30))
        return imageView
    }()
    
    lazy var shareMoveView :CDShareMoveView = {
        let moveView = CDShareMoveView(frame: CGRect(x: 0, y: 70, width: container.frame.width, height: self.view.frame.width + 30))
//        container.addSubview(moveView)
        return moveView
    }()
}
