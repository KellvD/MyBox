//
//  CDShareViewController.swift
//  Share
//
//  Created by cwx889303 on 2021/10/9.
//  Copyright © 2021 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

class CDShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        let extensionItem = self.extensionContext!.inputItems.first as? NSExtensionItem
//        let itemProvider = extensionItem?.attachments?.first
//
//        if ((itemProvider?.hasItemConformingToTypeIdentifier("public.image")) != nil){
//
        
        
        for obj in self.extensionContext!.inputItems {
            let extensionItem = obj as! NSExtensionItem
            for itemProvider:NSItemProvider in extensionItem.attachments! {
                if itemProvider.hasItemConformingToTypeIdentifier("public.image") {
                    DispatchQueue.global().async {
                        itemProvider.loadItem(forTypeIdentifier: "public.image", options: nil) { item, error in
                            if (item as! NSObject) is URL{
                                //从相册中分享，此时图片已经在相册中，取到的是路径Url
                                let imageUrl = item as! URL
                            }else{
                                //截屏后点击分享，此时图片还未入库，所以拿到的是Image
                            }
                        }
                    }
                }else if itemProvider.hasItemConformingToTypeIdentifier("public.movie"){
                    DispatchQueue.global().async {
                        itemProvider.loadItem(forTypeIdentifier: "public.movie", options: nil) { item, error in
                            if (item as! NSObject) is URL{
                                //从相册中分享，此时图片已经在相册中，取到的是路径Url
                                let movieUrl = item as! URL
                            }
                        }
                    }
                }else if itemProvider.hasItemConformingToTypeIdentifier("public.file-url"){
                    DispatchQueue.global().async {
                        itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
                            if (item as! NSObject) is URL{
                                //从相册中分享，此时图片已经在相册中，取到的是路径Url
                                let fileUrl = item as! URL
                            }
                        }
                    }
                }else if itemProvider.hasItemConformingToTypeIdentifier("public.url"){
                    DispatchQueue.global().async {
                        itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { item, error in
                            if (item as! NSObject) is URL{
                                //从相册中分享，此时图片已经在相册中，取到的是路径Url
                                let url = item as! URL
                            }
                        }
                    }
                }else if itemProvider.hasItemConformingToTypeIdentifier("public.plain-text"){
                    DispatchQueue.global().async {
                        itemProvider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { item, error in
                            if (item as! NSObject) is String{
                                //从相册中分享，此时图片已经在相册中，取到的是路径Url
                                let content = item as! String
                            }
                        }
                    }
                }
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
