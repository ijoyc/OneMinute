//
//  UIColor+Common.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/5.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

extension UIColor {
  static func RGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
  }
  
  open class var separateLine: UIColor {
    return RGBA(245, 245, 245, 1)
  }
  
  open class var omTextGray: UIColor {
    return RGBA(153, 153, 153, 1)
  }
  
  open class var themeGreen: UIColor {
    return RGBA(132, 215, 207, 1)
  }
}
