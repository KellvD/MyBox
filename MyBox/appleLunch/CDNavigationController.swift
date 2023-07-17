//
//  CDNavigationController.swift
//  MyBox
//
//  Created by changdong on 2020/11/12.
//  Copyright © 2020 changdong. All rights reserved.
//

import UIKit

class CDNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0)
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .navgationBarColor
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        }
        var textAttributes: [NSAttributedString.Key: Any] = [:]
        textAttributes[.foregroundColor] = UIColor.white
        textAttributes[.shadow] = shadow
        textAttributes[.attachment] = UIFont.large
        self.navigationBar.titleTextAttributes = textAttributes

    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
