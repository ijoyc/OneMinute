//
//  Common.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/5.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

func OMGetSafeArea() -> UIEdgeInsets {
  if #available(iOS 11.0, *) {
    return UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets.zero
  } else {
    return UIEdgeInsets.zero
  }
}
