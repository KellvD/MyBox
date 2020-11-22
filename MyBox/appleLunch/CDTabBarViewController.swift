//
//  CDTabBarViewController.swift
//  MyBox
//
//  Created by changdong  on 2020/6/29.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit

class CDTabBarViewController: UITabBarController,UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        addChildViewControll(vc: CDSafeViewController(), title: "魔方", imageName: "safe_normal", selectImageName: "safe_select")
        addChildViewControll(vc: CDReaderListViewController(), title: "电子书", imageName: "reader_normal", selectImageName: "reader_select")
        addChildViewControll(vc: CDMusicViewController(), title: "幻音", imageName: "music_normal", selectImageName: "music_select")
        addChildViewControll(vc: CDMineViewController(), title: "我的", imageName: "mine_normal", selectImageName: "mine_select")

        self.tabBar.backgroundImage = UIImage(named: "下导航-bg")
        self.tabBarController?.selectedIndex = 0
    
    }

    private func addChildViewControll(vc:UIViewController,title:String,imageName:String,selectImageName:String){
        vc.title = title
        vc.tabBarItem.image = LoadImage(imageName: imageName, type: "png")
        vc.tabBarItem.selectedImage = LoadImage(imageName: selectImageName, type: "png")
        let naVC = CDNavigationController(rootViewController: vc)
        self.addChild(naVC)
        
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
