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

class Order {
  public static let numberOfOrdersPerPage = 20
  
  let type: OrderType
  let time: TimeInterval
  let distance: String
  let progresses: [OrderProgress]
  let progress: Int
  let profit: String
  
  var timeString: String {
    return "2019.04.11 15:16"
  }
  
  init(json: [String: Any]) {
    self.type = OrderType(rawValue: (json["type"] as? Int) ?? 1) ?? .buy
    self.time = json["time"] as? TimeInterval ?? 0
    self.distance = json["distance"] as? String ?? ""
    
    var progresses = [OrderProgress]()
    for progress in (json["progresses"] as? Array ?? []) {
      guard let progress = progress as? [String: Any] else { continue }
      progresses.append(OrderProgress(json: progress))
    }
    self.progresses = progresses
    
    self.progress = json["progress"] as? Int ?? 1
    self.profit = json["profit"] as? String ?? ""
  }
}
