//
//  SigninViewModel.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/5.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

class SigninViewModel {
  // MARK: - Output
  
  let signedIn: Driver<LoginResult>
  let signingIn: Driver<Bool>
  let signinEnabled: Driver<Bool>
  
  let inputUsername: Driver<ValidationResult>
  let inputPassword: Driver<ValidationResult>
  
  init(input: (username: Driver<String>, password: Driver<String>, validatedUsername: Driver<ValidationResult>, validatedPassword: Driver<ValidationResult>, loginTaps: Signal<Void>), dependency: (api: SigninAPI, validation: validationService)) {
    let api = dependency.api
    let validation = dependency.validation
    
    inputUsername = input.username.map { username in
      return validation.validateUsername(username)
    }
    
    inputPassword = input.password.map { password in
      return validation.validatePassword(password)
    }
    
    let signingIn = ActivityIndicator()
    self.signingIn = signingIn.asDriver()
    
    let usernameAndPassword = Driver.combineLatest(input.username, input.password) { (username: $0, password: $1) }
    signedIn = input.loginTaps.withLatestFrom(usernameAndPassword)
      .flatMapLatest { pair in
        return api.signin(withUsername: pair.username, password: pair.password)
          .trackActivity(signingIn)
          .asDriver(onErrorJustReturn: LoginResult.empty)
      }
    
    signinEnabled = Driver.combineLatest(inputUsername, inputPassword, input.validatedUsername, input.validatedPassword, signingIn) { username, password, validatedUsername, validatedPassword, signingIn in
      username.isValid && password.isValid && validatedUsername.isValid && validatedPassword.isValid && !signingIn
    }.distinctUntilChanged()
  }
}
