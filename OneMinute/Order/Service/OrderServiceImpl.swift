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
  
  func queryOrderDetail(with id: Int) -> Observable<OrderDetail?> {
//    return OneMinuteAPI.get(.orderDetail, parameters: ["orderId": id]).map { json in
//      guard let data = json["data"] as? [String: Any] else {
//        return nil
//      }
//
//      return OrderDetail(json: data)
//    }
    
    return Observable.just(OrderDetail.init(json: [
      "type": 1,
      "state": 3,
      "progresses": [
        [
          "type": 1,
          "title": "星巴克(华润万象汇店)",
          "desc": "华润万象小汇的对面"
        ],
        [
          "type": 2,
          "title": "元岗创意园",
          "desc": "广东省广州市天河区元岗天河客运站元岗创意园"
        ]
      ],
      "progress": 1,
      "orderID": "A201904093937563",
      "note": "麻烦帮我快点送过来，谢谢！",
      "telephone": "18463104321",
      "startLatitude": 30.308997,
      "startLongitude": 120.092703,
      "endLatitude": 30.273821,
      "endLongitude": 120.114909
      ])).delay(.seconds(1), scheduler: MainScheduler.instance)
  }
}
