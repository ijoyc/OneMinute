//
//  ViewFactory.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

struct ViewFactory {
  static func label(withText text: String = "", font: UIFont = UIFont.systemFont(ofSize: 12)) -> UILabel {
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
  
  static func button(withTitle title: String, font: UIFont = UIFont.systemFont(ofSize: 12)) -> UIButton {
    let button = UIButton(type: .custom)
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = font
    return button
  }
}
