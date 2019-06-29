//
//  UIKit+Rx.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/29.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIRefreshControl {
  var title: Binder<String> {
    return Binder(base) { refreshControl, title in
      refreshControl.attributedTitle = NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.black])
    }
  }
}

extension Reactive where Base: UITextField {
  var placeholder: Binder<String> {
    return Binder(base) { textField, placeholder in
      textField.placeholder = placeholder
    }
  }
}

extension Reactive where Base: UITabBarItem {
  var title: Binder<String> {
    return Binder(base) {  item, title in
      item.title = title
    }
  }
}
