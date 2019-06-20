//
//  OrderViewModel.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/8.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

class OrderViewModel {
  // - Output
  let cellModels = BehaviorRelay<[OrderCellModel]>(value: [])
  let hasMore = BehaviorRelay<Bool>(value: true)
  // for load more
  let loading: Driver<Bool>
  // for refreshing or change category
  let refreshing: Driver<Bool>
  
  private let resetPage = BehaviorRelay<Bool>(value: false)
  
  let bag = DisposeBag()
  
  // true: load more , false: refresh
  init(input: (loadTrigger: Signal<Bool>, categoryTrigger: Signal<Int>), api: OrderAPI) {
    let loadTrigger = input.loadTrigger
    let categoryTrigger = input.categoryTrigger
    
    let activityIndicator = ActivityIndicator()
    loading = activityIndicator.asDriver()
    let refreshActivityIndicator = ActivityIndicator()
    refreshing = refreshActivityIndicator.asDriver()
    
    // Load More
    
    let loadNextPage = Driver.combineLatest(loading, hasMore.asDriver()) { !$0 && $1 }
    
    loadTrigger.filter { $0 }
      .withLatestFrom(loadNextPage)
      .filter { $0 }
      // After refreshing, the next page should be the second one.
      .scan(0) { [weak self] (page, _) in (self?.resetPage.value ?? true) ? 2 : page + 1 }
      .withLatestFrom(categoryTrigger) { (page: $0, category: $1) }
      .do(onNext: { [weak self] pair in
        print("Request grab orders for page \(pair.page) of category \(pair.category).")
        self?.resetPage.accept(false)
      })
      .flatMapLatest { pair in
        return api.queryOrders(withCategory:pair.category, page: pair.page, size: Order.numberOfOrdersPerPage)
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
    
    // Refresh
    
    let refreshTrigger = Signal.merge(loadTrigger.filter { !$0 }.withLatestFrom(categoryTrigger.startWith(0)), categoryTrigger)
    
    refreshTrigger.flatMapLatest { category in
      return api.queryOrders(withCategory: category, page: 1, size: Order.numberOfOrdersPerPage)
        .trackActivity(refreshActivityIndicator)
        .do(onNext: { [weak self] pairs in
          print("Request grab orders for page 1 of category \(category).")
          self?.hasMore.accept(pairs.hasMore)
          self?.resetPage.accept(true)
        })
        .map { pairs in
          pairs.orders.map { order in OrderCellModel(model: order) }
        }
        .asDriver(onErrorJustReturn: [])
      }
      .drive(cellModels)
      .disposed(by: bag)
  }
}
