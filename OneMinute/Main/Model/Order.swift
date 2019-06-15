//
//  Order.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

enum OrderType : Int, CustomStringConvertible {
  case buy, take, send, transfer, withdraw
  
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
    case .withdraw:
      return "提现"
    }
  }
}

enum OrderState : Int, CustomStringConvertible {
  case paying, grabing, grabed, doing, reached, payed, finished, timeout, canceled, chargeback
  
  public var description: String {
    switch self {
    case .paying:
      return "待付配送费"
    case .grabing:
      return "待接单(已付配送费)"
    case .grabed:
      return "正前往收货地址"
    case .doing:
      return "已到达取货位置(已买到商品)"
    case .reached:
      return "已到达目的地"
    case .payed:
      return "已支付商品费用"
    case .finished:
      return "已完成"
    case .timeout:
      return "支付超时"
    case .canceled:
      return "已取消"
    case .chargeback:
      return "已退单"
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
  
  let id: Int
  let orderNo: String
  let type: OrderType
  let time: TimeInterval
  let distance: Double
  let state: OrderState
  let progresses: [OrderProgress]
  let progress: Int
  let profit: Double
  let isGrabable: Bool
  
  private static var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    formatter.timeZone = .current
    formatter.locale = Locale(identifier: "en_GB")
    formatter.calendar = Calendar(identifier: .gregorian)
    return formatter
  }
  
  var timeString: String {
    return Order.dateFormatter.string(from: Date(timeIntervalSince1970: time))
  }
  
  init(json: [String: Any]) {
    self.id = json["id"] as? Int ?? 0
    self.type = OrderType(rawValue: (json["orderType"] as? Int) ?? 0) ?? .buy
    self.time = (TimeInterval(exactly: (json["createTime"] as? NSNumber ?? 0)) ?? 0) / 1000
    self.orderNo = json["orderNo"] as? String ?? ""
    
    self.state = OrderState(rawValue: (json["orderFlag"] as? Int ?? 0)) ?? .paying
    
    var progresses = [OrderProgress]()
    
    // add start point
    let startPoint = OrderProgress(title: json["addressNameGet"] as? String ?? "",
                                   desc: json["addressDetailGet"] as? String ?? "")
    progresses.append(startPoint)
    
    for progress in (json["addressReceiveList"] as? [[String: Any]] ?? []) {
      progresses.append(OrderProgress(title: progress["addressReceive"] as? String ?? "",
                                      desc: progress["addressReceiveDetail"] as? String ?? ""))
    }
    self.progresses = progresses
    self.progress = json["progress"] as? Int ?? 1
    
    self.distance = Double(exactly: json["distanceDriver"] as? NSNumber ?? 0) ?? 0
    self.profit = Double(exactly: json["feeDeliverDriver"] as? NSNumber ?? 0) ?? 0
    self.isGrabable = (json["catchFlag"] as? String ?? "0") == "0"
  }
}
