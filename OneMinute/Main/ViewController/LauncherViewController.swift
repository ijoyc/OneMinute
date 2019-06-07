//
//  LauncherViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/6.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

class LauncherViewController : UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  func setup() {
    UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.RGBA(0, 0, 0, 1)], for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.themeGreen], for: .selected)
    
    let grabController = GrabViewController()
    addChild(grabController, title: "抢单", image: "tab_grab")
    
    let orderController = OrderViewController()
    addChild(orderController, title: "订单", image: "tab_order")
    
    let profileController = ProfileViewController()
    addChild(profileController, title: "我的", image: "tab_profile")
  }
  
  private func addChild(_ childController: UIViewController, title: String, image: String) {
    let item = UITabBarItem(title: title, image: UIImage(named: image)?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "\(image)_highlight")?.withRenderingMode(.alwaysOriginal))
    childController.tabBarItem = item
    childController.title = title
    let navigationController = UINavigationController(rootViewController: childController)
    addChild(navigationController)
  }
  
}
