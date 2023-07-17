//
//  CDTabBarViewController.swift
//  MyBox
//
//  Created by changdong  on 2020/6/29.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit

class CDTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        addChildViewControll(vc: CDSafeViewController(), title: "墨方城".localize, imageName: "safe_normal", selectImageName: "safe_select")
        addChildViewControll(vc: CDReaderListViewController(), title: "凌烟阁".localize, imageName: "reader_normal", selectImageName: "reader_select")
        addChildViewControll(vc: CDAttendanceViewController(), title: "考勤".localize, imageName: "music_normal", selectImageName: "music_select")
        addChildViewControll(vc: CDMineViewController(), title: "起之".localize, imageName: "mine_normal", selectImageName: "mine_select")
        self.tabBarController?.selectedIndex = 0

        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .baseBgColor
            self.tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                self.tabBar.scrollEdgeAppearance = self.tabBar.standardAppearance
            }
        }

    }

    private func addChildViewControll(vc: UIViewController, title: String, imageName: String, selectImageName: String) {
        vc.title = title
        vc.tabBarItem.image = imageName.image
        vc.tabBarItem.selectedImage = LoadImage(selectImageName)

        let naVC = CDNavigationController(rootViewController: vc)
        self.addChild(naVC)

    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
