//
//  OrderService.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/8.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

protocol OrderAPI {
  func queryOrders(withCategory category: Int, page: Int, size: Int) -> Observable<(orders: [Order], hasMore: Bool)>
  func queryOrderDetail(with id: Int) -> Observable<OrderDetail>
}
