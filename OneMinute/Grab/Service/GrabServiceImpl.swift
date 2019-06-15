//
//  GrabServiceImpl.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

/*
 let type: OrderType
 let time: TimeInterval
 let distance: String
 let progresses: [OrderProgress]
 let progress: Int
 let profit: String
 */

class GrabAPIImplementation : GrabAPI {
  static let shared = GrabAPIImplementation()
  
  func queryGrabOrders(withPage page: Int, size: Int) -> Observable<(orders: [Order], hasMore: Bool)> {
    return OneMinuteAPI.get(.orders, parameters: ["flag": "0", "pageNum": page, "pageSize": size]).map { json in
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
  
  func grabOrder(with id: Int) -> Observable<Result> {
    return OneMinuteAPI.post(.grabOrder, parameters: ["orderId": id]).map { json in
      let success = json["data"] as? Bool ?? false
      let message = json["message"] as? String ?? ""
      return Result(success: success, message: message)
    }
  }
}
