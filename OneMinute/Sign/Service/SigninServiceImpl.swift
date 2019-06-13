//
//  SigninServiceImpl.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/5.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

class SigninServiceImplementation : SigninAPI {
  
  static let shared = SigninServiceImplementation(session: URLSession.shared)
  
  let session: URLSession
  
  init(session: URLSession) {
    self.session = session
  }
  
  func signin(withUsername username: String, password: String) -> Observable<LoginResult> {
    // just for mock
    let signinResult = arc4random() % 5;
    var result = LoginResult(result: .empty, isUsername: true)
    switch signinResult {
    case 1:
      result.result = .failed(message: "账号不正确")
    case 2:
      result.result = .failed(message: "账号已被禁用")
    case 3:
      result.result = .failed(message: "密码不正确")
      result.isUsername = false
    default:
      result.result = .ok
    }
    
    return Observable.just(result).delay(.seconds(1), scheduler: MainScheduler.instance)
  }
  
  func signout() -> Observable<Bool> {
    return Observable.just(true).delay(.seconds(1), scheduler: MainScheduler.instance)
  }
}

class ValidationServiceImplementation : validationService {
  static let shared = ValidationServiceImplementation()
  
  func validateUsername(_ username: String) -> ValidationResult {
    if username.count == 0 {
      return .empty
    }
    return .ok
  }
  
  func validatePassword(_ password: String) -> ValidationResult {
    if password.count == 0 {
      return .empty
    }
    return .ok
  }
}
