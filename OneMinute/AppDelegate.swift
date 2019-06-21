//
//  AppDelegate.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/5/31.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.main.bounds)
    // Override point for customization after application launch.
    self.window!.backgroundColor = UIColor.white
    self.window!.makeKeyAndVisible()
    
    UINavigationBar.appearance().tintColor = .black
    // hide back button title
    let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 0.1), NSAttributedString.Key.foregroundColor: UIColor.clear]
    UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
    UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .highlighted)
    
    // Global service register
    
    Config.storage = KeychainStorage.shared
    OneMinuteAPI.networkService = NetworkServiceImpl.shared
    
    // Request important permission
    LBSServiceImpl.shared.requestAuthorization()
    
    if let token = User.signInfo.token, token.count > 0 {
      self.window?.rootViewController = LauncherViewController()
    } else {
      self.window?.rootViewController = SigninViewController()
    }
    
    return true
  }

}

