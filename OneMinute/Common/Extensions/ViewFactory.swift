//
//  ViewFactory.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import JGProgressHUD
import RxCocoa
import RxSwift

struct ViewFactory {
  static func label(withText text: String = "", font: UIFont = .systemFont(ofSize: 12)) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = font
    return label
  }
  
  static func separateLine() -> UIView {
    let view = UIView()
    view.backgroundColor = .separateLine
    return view
  }
  
  static func button(withTitle title: String, font: UIFont = .systemFont(ofSize: 12)) -> UIButton {
    let button = UIButton(type: .custom)
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = font
    return button
  }
  
  static func showAlert(_ title: String?, message: String? = nil, success: Bool = true) {
    let hud = JGProgressHUD(style: .dark)
    hud.indicatorView = success ? JGProgressHUDSuccessIndicatorView() : JGProgressHUDErrorIndicatorView()
    hud.textLabel.text = title
    if let message = message {
      hud.detailTextLabel.text = message
    }
    hud.show(in: currentViewController.view)
    hud.dismiss(afterDelay: 1.5)
  }
  
  private static var currentViewController: UIViewController {
    return topController(with: UIApplication.shared.keyWindow!.rootViewController!)
  }
  
  private static func topController(with controller: UIViewController) -> UIViewController {
    if let tabVC = controller as? UITabBarController {
      return topController(with: tabVC.selectedViewController!)
    } else if let naviVC = controller as? UINavigationController {
      return topController(with: naviVC.visibleViewController!)
    } else if let presentedVC = controller.presentedViewController {
      return topController(with: presentedVC)
    } else {
      return controller
    }
  }
}
