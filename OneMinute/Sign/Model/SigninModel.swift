//
//  SigninModel.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/5.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import Foundation

enum ValidationResult {
  case ok
  case empty
  case failed(message: String)
  
  var isValid: Bool {
    switch self {
    case .ok:
      return true
    default:
      return false
    }
  }
}

struct LoginResult {
  var result: ValidationResult
  var isUsername: Bool
  var token = ""
  
  init(result: ValidationResult, isUsername: Bool) {
    self.result = result
    self.isUsername = isUsername
  }
  
  static var empty: LoginResult {
    return LoginResult(result: .empty, isUsername: true)
  }
}

extension ValidationResult : CustomStringConvertible {
  var description: String {
    switch self {
    case .ok, .empty:
      return ""
    case let .failed(message):
      return message
    }
  }
}
