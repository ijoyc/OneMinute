//
//  Order.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

enum OrderType : Int, CustomStringConvertible {
  /** 代买 */
  case buy = 1
  /** 代取 */
  case take
  /** 代送 */
  case send
  /** 接送 */
  case transfer
  
  var description: String {
    switch self {
    case .buy:
      return "代买"
    case .take:
      return "代取"
    case .send:
      return "代送"
    case .transfer:
      return "接送"
    }
  }
}

enum OrderState : Int, CustomStringConvertible {
  case doing = 1, finished, canceled
  
  public var description: String {
    switch self {
    case .finished:
      return "已完成"
    case .canceled:
      return "已取消"
    default:
      return "在路上"
    }
  }
  
  public var color: UIColor {
    switch self {
    case .finished:
      return .black
    case .canceled:
      return .omTextGray
    default:
      return .themeGreen
    }
  }
}

class Order {
  public static let numberOfOrdersPerPage = 20
  
  let type: OrderType
  let time: TimeInterval
  let distance: String?
  let state: OrderState?
  let progresses: [OrderProgress]
  let progress: Int
  let profit: String?
  
  var timeString: String {
    return "2019.04.11 15:16"
  }
  
  init(json: [String: Any]) {
    self.type = OrderType(rawValue: (json["type"] as? Int) ?? 1) ?? .buy
    self.time = json["time"] as? TimeInterval ?? 0
    self.distance = json["distance"] as? String
    self.state = OrderState(rawValue: (json["state"] as? Int ?? 0))
    
    var progresses = [OrderProgress]()
    for progress in (json["progresses"] as? Array ?? []) {
      guard let progress = progress as? [String: Any] else { continue }
      progresses.append(OrderProgress(json: progress))
    }
    self.progresses = progresses
    
    self.progress = json["progress"] as? Int ?? 1
    self.profit = json["profit"] as? String
  }
}
