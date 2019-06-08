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
  // - Output
  let cellModels = BehaviorRelay<[OrderCellModel]>(value: [])
  let hasMore = BehaviorRelay<Bool>(value: true)
  let loading: Driver<Bool>
  
  let bag = DisposeBag()
  
  // true: load more , false: refresh
  init(loadTrigger: Signal<Bool>, api: GrabAPI) {
    let activityIndicator = ActivityIndicator()
    loading = activityIndicator.asDriver()
    
    let loadNextPage = Driver.combineLatest(loading, hasMore.asDriver()) { !$0 && $1 }
    
    // true: load more
    loadTrigger.filter{ $0 }
      .withLatestFrom(loadNextPage)
      .filter{ $0 }
      .scan(0) { (page, _) -> Int in page + 1 }
      .do(onNext: { page in print("Request grab orders for page \(page).") })
      .flatMapLatest { page in
        return api.queryGrabOrders(withPage: page, size: Order.numberOfOrdersPerPage)
          .trackActivity(activityIndicator)
          .do(onNext: { [weak self] pairs in
            self?.hasMore.accept(pairs.hasMore)
          })
          .map { [weak self] pairs in
            guard let `self` = self else { return [] }
            return self.cellModels.value + pairs.orders.map { order in OrderCellModel(model: order) }
          }
          .asDriver(onErrorJustReturn: [])
      }
      .drive(cellModels)
      .disposed(by: bag)
  }
}
