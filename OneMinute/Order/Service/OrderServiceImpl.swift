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
    return Observable.just((orders: [
      Order(json: [
        "type": 1,
        "time": "2019-11-11 11:11",
        "state": 1,
        "progresses": [
          [
            "type": 1,
            "title": "星巴克(华润万象汇店)(category: \(category))",
            "desc": "华润万象小汇的对面"
          ],
          [
            "type": 2,
            "title": "元岗创意园",
            "desc": "广东省广州市天河区元岗天河客运站元岗创意园"
          ]
        ],
        "progress": 1
        ]),
      Order(json: [
        "type": 2,
        "time": "2019-11-11 11:11",
        "state": 2,
        "progresses": [
          [
            "type": 3,
            "title": "星巴克(华润万象汇店)(category: \(category))",
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
        "progress": 1
        ]),
      Order(json: [
        "type": 1,
        "time": "2019-11-11 11:11",
        "state": 3,
        "progresses": [
          [
            "type": 1,
            "title": "星巴克(华润万象汇店)(category: \(category))",
            "desc": "华润万象小汇的对面"
          ],
          [
            "type": 2,
            "title": "元岗创意园",
            "desc": "广东省广州市天河区元岗天河客运站元岗创意园"
          ]
        ],
        "progress": 1
        ])
      ], hasMore: true)).delay(.seconds(1), scheduler: MainScheduler.instance)
  }
  
  func queryOrderDetail(with id: Int) -> Observable<OrderDetail> {
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
