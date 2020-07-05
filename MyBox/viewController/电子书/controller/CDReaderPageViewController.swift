//
//  CDReadDetailViewController.swift
//  MyBox
//
//  Created by changdong cwx889303 on 2020/6/29.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit

let chapterViewWidth = CDSCREEN_WIDTH / 3 * 2

//class CDReadDetailViewController: CDBaseAllViewController,CDReaderToolBarDelegate,CDChapterViewDelegate,UIPageViewControllerDelegate,UIPageViewControllerDataSource {
//
//
//
////    public var resource:String!
////    public var model:CDReaderModel
////
////
////    private var toolsBar:CDReaderToolBar!
////    private var chapterView:CDChapterView!
////    private var chapterArr:[CDChapterModel] = []
////    private var readView:CDReaderViewController!  //当前视图
//
//    {
//        var chapter:Int = 0 //s当前显示章节
//        var page:Int = 0 //当前显示页数
//        var changeChapter:Int = 0//将要变化的章节
//        var changePage:Int = 0 //将要变化的页数
//        var isTransition:Bool = false //是否开始翻页
//
//
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.addChild(pageVC)
//
//
////        chapterView = CDChapterView(frame: CGRect(x: -chapterViewWidth, y: 0, width: chapterViewWidth, height: CDSCREEN_HEIGTH))
////        chapterView.myDelegate = self
////        self.view.addSubview(chapterView)
////
////        let index = CDConfigFile.getIntValueFromConfigWith(key: CD_ChapterIndex)
////        toolsBar = CDReaderToolBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - 173, width: CDSCREEN_WIDTH, height: 173))
////        toolsBar.delegate = self
////        toolsBar.chapterLabel.text = chapterArr[index].title
////        toolsBar.chapterTotalCount = chapterArr.count
////        toolsBar.chapterCurrentCount = index
////        self.view.addSubview(toolsBar)
//    }
//
//    lazy var pageVC: UIPageViewController = {
//        let page = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
//        page.delegate = self
//        page.dataSource = self
//        self.view.addSubview(page.view)
//        return page
//    }()
//    func onSelectChapter(index: Int) {
////        toolsBar.chapterLabel.text = chapterArr[index].title
////        CDConfigFile.setIntValueToConfigWith(key: CD_ChapterIndex, intValue: index)
//    }
//    func onPopChapterView() {
//        var rect = chapterView.frame
//        UIView.animate(withDuration: 0.25) {
//            rect.origin.x = rect.origin.x == 0 ? chapterViewWidth : 0
//            self.chapterView.frame = rect
//        }
//    }
//
//    func onChangeChapters(index:Int) {
//
//        toolsBar.chapterLabel.text = chapterArr[index].title
//        CDConfigFile.setIntValueToConfigWith(key: CD_ChapterIndex, intValue: index)
//    }
//
//    func onChangeBgModel(model: CDReaderBgModel) {
//
//    }
//
//
//
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        if !completed {
//            let readView = previousViewControllers.first as! CDReaderViewController
//
//        }
//    }
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        return nil
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        return nil
//    }
//}
