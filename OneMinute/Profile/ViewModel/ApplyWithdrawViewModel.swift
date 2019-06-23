//
//  ApplyWithdrawViewModel.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/22.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

class ApplyWithdrawViewModel {
  var loading: Driver<Bool>
  var message = BehaviorRelay<String>(value: "")
  var success = BehaviorRelay<Bool>(value: false)
  
  private let bag = DisposeBag()
  
  init(input: (amount: Driver<Double>, account: Driver<String>, accountType: Driver<WithdrawAccount>, withdrawTrigger: Signal<Void>), api: ProfileAPI) {
    let activityIndicator = ActivityIndicator()
    loading = activityIndicator.asDriver()
    
    let amount = input.amount
    let account = input.account
    let accountType = input.accountType
    let withdrawTrigger = input.withdrawTrigger
    
    let parameters = Driver.combineLatest(amount, account, accountType) {
      (amount: $0, account: $1, accountType: $2)
    }
    let withdraw = withdrawTrigger.withLatestFrom(parameters).flatMapLatest { pair in
      return api.withdraw(with: pair.amount,
                          account: pair.account,
                          accountType: pair.accountType)
        .trackActivity(activityIndicator)
        .asDriver(onErrorJustReturn: .empty)
    }
    
    withdraw.map { $0.message }.drive(message).disposed(by: bag)
    withdraw.map { $0.success }.drive(success).disposed(by: bag)
  }
}
