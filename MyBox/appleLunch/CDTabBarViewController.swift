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
        addChildViewControll(vc: CDSafeViewController(), title: LocalizedString("Box"), imageName: "safe_normal", selectImageName: "safe_select")
        addChildViewControll(vc: CDReaderListViewController(), title: LocalizedString("Reader"), imageName: "reader_normal", selectImageName: "reader_select")
        addChildViewControll(vc: CDMusicViewController(), title: LocalizedString("Music"), imageName: "music_normal", selectImageName: "music_select")
        addChildViewControll(vc: CDMineViewController(), title: LocalizedString("Mine"), imageName: "mine_normal", selectImageName: "mine_select")

//        self.tabBar.backgroundImage = UIImage(named: "下导航-bg")
        self.tabBar.backgroundColor = .baseBgColor
        self.tabBarController?.selectedIndex = 0
    
    }

    private func addChildViewControll(vc:UIViewController,title:String,imageName:String,selectImageName:String){
        vc.title = title
        vc.tabBarItem.image = LoadImage(imageName)
        vc.tabBarItem.selectedImage = LoadImage(selectImageName)
        let naVC = CDNavigationController(rootViewController: vc)
        self.addChild(naVC)
        
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
