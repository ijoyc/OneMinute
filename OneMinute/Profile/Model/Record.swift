//
//  Record.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/13.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import Foundation

class Record {
  public static let numberOfRecordsPerPage = 20
  
  let type: OrderType
  let time: String
  let orderID: String
  let remark: String
  let amount: Double
  
  init(json: [String: Any]) {
    self.type = OrderType(rawValue: json["orderType"] as? Int ?? 1) ?? .buy
    self.time = json["createTime"] as? String ?? ""
    self.orderID = json["orderNo"] as? String ?? ""
    self.remark = json["remark"] as? String ?? ""
    self.amount = Double(exactly: json["amount"] as? NSNumber ?? 0) ?? 0
  }
}
