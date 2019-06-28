//
//  SigninServiceImpl.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/5.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

class SigninServiceImplementation : SigninAPI {
  
  static let shared = SigninServiceImplementation()
  
  private init() {}
  
  func signin(withUsername username: String, password: String) -> Observable<LoginResult> {
    
    return OneMinuteAPI.post(.signin, parameters: ["phone": username, "password": password]).map { json in
      var result = LoginResult(result: .empty, isUsername: true)
      
      let code = json["code"] as? String ?? ""
      switch code {
      case "60011":
        result.result = .failed(message: Config.localizedText(for: "error_invalid_username"))
      case "60012":
        result.result = .failed(message: Config.localizedText(for: "error_invalid_password"))
        result.isUsername = false
      case "60013":
        result.result = .failed(message: Config.localizedText(for: "error_banned_user"))
      case "200":
        result.result = .ok
        if let token = json["data"] as? String {
          result.token = token
        }
      default:
        result.result = .failed(message: Config.localizedText(for: "error_network"))
      }
      
      return result
    }
  }
  
  func signout() -> Observable<Bool> {
    return Observable.just(true)
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
