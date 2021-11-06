//
//  CDWebViewController.swift
//  MyRule
//
//  Created by changdong on 2019/6/21.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import WebKit

class CDWebViewController: CDBaseAllViewController,WKUIDelegate,WKNavigationDelegate {

    private var processView:UIProgressView!
    private var webView:WKWebView!
    public var url:URL!
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProcess")
        webView.removeObserver(self, forKeyPath: "title")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //进度条
        processView = UIProgressView(progressViewStyle: .default)
        processView.frame = CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 2)
        processView.progressTintColor = .customBlue
        processView.trackTintColor = .baseBgColor
        view.addSubview(processView)
        processView.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
        
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight-1))
        view.addSubview(webView)
        //UI代理
        webView.uiDelegate = self
        //导航代理
        webView.navigationDelegate = self
        //允许左滑返回上一级
        webView.allowsBackForwardNavigationGestures = true
        //进度条
        //监听网页加载进度
        webView.addObserver(self, forKeyPath: "estimatedProcess", options: .new, context: nil)
        //监听网页标题
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        loadUrl(url: url)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProcess") {
            let process = change![.newKey] as! Float
            print(process)
            if process == 1 {
                self.processView.setProgress(process, animated: true)
                UIView.animate(withDuration: 0.25, delay: 0.3, options: .curveEaseOut) {
                    self.processView.transform = CGAffineTransform(scaleX: 1.0, y: 1.4)
                } completion: { success in
                    self.processView.isHidden = true
                }

            }else{
                self.processView.setProgress(process, animated: true)
            }
        }else if (keyPath == "title") {
            self.title = webView.title
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    func loadUrl(url:URL){
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.processView.isHidden = false
        self.processView.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
        self.view.bringSubviewToFront(self.processView)
    }
//    // 页面加载完成之后调用
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self.processView.isHidden = true
//    }
//    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        //页面加载失败
//        self.processView.isHidden = true
//    }
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        //提交发生错误
//        self.processView.isHidden = true
//    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
