//
//  UIScrollView+Common.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

extension UIScrollView {
  func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
    return self.contentOffset.y + self.frame.height + edgeOffset > self.contentSize.height
  }
}
