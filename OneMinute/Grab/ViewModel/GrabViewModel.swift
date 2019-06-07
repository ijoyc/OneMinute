//
//  GrabViewModel.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

class GrabViewModel {
  // MARK: - Output
  
  let cellModels = BehaviorRelay<[OrderCellModel]>(value: [])
  let bag = DisposeBag()
  
  init(api: GrabAPI) {
    api.queryGrabOrders().map { orders in
      return orders.map { order in OrderCellModel(model: order) }
    }.bind(to: cellModels).disposed(by: bag)
  }
}
