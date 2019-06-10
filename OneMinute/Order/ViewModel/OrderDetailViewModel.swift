//
//  OrderDetailViewModel.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/10.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

class OrderDetailViewModel {
  // - Output
  
  let orderDetail: Driver<OrderDetail>
  
  init(orderID: Int, api: OrderAPI) {
    orderDetail = api.queryOrderDetail(with: orderID).asDriver(onErrorJustReturn: OrderDetail(json: [String: Any]()))
  }
}
