//
//  RecordsViewModel.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/13.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

class RecordsViewModel {
  // - Output
  
  let records = BehaviorRelay<[Record]>(value: [])
  let hasMore = BehaviorRelay<Bool>(value: true)
  // for load more
  let loading: Driver<Bool>
  
  private let bag = DisposeBag()
  
  init(loadTrigger: Signal<Void>, api: ProfileAPI) {
    let activityIndicator = ActivityIndicator()
    loading = activityIndicator.asDriver()
    
    // Load More
    
    let loadNextPage = Driver.combineLatest(loading, hasMore.asDriver()) { !$0 && $1 }
    
    loadTrigger
      .withLatestFrom(loadNextPage)
      .filter { $0 }
      // After refreshing, the next page should be the second one.
      .scan(0) { (page, _) in page + 1 }
      .do(onNext: { page in
        print("Request records for page \(page).")
      })
      .flatMapLatest { page in
        return api.queryRecords(withPage: page, size: Record.numberOfRecordsPerPage)
          .trackActivity(activityIndicator)
          .do(onNext: { [weak self] pairs in
            self?.hasMore.accept(pairs.hasMore)
          })
          .map { [weak self] pairs in
            guard let self = self else { return [] }
            return self.records.value + pairs.records
          }
          .asDriver(onErrorJustReturn: [])
      }
      .drive(records)
      .disposed(by: bag)
    
  }
}
