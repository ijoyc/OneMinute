//
//  SignupViewModel.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/7/14.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

class SignupViewModel {
  let signedUp: Driver<(result: Result, token: String)>
  let signingUp: Driver<Bool>
  let signupEnabled: Driver<Bool>
  
  let inputUsername: Driver<ValidationResult>
  let inputPassword: Driver<ValidationResult>
  let inputOther: Driver<ValidationResult>
  
  init(input: (username: Driver<String>, password: Driver<String>, firstName: Driver<String>, lastName: Driver<String>, cardNo: Driver<String>, signupTaps: Signal<Void>), dependency: (api: SigninAPI, validation: validationService)) {
    let api = dependency.api
    let validation = dependency.validation
    
    inputUsername = input.username.map { username in
      return validation.validateUsername(username)
    }
    
    inputPassword = input.password.map { password in
      return validation.validatePassword(password)
    }
    
    inputOther = Driver.combineLatest(input.firstName, input.lastName, input.cardNo).map { pair in
      if pair.0.count > 0 && pair.1.count > 0 && pair.2.count > 0 {
        return .ok
      }
      return .failed(message: "")
    }
    
    let signingUp = ActivityIndicator()
    self.signingUp = signingUp.asDriver()
    
    let infos = Driver.combineLatest(input.username, input.password, input.firstName, input.lastName, input.cardNo) { (username: $0, password: $1, firstName: $2, lastName: $3, cardNo: $4) }
    signedUp = input.signupTaps.withLatestFrom(infos)
      .flatMapLatest { pair in
        return api.signup(with: SignupInfo(cardNo: pair.cardNo, firstName: pair.firstName, lastName: pair.lastName, password: pair.password, phone: pair.username))
          .trackActivity(signingUp)
          .asDriver(onErrorJustReturn: (result: .empty, token: ""))
    }
    
    signupEnabled = Driver.combineLatest(inputUsername, inputPassword, inputOther, signingUp) { username, password, other, signingUp in
      username.isValid && password.isValid && other.isValid && !signingUp
      }.distinctUntilChanged()
  }
}
