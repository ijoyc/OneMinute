//
//  Result.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/15.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import Foundation

struct Result: Equatable {
  let success: Bool
  let message: String
  
  static let empty = Result(success: false, message: Config.localizedText(for: "error_network").value)
  
  init(success: Bool, message: String) {
    self.success = success
    self.message = message
  }
  
  init(json: [String: Any]) {
    self.success = json["data"] as? Bool ?? false
    self.message = json["message"] as? String ?? ""
  }
  
  static func == (lhs: Result, rhs: Result) -> Bool {
    return lhs.success == rhs.success && lhs.message == rhs.message
  }
}
