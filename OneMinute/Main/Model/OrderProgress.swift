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
}

class OrderProgress {
  let type: ProgressType
  let title: String
  let desc: String
  
  init(json: [String: Any]) {
    self.type = ProgressType(rawValue: json["type"] as? Int ?? 1) ?? .buy
    self.title = json["title"] as? String ?? ""
    self.desc = json["desc"] as? String ?? ""
  }
}
