//
//  LauncherViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/6.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LauncherViewController : UITabBarController {
  
  private let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
    
    _ = NotificationCenter.default.rx
      .notification(OneMinuteAPI.notSigninNotification)
      .takeUntil(self.rx.deallocated)
      .subscribe(onNext: { _ in
        User.signout()
        self.present(SigninViewController(), animated: true, completion: nil)
      });
  }
  
  func setup() {
    UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.RGBA(0, 0, 0, 1)], for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.themeGreen], for: .selected)
    
    let grabController = GrabViewController()
    addChild(grabController, title: Config.localizedText(for: "tab_grab"), image: "tab_grab")
    
    let orderController = OrderViewController()
    addChild(orderController, title: Config.localizedText(for: "tab_order"), image: "tab_order")
    
    let profileController = ProfileViewController()
    addChild(profileController, title: Config.localizedText(for: "tab_profile"), image: "tab_profile")
  }
  
  private func addChild(_ childController: UIViewController, title: BehaviorRelay<String>, image: String) {
    let item = UITabBarItem(title: "", image: UIImage(named: image)?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "\(image)_highlight")?.withRenderingMode(.alwaysOriginal))
    title.bind(to: item.rx.title).disposed(by: bag)
    childController.tabBarItem = item
    title.bind(to: childController.rx.title).disposed(by: bag)
    let navigationController = UINavigationController(rootViewController: childController)
    addChild(navigationController)
  }
  
}
