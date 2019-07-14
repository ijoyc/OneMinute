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
        result.result = .failed(message: Config.localizedText(for: "error_invalid_username").value)
      case "60012":
        result.result = .failed(message: Config.localizedText(for: "error_invalid_password").value)
        result.isUsername = false
      case "60013":
        result.result = .failed(message: Config.localizedText(for: "error_banned_user").value)
      case "200":
        result.result = .ok
        if let token = json["data"] as? String {
          result.token = token
        }
      default:
        result.result = .failed(message: Config.localizedText(for: "error_network").value)
      }
      
      return result
    }
  }
  
  func signup(with signupInfo: SignupInfo) -> Observable<(result: Result, token: String)> {
    return OneMinuteAPI.post(.signup, parameters: ["phone": signupInfo.phone, "password": signupInfo.password, "cardNo": signupInfo.cardNo, "firstname": signupInfo.firstName, "lastname": signupInfo.lastName, "sex": 0, "type": 0]).map { json in
      let code = json["code"] as? String ?? ""
      return (result: Result(success: code == "200", message: json["message"] as? String ?? ""), token: json["data"] as? String ?? "")
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
