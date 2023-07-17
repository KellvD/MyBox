//
//  CDReaderPageViewController.swift
//  MyBox
//
//  Created by changdong on 2020/7/13.
//  Copyright changdong 2012-2019. All rights reserved.
//

import UIKit

class CDReaderPageViewController: CDBaseAllViewController, CDReaderToolBarDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, CDChapterViewControllerDelegate {

    public var resource: String!

    private var greadView: CDReaderViewController!  // 当前视图
    private var toolsView: CDReaderToolBar!
    private var _hiddenNavBar: Bool = false
    private var _chapterIndex: Int = 0 // s当前显示章节
    private var _pageIndex: Int = 0 // 当前显示页数
    private var _changeChapterIndex: Int = 0// 将要变化的章节
    private var _changePageIndex: Int = 0 // 将要变化的页数
    private var _isTransition: Bool = false // 是否开始翻页
    private var barStyle: UIStatusBarStyle!

    override var prefersStatusBarHidden: Bool {
        return _hiddenNavBar
    }

    override func viewWillDisappear(_ animated: Bool) {
        barStyle = .default
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "上导航栏-背景"), for: .default)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return barStyle
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        CDHUDManager.shared.showWait("正在加载中，请稍等...")
        self.addChild(self.pageVC)
        CDReaderManager.shared.laodFile(filePath: self.resource)
        NotificationCenter.default.addObserver(forName: NSNotification.Name("TXTLoadToModel"), object: nil, queue: OperationQueue.main) { (_) in
            CDHUDManager.shared.hideWait()
            self.pageVC.setViewControllers([self.readViewChapter(chapter: CDReaderManager.shared.readModel.chapterIndex,
                                                                 page: CDReaderManager.shared.readModel.pageIndex)],
                                           direction: .forward,
                                           animated: true,
                                           completion: nil)
            self._chapterIndex = CDReaderManager.shared.readModel.chapterIndex
            self._pageIndex = CDReaderManager.shared.readModel.pageIndex
            self.toolsView.updateProcess()
        }
        let height: CGFloat = iPhoneX ? 300 : 220
        self.toolsView = CDReaderToolBar(frame: CGRect(x: 0, y: CDSCREEN_HEIGTH - height, width: CDSCREEN_WIDTH, height: height))
        self.toolsView.delegate = self
        self.view.addSubview(self.toolsView)
        let popBtn = UIButton(type: .custom)
        popBtn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        popBtn.setImage(UIImage(named: "back_normal"), for: .normal)
        popBtn.setImage(UIImage(named: "back_pressed"), for: .selected)
        popBtn.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: popBtn)

        self.onChangeTheme()
        self.hiddenNavBar()

        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenNavBar))
        self.pageVC.view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(onChangeTheme), name: NSNotification.Name("changeTheme"), object: nil)

    }

    lazy var pageVC: UIPageViewController = {
        let page = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        page.delegate = self
        page.dataSource = self
        self.view.addSubview(page.view)
        return page
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        self.pageVC.view.frame = CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH)
    }

   @objc private func onChangeTheme() {
        self.view.backgroundColor = CDReaderManager.shared.config.theme
        self.pageVC.view.backgroundColor = CDReaderManager.shared.config.theme
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.barTintColor = CDReaderManager.shared.config.theme
        if CDReaderManager.shared.config.theme == night {
            barStyle = .lightContent
        } else {
            if #available(iOS 13.0, *) {
                barStyle = .darkContent
            } else {
                barStyle = .default
            }
        }
    }

   func onDidChangeFont() {
        let currentChapter = CDReaderManager.shared.readModel.chaptersArr[CDReaderManager.shared.readModel.chapterIndex]
        currentChapter.updateFont()

        let page = CDReaderManager.shared.readModel.pageIndex > (currentChapter.pageCount - 1) ?
            currentChapter.pageCount - 1 :
            CDReaderManager.shared.readModel.pageIndex

        pageVC.setViewControllers([readViewChapter(chapter: CDReaderManager.shared.readModel.chapterIndex,
                                                   page: page)],
                                  direction: .forward,
                                  animated: false,
                                  completion: nil)
        updateReadModel(chapterIndex: CDReaderManager.shared.readModel.chapterIndex, page: page)

    }

    @objc func hiddenNavBar() {

        _hiddenNavBar = !_hiddenNavBar
        self.toolsView.isHidden = _hiddenNavBar
        self.navigationController?.navigationBar.isHidden = _hiddenNavBar
    }

     // CDReaderToolBarDelegate
       func onDidSelectedChapter() {
           hiddenNavBar()
           let chapterVC = CDChapterViewController()
           chapterVC.myDelegate = self
           chapterVC.modalPresentationStyle = .popover
           self.present(chapterVC, animated: true, completion: nil)
       }

       func onDidChangeChapterProcess(process: Int) {
           updateReadModel(chapterIndex: process, page: 0)
           pageVC.setViewControllers([readViewChapter(chapter: process, page: 0)], direction: .forward, animated: true, completion: nil)
       }
       // CDChapterViewControllerDelegate
       func onDidSelectdChapter(chapterIndex: Int) {
           updateReadModel(chapterIndex: chapterIndex, page: 0)
           pageVC.setViewControllers([readViewChapter(chapter: chapterIndex, page: 0)], direction: .forward, animated: true, completion: nil)
       }

       //
       func readViewChapter(chapter: Int, page: Int) -> CDReaderViewController {
           if CDReaderManager.shared.readModel.chapterIndex != chapter {
               updateReadModel(chapterIndex: chapter, page: page)
               CDReaderManager.shared.readModel.chapterModel.updateFont()
           }
           greadView = CDReaderViewController()
           greadView.content = CDReaderManager.shared.readModel.chaptersArr[chapter].stringOfPage(index: page)
           greadView.hiddenNavBar = _hiddenNavBar
           greadView.pageIndex = CDReaderManager.shared.readModel.pageIndex
           greadView.chapterIndex = CDReaderManager.shared.readModel.chapterIndex
           return greadView
       }

       func updateReadModel(chapterIndex: Int, page: Int) {
           _chapterIndex = chapterIndex
           _pageIndex = page
           CDReaderManager.shared.readModel.chapterIndex = chapterIndex
           CDReaderManager.shared.readModel.pageIndex = page
        CDReaderModel.updateLocalModel(model: CDReaderManager.shared.readModel, url: resource.url)
           self.toolsView.updateProcess()

       }

       // TODO:UIPageViewController
       func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
           if !completed {
               let readView = previousViewControllers.first as! CDReaderViewController
               greadView = readView
               _pageIndex = readView.pageIndex
               _chapterIndex = readView.chapterIndex

           } else {
              updateReadModel(chapterIndex: _chapterIndex, page: _pageIndex)
           }
       }

       func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
           _chapterIndex = _changeChapterIndex
           _pageIndex = _changePageIndex
       }

       func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
           if !_hiddenNavBar { hiddenNavBar()}
           _changeChapterIndex = _chapterIndex
           _changePageIndex = _pageIndex
           if _changeChapterIndex == 0 && _changeChapterIndex == 0 {
               return nil
           }

           // 页数为0章节-1
           if _changePageIndex == 0 {
               _changeChapterIndex -= 1
               _changePageIndex = CDReaderManager.shared.readModel.chaptersArr[_changeChapterIndex].pageCount - 1
           } else {
               _changePageIndex -= 1
           }
           return readViewChapter(chapter: _changeChapterIndex, page: _changePageIndex)
       }

       func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
           if !_hiddenNavBar { hiddenNavBar()}
           _changeChapterIndex = _chapterIndex
           _changePageIndex = _pageIndex
           if _changePageIndex == CDReaderManager.shared.readModel.chaptersArr.last!.pageCount - 1 &&
               _changeChapterIndex == CDReaderManager.shared.readModel.chaptersArr.count - 1 {
               return nil
           }

           if _changePageIndex == CDReaderManager.shared.readModel.chaptersArr[_changeChapterIndex].pageCount - 1 {
               _changeChapterIndex += 1
               _changePageIndex = 0
           } else {
               _changePageIndex += 1
           }
           return readViewChapter(chapter: _changeChapterIndex, page: _changePageIndex)
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
