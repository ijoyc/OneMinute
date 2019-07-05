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
  
  var queryResult: Driver<(orderDetail: OrderDetail?, result: Result)>
  let operationText = BehaviorRelay<String>(value: "")
  let stateText = BehaviorRelay<String>(value: "")
  let orderState = BehaviorRelay<OrderState>(value: .paying)
  let changingOrderState: Driver<Bool>
  let finishingOrder: Driver<Bool>
  let result = BehaviorRelay<Result>(value: .empty)
  
  private let orderDetail = BehaviorRelay<OrderDetail?>(value: nil)
  private let bag = DisposeBag()
  
  init(input: (orderID: Int,
               changeStateSignal: Signal<OrderState>,
               finishSignal: Signal<String>),
       api: OrderAPI) {
    let orderID = input.orderID
    let changeStateSignal = input.changeStateSignal
    let finishSignal = input.finishSignal
    
    let activityIndicator = ActivityIndicator()
    changingOrderState = activityIndicator.asDriver()
    
    let finishingIndicator = ActivityIndicator()
    finishingOrder = finishingIndicator.asDriver()
    
    queryResult = api.queryOrderDetail(with: orderID).asDriver(onErrorJustReturn: (orderDetail: nil, result: Result.empty))
    queryResult = queryResult.do(onNext: { [weak self] pair in
      guard let self = self, let orderDetail = pair.orderDetail else { return }
      
      orderDetail.currentOperationTitle.bind(to: self.operationText).disposed(by: self.bag)
      orderDetail.state.localizedText.bind(to: self.stateText).disposed(by: self.bag)
      self.orderState.accept(orderDetail.state)
    })
    queryResult.map { $0.orderDetail }.drive(orderDetail).disposed(by: bag)
    
    changeStateSignal.flatMapLatest { [weak self] state in
      guard let self = self else { return Driver.just(.empty) }
      
      return api.changeOrderState(with: orderID, state: state.rawValue).trackActivity(activityIndicator).asDriver(onErrorJustReturn: .empty).do(onNext: { result in
        guard result.success else { return }
        
        self.orderState.accept(state)
        
        // finish order is another api...
        switch state {
        case .doing:
          self.operationText.accept(OrderState.reached.localizedText.value)
          self.stateText.accept(OrderState.doing.localizedText.value)
          break
        default:
          break
        }
        
      })
    }.drive(result).disposed(by: bag)
    
    finishSignal.flatMapLatest { code in
      return api.finishOrder(with: orderID, code: code).trackActivity(finishingIndicator).asDriver(onErrorJustReturn: .empty)
    }.drive(onNext: { [weak self] in
      guard let self = self else { return }
      
      if $0.success {
        var state = OrderState.finished
        if let type = self.orderDetail.value?.type, case .buy = type {
          state = .reached
        }
        self.operationText.accept(state.localizedText.value)
        self.stateText.accept(state.localizedText.value)
        self.orderState.accept(state)
      } else {
        // There will be a custom toast when success
        self.result.accept($0)
      }
    }).disposed(by: bag)
  }
}
