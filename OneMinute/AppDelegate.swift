//
//  AppDelegate.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/5/31.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.main.bounds)
    // Override point for customization after application launch.
    self.window!.backgroundColor = UIColor.white
    self.window!.makeKeyAndVisible()
    
    // Styles
    
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
    LBSServiceImpl.shared.start()
    
    // Push Notification
    if #available(iOS 10, *) {
      let entity = JPUSHRegisterEntity()
      entity.types = Int(JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue)
      JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
    } else {
      JPUSHService.register(forRemoteNotificationTypes: UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue | UIUserNotificationType.alert.rawValue, categories: nil)
    }
    
    JPUSHService.setup(withOption: launchOptions, appKey: Config.jpushAppKey, channel: Config.jpushChannel, apsForProduction: Config.isProduction)
    
    if User.isSignedIn() {
      LBSServiceImpl.shared.startUploadLocation()
      self.window?.rootViewController = LauncherViewController()
    } else {
      self.window?.rootViewController = SigninViewController()
    }
    
    return true
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("Device Token: \(token)")
    
    JPUSHService.registerDeviceToken(deviceToken)
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Did fail to register for remote notification with error \(error)")
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    print("Receive remote notification: \(userInfo)")
    JPUSHService.handleRemoteNotification(userInfo)
  }

  
  func applicationDidEnterBackground(_ application: UIApplication) {
    LBSServiceImpl.shared.stop()
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    LBSServiceImpl.shared.start()
  }
}

extension AppDelegate: JPUSHRegisterDelegate {
  @available(iOS 10.0, *)
  func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
    print("Will present notification \(notification.request.content)")
    let userInfo = notification.request.content.userInfo
    if let trigger = notification.request.trigger, trigger.isKind(of: UNPushNotificationTrigger.self) {
      JPUSHService.handleRemoteNotification(userInfo)
    }
    completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
  }
  
  @available(iOS 10.0, *)
  func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
    print("Did receive response: \(response!)")
    let userInfo = response.notification.request.content.userInfo
    if let trigger = response.notification.request.trigger, trigger.isKind(of: UNPushNotificationTrigger.self) {
      JPUSHService.handleRemoteNotification(userInfo)
    }
    
    completionHandler()
  }
  
  @available(iOS 10.0, *)
  func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {
    print("Open settings for notification")
    if let trigger = notification?.request.trigger, trigger.isKind(of: UNPushNotificationTrigger.self) {
      // Enter from notification screen
    } else {
      // Enter from notification setting page
    }
  }
  
  
}
