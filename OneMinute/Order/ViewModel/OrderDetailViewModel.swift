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
  let errorMessage = BehaviorRelay<String>(value: "")
  
  let bag = DisposeBag()
  
  init(input: (orderID: Int,
               changeStateSignal: Signal<OrderState>,
               finishSignal: Signal<String>),
       api: OrderAPI) {
    let orderID = input.orderID
    let changeStateSignal = input.changeStateSignal
    let finishSignal = input.finishSignal
    
    let activityIndicator = ActivityIndicator()
    changingOrderState = activityIndicator.asDriver()
    
    queryResult = api.queryOrderDetail(with: orderID).asDriver(onErrorJustReturn: (orderDetail: nil, result: Result.empty))
    queryResult = queryResult.do(onNext: { [weak self] pair in
      guard let self = self, let orderDetail = pair.orderDetail else { return }
      
      self.operationText.accept(orderDetail.currentOperationTitle)
      self.stateText.accept(orderDetail.state.description)
      self.orderState.accept(orderDetail.state)
    })
    
    changeStateSignal.flatMapLatest { state in
      return api.changeOrderState(with: orderID, state: state.rawValue).trackActivity(activityIndicator).asDriver(onErrorJustReturn: .empty).do(onNext: { result in
        guard result.success else { return }
        
        self.orderState.accept(state)
        
        switch state {
        case .doing:
          self.operationText.accept(OrderState.reached.description)
          self.stateText.accept(OrderState.doing.description)
          break
        case .finished:
          self.operationText.accept(OrderState.finished.description)
          self.stateText.accept(OrderState.finished.description)
          break
        default:
          break
        }
        
      })
    }.drive(onNext: { self.errorMessage.accept($0.message) }).disposed(by: bag)
    
    finishSignal.flatMapLatest { code in
      return api.finishOrder(with: orderID, code: code).trackActivity(activityIndicator).asDriver(onErrorJustReturn: .empty)
    }.drive(onNext: { self.errorMessage.accept($0.message) }).disposed(by: bag)
  }
}
