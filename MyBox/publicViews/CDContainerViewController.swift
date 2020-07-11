//
//  CDContainerViewController.swift
//  MyBox
//
//  Created by changdong  on 2020/6/11.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit

class CDContainerViewController: UIViewController,UIGestureRecognizerDelegate {
              
    var boxView = UIView()
    var sideView = UIView()
    var edgePan:UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(boxView)
        view.addSubview(sideView)
        
        boxVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addChild(boxVC)
        boxVC.view.frame = self.view.bounds
        boxView.addSubview(boxVC.view)
        boxVC.didMove(toParent: self)
        
        sideVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addChild(sideVC)
        sideVC.view.frame = self.view.bounds
        sideView.addSubview(sideVC.view)
        sideVC.didMove(toParent: self)
        
        edgePan = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(tap:)))
        edgePan.delegate = self
        boxView.addGestureRecognizer(edgePan)
    }
    

    @objc func panGestureRecognizer(tap:UIPanGestureRecognizer) {
//        let point = tap.translation(in: self.view)
//        let velocityX = tap.translation(in: self.view).x
//        if velocityX >  {
//            <#code#>
//        }
        
    }
    
    lazy var boxVC: CDSafeViewController = {
        let boxVC = CDSafeViewController()
        return boxVC
    }()
    
    lazy var sideVC: CDSideViewController = {
        let sideVC = CDSideViewController()
        return sideVC
    }()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
