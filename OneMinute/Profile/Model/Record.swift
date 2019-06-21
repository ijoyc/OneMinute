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
  
  private static var fromFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = .current
    formatter.locale = Locale(identifier: "en_GB")
    formatter.calendar = Calendar(identifier: .gregorian)
    return formatter
  }
  
  private static var toFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM.dd HH:mm"
    formatter.timeZone = .current
    formatter.locale = Locale(identifier: "en_GB")
    formatter.calendar = Calendar(identifier: .gregorian)
    return formatter
  }
  
  var timeString: String {
    guard let date = Record.fromFormatter.date(from: time) else { return "00.00 00:00" }
    return Record.toFormatter.string(from: date)
  }
  
  init(json: [String: Any]) {
    self.type = OrderType(rawValue: json["orderType"] as? Int ?? 0) ?? .buy
    self.time = json["createTime"] as? String ?? ""
    self.orderID = json["orderNo"] as? String ?? ""
    self.remark = json["remark"] as? String ?? ""
    self.amount = Double(exactly: json["amount"] as? NSNumber ?? 0) ?? 0
  }
}
