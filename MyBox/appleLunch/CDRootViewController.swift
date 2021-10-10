//
//  CDRootViewController.swift
//  MyBox
//
//  Created by changdong on 2021/2/26.
//  Copyright © 2021 changdong. All rights reserved.
//

import UIKit
import CoreText
class CDRootViewController: UIViewController,UIScrollViewDelegate {

    var scrollerView:UIScrollView!
    var pageView:UIPageControl!
    //记录是否第一次让按钮出现
    var isFirst = true
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageView = UIPageControl()
        pageView.center = CGPoint(x: CDSCREEN_WIDTH/2.0, y: CDSCREEN_HEIGTH - 30)
        pageView.currentPageIndicatorTintColor = .red
        pageView.pageIndicatorTintColor = .white
        pageView.numberOfPages = dataArr.count
        
        
        scrollerView = UIScrollView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        scrollerView.delegate = self
        scrollerView.bounces = false
        scrollerView.showsHorizontalScrollIndicator = false
        scrollerView.isPagingEnabled = true
        scrollerView.contentSize = CGSize(width: CGFloat(dataArr.count) * CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH)
        self.view.addSubview(scrollerView)
        self.view.addSubview(pageView)
        
        scrollerView.addSubview(enterBtn)
        initData()
    }
    
    func initData() {

        for i in 0..<4 {
            let label = UILabel(frame: self.view.bounds)
            label.text = dataArr[i]
            label.font = UIFont.systemFont(ofSize: 100, weight: .regular)
            label.textAlignment = .center
            label.addBackgroundGradient(colors: [.red,.green,.blue], locations: [0.2,0.5,0.7], direction: .vertical)
            
            var frmae = label.frame
            frmae.origin.x = CGFloat(i) * frmae.width
            label.frame = frmae
            scrollerView.addSubview(label)
        }
    }

    let enterBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 4.0 * CDSCREEN_WIDTH - 15.0 - 75.0, y: CDSCREEN_HEIGTH - 15.0 - 30, width: 75.0, height: 30.0), text: "跳过".localize, textColor: .red, target: self, function: #selector(onEnterBoxView))
        btn.layer.borderWidth = 2.0
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.cornerRadius = 4.0
        return btn
    }()
    
    let dataArr: [String] = {
        let arr = ["墨","凌","风","起"]
        return arr
    }()
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = scrollerView.contentOffset.x/CDSCREEN_WIDTH
        pageView.currentPage = Int(index)
    }

    
    @objc func onEnterBoxView(){
        CDSignalTon.shared.tab = CDTabBarViewController()
        let myDelegate = UIApplication.shared.delegate as! CDAppDelegate
        myDelegate.window?.rootViewController = CDSignalTon.shared.tab
    }
}
