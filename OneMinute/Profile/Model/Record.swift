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
  let time: TimeInterval
  let orderID: String
  let remark: String
  let amount: Double
  
  private static var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM.dd HH:mm"
    formatter.timeZone = .current
    formatter.locale = Locale(identifier: "en_GB")
    formatter.calendar = Calendar(identifier: .gregorian)
    return formatter
  }

  var timeString: String {
    return Record.dateFormatter.string(from: Date(timeIntervalSince1970: time))
  }
  
  init(json: [String: Any]) {
    self.type = OrderType(rawValue: json["orderType"] as? Int ?? 0) ?? .buy
    self.time = (TimeInterval(exactly: (json["createTime"] as? NSNumber ?? 0)) ?? 0) / 1000
    self.orderID = json["orderNo"] as? String ?? ""
    self.remark = json["remark"] as? String ?? ""
    self.amount = Double(exactly: json["amount"] as? NSNumber ?? 0) ?? 0
  }
}
