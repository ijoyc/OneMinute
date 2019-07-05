//
//  Order.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum OrderType : Int {
  case buy, take, send, transfer, withdraw
  
  var localizedText: BehaviorRelay<String> {
    switch self {
    case .buy:
      return Config.localizedText(for: "buy")
    case .take:
      return Config.localizedText(for: "take")
    case .send:
      return Config.localizedText(for: "send")
    case .transfer:
      return Config.localizedText(for: "transfer")
    case .withdraw:
      return Config.localizedText(for: "withdraw")
    }
  }
}

enum OrderState : Int {
  case paying, grabing, grabed, doing, reached, finished, timeout = -1, canceled = -2, chargeback = -3
  
  public var localizedText: BehaviorRelay<String> {
    switch self {
    case .paying:
      return Config.localizedText(for: "paying")
    case .grabing:
      return Config.localizedText(for: "grabing")
    case .grabed:
      return Config.localizedText(for: "grabed")
    case .doing:
      return Config.localizedText(for: "doing")
    case .reached:
      return Config.localizedText(for: "reached")
    case .finished:
      return Config.localizedText(for: "finished")
    case .timeout:
      return Config.localizedText(for: "timeout")
    case .canceled:
      return Config.localizedText(for: "canceled")
    case .chargeback:
      return Config.localizedText(for: "chargeback")
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
  let createTime: TimeInterval
  let scheduleTime: String
  // 0: Instant Order, 1: Reservation Order
  let scheduleFlag: Int
  let distance: Double
  let state: OrderState
  let progresses: [OrderProgress]
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
  
//  var scheduleTimeString: String {
//    return Order.dateFormatter.string(from: Date(timeIntervalSince1970: scheduleTime))
//  }
  
  init(json: [String: Any]) {
    self.id = json["id"] as? Int ?? 0
    self.type = OrderType(rawValue: (json["orderType"] as? Int) ?? 0) ?? .buy
    self.createTime = (TimeInterval(exactly: (json["createTime"] as? NSNumber ?? 0)) ?? 0) / 1000
//    self.scheduleTime = (TimeInterval(exactly: (json["scheduleTime"] as? NSNumber ?? 0)) ?? 0) / 1000
    self.scheduleTime = json["scheduleTime"] as? String ?? ""
    self.scheduleFlag = json["scheduleFlag"] as? Int ?? 0
    self.orderNo = json["orderNo"] as? String ?? ""
    
    self.state = OrderState(rawValue: (json["orderFlag"] as? Int ?? 0)) ?? .paying
    
    var progresses = [OrderProgress]()
    
    // add start point
    let startPoint = OrderProgress(title: json["addressNameGet"] as? String ?? "",
                                   desc: json["addressDetailGet"] as? String ?? "")
    progresses.append(startPoint)
    
    for progress in (json["addressReceiveList"] as? [[String: Any]] ?? []) {
      progresses.append(OrderProgress(json: progress))
    }
    self.progresses = progresses
    
    self.distance = Double(exactly: json["distanceDriver"] as? NSNumber ?? 0) ?? 0
    self.profit = Double(exactly: json["feeDeliverDriver"] as? NSNumber ?? 0) ?? 0
    self.isGrabable = (json["catchFlag"] as? String ?? "0") == "0"
  }
}
