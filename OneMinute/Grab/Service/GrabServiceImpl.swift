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
    return Observable.of((orders: [Order.init(json:
      [
        "type": 1,
        "time": "2019-11-11 11:11",
        "distance": "距离我1.2km",
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
        "profit": "$20.00"
      ]),
      Order.init(json: [
        "type": 2,
        "time": "2019-11-11 11:11",
        "distance": "距离我1.2km",
        "progresses": [
          [
            "type": 3,
            "title": "星巴克(华润万象汇店)",
            "desc": "华润万象小汇的对面"
          ],
          [
            "type": 4,
            "title": "元岗创意园",
            "desc": "广东省广州市天河区元岗天河客运站元岗创意园"
          ],
          [
            "type": 5,
            "title": "元岗创意园2",
            "desc": "广东省广州市天河区元岗天河客运站元岗创意园2广东省广州市天河区元岗天河客运站元岗创意园2"
          ]
        ],
        "progress": 1,
        "profit": "$20.00"
      ]
      )], hasMore: true)).delay(.seconds(2), scheduler: MainScheduler.instance)
  }
}
