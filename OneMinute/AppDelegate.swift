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
    
    Config.storage = KeychainStorage.shared
    OneMinuteAPI.networkService = NetworkServiceImpl.shared
    
    if let _ = User.signInfo.token, let _ = User.signInfo.driverToken {
      self.window?.rootViewController = LauncherViewController()
    } else {
      self.window?.rootViewController = SigninViewController()
    }
    
    return true
  }

}

