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
  let grabing: Driver<Bool>
  let grabResult: Driver<Result>
  
  private let resetPage = BehaviorRelay<Bool>(value: false)
  
  let bag = DisposeBag()
  
  // true: load more , false: refresh
  init(input: (loadTrigger: Signal<Bool>, grabTrigger: Signal<Int>), api: GrabAPI) {
    let loadTrigger = input.loadTrigger
    let grabTrigger = input.grabTrigger
    
    // Grab order
    
    let grabingIndicator = ActivityIndicator()
    grabing = grabingIndicator.asDriver()
    
    grabResult = grabTrigger.filter { $0 >= 0 }.do(onNext: { id in
      print("grab order \(id)")
    }).flatMapLatest { id in
      return api.grabOrder(with: id)
        .trackActivity(grabingIndicator)
        .asDriver(onErrorJustReturn: .empty)
    }
    
    // load orders
    
    let activityIndicator = ActivityIndicator()
    loading = activityIndicator.asDriver()
    
    let loadNextPage = Driver.combineLatest(loading, hasMore.asDriver()) { !$0 && $1 }
    
    loadTrigger.filter{ $0 }
      .withLatestFrom(cellModels.asDriver())
      .filter { $0.count > 0 }
      .withLatestFrom(loadNextPage)
      .filter{ $0 }
      // After refreshing, the next page should be the second one.
      .scan(0) { [weak self] (page, _) in (self?.resetPage.value ?? true) ? 2 : page + 1 }
      .do(onNext: { [weak self] page in
        print("Request grab orders for page \(page).")
        self?.resetPage.accept(false)
      })
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
    
    loadTrigger.filter { !$0 }.flatMapLatest { _ in
      return api.queryGrabOrders(withPage: 1, size: Order.numberOfOrdersPerPage)
        .do(onNext: { [weak self] pairs in
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
