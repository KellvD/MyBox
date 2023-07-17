//
//  CDNetworkTools.swift
//  HttpDemo
//
//  Created by changdong on 2020/8/21.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
let REQUESTTIMEOUT = 15.0
enum CDHttpMethod: String {
    case Post = "POST"
    case Get = "GET"
}

// 网络请求返回的response，info,error
typealias CompletionHandler = (Any?, Any?) -> Void
class CDNetworkTools: NSObject, URLSessionDelegate {

    public static let getInstance = CDNetworkTools()
    private let queue = OperationQueue()
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = REQUESTTIMEOUT
        let sess = URLSession(configuration: config, delegate: self, delegateQueue: queue)
        return sess
    }()

    /** http请求
     *@method 请求方法
     *@param url 地址
     *@param param 请求体
     *@param completion 回调
     */
    public func request(method: CDHttpMethod, url: String, param: Any, completionHandle:@escaping CompletionHandler) {
        if url.isEmpty {
            completionHandle(nil, "请求地址异常")
        }
        // 创建请求对象
        var request = URLRequest(url: URL(string: url)!)
        // 设置header
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = ["Content-Type": "/*/",
                                       "Accept": "/*/",
                                       "User-Agent": "iOS",
                                       "Charset": "UTF-8"]
        request.timeoutInterval = REQUESTTIMEOUT
        request.httpBody = try! JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
        let task: URLSessionDataTask = self.session.dataTask(with: request) { (data, response, error) in
            self.parseHttpResponse(data: data, response: response, error: error, completionHandle: completionHandle)
        }
        task.resume()
    }

    /** 上传文件
    *@method 请求方法
    *@param url 地址
    *@param param 文件
    *@param completion 回调
    */
    public func upload(url: String, param: [String: Any]?, filepPath: String, completionHandle:@escaping CompletionHandler) {
        if url.isEmpty {
            completionHandle(nil, "上传文件地址异常")
        }
        // 创建请求对象
        var request = URLRequest(url: URL(string: url)!)
        // 设置header
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "/*/",
                                       "Accept": "/*/",
                                       "User-Agent": "iOS",
                                       "Charset": "UTF-8"]
        request.timeoutInterval = REQUESTTIMEOUT

//        request.httpBody = try! JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
        let fileData = try! Data(contentsOf: filepPath.url)
        let task: URLSessionDataTask = self.session.uploadTask(with: request, from: fileData, completionHandler: { (data, response, error) in
            self.parseHttpResponse(data: data, response: response, error: error, completionHandle: completionHandle)
        })
        task.resume()
    }

    /**
     * 处理返回的x响应
     */
    private func parseHttpResponse(data: Data?, response: URLResponse?, error: Error?, completionHandle: @escaping CompletionHandler) {

        if response == nil {
            print("返回response为nil")
            return
        }
        let resp: HTTPURLResponse = response as! HTTPURLResponse
        if error == nil &&
            data != nil &&
            resp.statusCode == 200 {
            do {
                let dic = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                completionHandle(dic, nil)
            } catch {
                let str = String(data: data!, encoding: .utf8)
                completionHandle(str, nil)
            }
        } else {
            completionHandle(nil, error)
        }

    }

    /**
     *URLAuthenticationChallenge 授权质问
     *AuthChallengeDisposition 响应身份验证
     */
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
//            //服务端
//            let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
//            //从信任管理链中获取第一个证书
//            let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
//            //提取证书信息 copy返回X.509 cer
//            let remoteCertificateData = CFBridgingRetain(SecCertificateCopyKey(certificate!)) as! Data
//            let cerPath = Bundle.main.path(forResource: "", ofType: "")
//            let localCertivicateData = try! Data(contentsOf: URL(fileURLWithPath: cerPath!))
//            
//            //证书校验
//            if localCertivicateData == remoteCertificateData{
//                let credential = URLCredential(trust: serverTrust)
//                //尝试继续请求，不提供证书作为凭据
//                challenge.sender?.continueWithoutCredential(for: challenge)
//                //提供证书建立连接
//                challenge.sender?.use(credential, for: challenge)
//                //回调给服务器，使用该凭证继续连接
//                completionHandler(URLSession.AuthChallengeDisposition.useCredential,URLCredential(trust: challenge.protectionSpace.serverTrust!))
//            } else {
//                //证书验证不通过
//                challenge.sender?.cancel(challenge)
//                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge,nil)
//            }
//            
//            
//            
//            
//        }
//        
//        
//    }
}
