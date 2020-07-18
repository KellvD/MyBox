//
//  AppDelegate.swift
//  MyRule
//
//  Created by changdong on 2018/11/12.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
@UIApplicationMain
class CDAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loginNav:UINavigationController?
    var isEnterBackground:Bool = false
    var defaultImageView:UIImageView!
    var defaultView:UIView!



    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let _ = CDSqlManager.shared
        let _ = CDSignalTon.shared
        let _ = CDMusicManager.shareInstance()
        let _ = CDEditManager.shareInstance()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = UIColor.white

        application.statusBarStyle = .lightContent
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0)
        shadow.shadowOffset = CGSize(width: 0, height: 0)

        let navBar = UINavigationBar.appearance()
        navBar.setBackgroundImage(UIImage(named: "上导航栏-背景@2x"), for: .default)
        var textAttributes:[NSAttributedString.Key:Any] = [:]
        textAttributes[.foregroundColor] = UIColor(red: 251/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1.0)
        textAttributes[.shadow] = shadow
        textAttributes[.attachment] = TextBigFont
        navBar.titleTextAttributes = textAttributes

        
        CDSignalTon.shared.tab = CDTabBarViewController()
        
        if !isFirstInstall(){
            self.window?.rootViewController = CDSignalTon.shared.tab
            let realpwd = CDSqlManager.shared.queryUserRealKeyWithUserId(userId: CDUserId())
            let fakePwd = CDSqlManager.shared.queryUserFakeKeyWithUserId(userId: CDUserId())
            if !realpwd.isEmpty || !fakePwd.isEmpty {
                let lockVC = CDLockViewController()
                loginNav = UINavigationController(rootViewController: lockVC)
            }

        }else{
            self.window?.rootViewController = CDSignalTon.shared.tab
        }
        
        if CDSignalTon.shared.waterBean.isOn {
            CDSignalTon.shared.addWartMarkToWindow(appWindow: window!)
        } else {
            CDSignalTon.shared.removeWaterMarkFromWindow(window: window!)
        }
        return true
    }

    func lockOrUnlock() {
        defaultImageView?.removeFromSuperview()
        defaultView?.removeFromSuperview()
        
        if isEnterBackground{
            isEnterBackground = false
            if self.window?.rootViewController != loginNav {
                self.loginNav?.popViewController(animated: false)
            }
        }
        if !isFirstInstall() {
            let realpwd = CDSqlManager.shared.queryUserRealKeyWithUserId(userId: CDUserId())
            let fakePwd = CDSqlManager.shared.queryUserFakeKeyWithUserId(userId: CDUserId())
            if !realpwd.isEmpty || !fakePwd.isEmpty {
                let lockVC = CDLockViewController()
                loginNav = UINavigationController(rootViewController: lockVC)

            }
        }
        isEnterBackground = false
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {

        //进入后台后的present的view全部dismiss，比如分享，拍照等
        if (CDSignalTon.shared.customPickerView != nil) {
            CDSignalTon.shared.customPickerView.dismiss(animated: true, completion: nil)
            CDSignalTon.shared.customPickerView = nil
        }
        
        if defaultImageView == nil {
            defaultImageView = UIImageView.init()
            defaultView = UIView.init()
        }
        defaultImageView.frame = CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight+64)
        defaultImageView.backgroundColor = CustomBlueColor
        defaultView.frame = CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDViewHeight+64)
        defaultView.addSubview(defaultImageView)

        let iconY = CDViewHeight > 667 ? 145 : 115
        
        let firstImage = UIImageView.init(frame: CGRect(x: Int((CDSCREEN_WIDTH-240)/2), y: iconY, width: 240, height: 170))
//        firstImage.image = LoadImageByName(imageName: "", type: "")
        defaultView.addSubview(firstImage)

        let label = UILabel.init(frame: CGRect(x: 0, y: iconY+170-30, width: Int(CDSCREEN_WIDTH), height: 40))
        label.textAlignment = .center
        label.text = getAppName()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        defaultView.addSubview(label)
        self.window?.addSubview(defaultView)
//        self.window?.bri




    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        lockOrUnlock()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let urlStr = url.absoluteString
        print(urlStr)
        
        return true
    }
}

