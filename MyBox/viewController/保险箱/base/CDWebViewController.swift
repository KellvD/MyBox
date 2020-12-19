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
        processView = UIProgressView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 1))
        view.addSubview(processView)
        
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(x: 0, y: 1, width: CDSCREEN_WIDTH, height: CDViewHeight-1), configuration: config)
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
            print("网页加载进度 = %f",webView.estimatedProgress)
            processView.progress = Float(webView.estimatedProgress)
            if webView.estimatedProgress >= 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.processView.progress = 0
                }
            }
        }else if (keyPath == "title") {
            self.title = webView.title
        }
    }
    func loadUrl(url:URL){
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //页面加载失败
        self.processView.setProgress(0, animated: true)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //提交发生错误
        self.processView.setProgress(0, animated: true)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let url = navigationResponse.response.url
        print("当前跳转的地址：%s",url?.absoluteString)
        decisionHandler(.allow)
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
