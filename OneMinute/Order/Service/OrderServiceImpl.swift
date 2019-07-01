//
//  OrderServiceImpl.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/8.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

class OrderAPIImplementation : OrderAPI {
  static let shared = OrderAPIImplementation()
  
  func queryOrders(withCategory category: Int, page: Int, size: Int) -> Observable<(orders: [Order], hasMore: Bool)> {
    return OneMinuteAPI.get(.orders, parameters: ["flag": "1", "pageNum": page, "pageSize": size, "type": category]).map { json in
      var hasMore = true
      guard let data = json["data"] as? [String: Any] else {
        return (orders: [], hasMore: hasMore)
      }
      
      guard let list = data["list"] as? [[String: Any]], list.count > 0 else {
        return (orders: [], hasMore: hasMore)
      }
      
      let orders = list.map { Order(json: $0) }
      
      if let pages = data["pages"] as? Int, page >= pages {
        hasMore = false
      }
      
      return (orders: orders, hasMore: hasMore)
    }
  }
  
  func queryOrderDetail(with id: Int) -> Observable<(orderDetail: OrderDetail?, result: Result)> {
    return OneMinuteAPI.get(.orderDetail, parameters: ["orderId": id]).map { json in
      guard let data = json["data"] as? [String: Any] else {
        return (orderDetail: nil, result: Result(success: false, message: json["message"] as? String ?? ""))
      }

      return (orderDetail: OrderDetail(json: data), result: Result(success: true, message: ""))
    }
  }
  
  func changeOrderState(with id: Int, state: Int) -> Observable<Result> {
    let latitude = LBSServiceImpl.shared.currentLocation?.coordinate.latitude ?? 0
    let longitude = LBSServiceImpl.shared.currentLocation?.coordinate.longitude ?? 0
    return OneMinuteAPI
      .post(.changeOrderState,
            parameters: ["lat": latitude, "lng": longitude, "orderFlag": state, "orderId": id])
      .map { Result(json: $0) }
  }
  
  func finishOrder(with id: Int, code: String) -> Observable<Result> {
    let latitude = LBSServiceImpl.shared.currentLocation?.coordinate.latitude ?? 0
    let longitude = LBSServiceImpl.shared.currentLocation?.coordinate.longitude ?? 0
    return OneMinuteAPI
      .post(.finishOrder,
            parameters: ["lat": latitude, "lng": longitude, "orderId": id, "completeCode": code])
      .map { Result(json: $0) }
  }
}
