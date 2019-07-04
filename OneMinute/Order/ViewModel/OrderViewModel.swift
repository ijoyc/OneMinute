//
//  OrderViewModel.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/8.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

struct OrderCache {
  var hasMore = true
  var models: [OrderCellModel] = []
}

class OrderViewModel {
  // - Output
  let cellModels = BehaviorRelay<[OrderCellModel]>(value: [])
  let hasMore = BehaviorRelay<Bool>(value: true)
  // for load more
  let loading: Driver<Bool>
  // for refreshing or change category
  let refreshing: Driver<Bool>
  let errorMessage = PublishSubject<String>()
  
  private let resetPage = BehaviorRelay<Bool>(value: false)
  private var orderCache: [Int: OrderCache] = [:]
  
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
      .withLatestFrom(cellModels.asDriver())
      .filter { $0.count > 0 }
      .withLatestFrom(loadNextPage)
      .filter { $0 }
      // After refreshing, the next page should be the second one.
      .scan(0) { [weak self] (page, _) in (self?.resetPage.value ?? true) ? 2 : page + 1 }
      .withLatestFrom(categoryTrigger) { (page: $0, category: $1) }
      .filter { [weak self] pairs in
        guard let self = self else { return false }
        return self.orderCache[pairs.category]?.hasMore ?? true
      }
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
          .map { [weak self] pairs -> (models: [OrderCellModel], category: Int, hasMore: Bool) in
            guard let `self` = self else { return (models: [], category: pair.category, hasMore: true) }
            return (models: self.cellModels.value + pairs.orders.map { order in OrderCellModel(model: order) }, category: pair.category, hasMore: pairs.hasMore)
          }
          .do(onNext: { [weak self] pairs in
            self?.cacheOrders(pairs.models, with: pairs.category, hasMore: pairs.hasMore)
          }, onError: { [weak self] _ in
            self?.errorMessage.onNext(Config.localizedText(for: "error_network").value)
          })
          .map { $0.models }
          .asDriver(onErrorJustReturn: self.cellModels.value)
      }
      .drive(cellModels)
      .disposed(by: bag)
    
    // Refresh
    
    let refreshTrigger = Signal.merge(
      loadTrigger
        .filter { !$0 }
        .withLatestFrom(categoryTrigger.startWith(0)),
      categoryTrigger.do(onNext: { [weak self] category in
        guard let self = self,
          let cache = self.orderCache[category],
          cache.models.count > 0 else { return }
        self.cellModels.accept(cache.models)
      }).filter { [weak self] category in
        (self?.orderCache[category]?.models.count ?? 0) == 0
      }
    )
    
    refreshTrigger.flatMapLatest { category in
      return api.queryOrders(withCategory: category, page: 1, size: Order.numberOfOrdersPerPage)
        .trackActivity(refreshActivityIndicator)
        .do(onNext: { [weak self] pairs in
          print("Request grab orders for page 1 of category \(category).")
          self?.hasMore.accept(pairs.hasMore)
          self?.resetPage.accept(true)
        })
        .map { pairs in
          (models: pairs.orders.map { order in OrderCellModel(model: order) }, hasMore: pairs.hasMore)
        }
        .do(onNext: { [weak self] pairs in
          self?.cacheOrders(pairs.models, with: category, hasMore: pairs.hasMore, isAppend: false)
        }, onError: { [weak self] _ in
          self?.errorMessage.onNext(Config.localizedText(for: "error_network").value)
        })
        .map { $0.models }
        .asDriver(onErrorJustReturn: self.cellModels.value)
      }
      .drive(cellModels)
      .disposed(by: bag)
  }
  
  private func cacheOrders(_ orders: [OrderCellModel], with category: Int, hasMore: Bool, isAppend: Bool = true) {
    var current = orderCache[category]
    if let count = current?.models.count, count > 0 && isAppend {
      current!.models.append(contentsOf: orders)
      current!.hasMore = hasMore
    } else {
      orderCache[category] = OrderCache(hasMore: hasMore, models: orders)
    }
  }
}
