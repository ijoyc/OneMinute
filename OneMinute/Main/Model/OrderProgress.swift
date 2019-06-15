//
//  OrderProgress.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

public enum ProgressType : Int, CustomStringConvertible {
  case buy = 1
  case receive
  case get
  case take
  case send

  public var description: String {
    switch self {
    case .buy:
      return "买"
    case .receive:
      return "收"
    case .get:
      return "取"
    case .take:
      return "接"
    case .send:
      return "送"
    }
  }
  
  var iconColor: UIColor {
    switch self {
    case .buy, .get, .take:
      return UIColor.RGBA(238, 54, 0, 1)
    case .receive, .send:
      return UIColor.RGBA(129, 215, 207, 1)
    }
  }
  
  static func create(with orderType: OrderType, index: Int) -> ProgressType {
    switch orderType {
    case .buy:
      return index == 0 ? .buy : .receive
    case .take:
      return index == 0 ? .receive : .get
    case .send:
      return index == 0 ? .get : .receive
    case .transfer:
      return index == 0 ? .take : .send
    default:
      return .receive
    }
  }
}

struct OrderProgress {
  let title: String
  let desc: String
}
