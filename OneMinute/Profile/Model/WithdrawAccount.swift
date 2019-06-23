//
//  WithdrawAccount.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/22.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import Foundation

enum WithdrawAccount: Int, CaseIterable, CustomStringConvertible {
  case paypal = 0
  case scotiabank
  case td
  case bmo
  case royal
  case imperial
  
  var description: String {
    switch self {
    case .paypal:
      return "Paypal"
    case .scotiabank:
      return "Scotiabank"
    case .td:
      return "TD bank"
    case .bmo:
      return "BMO Bank of Montreal"
    case .royal:
      return "Royal Bank of Canada"
    case .imperial:
      return "Canadian Imperial Bank of Commerce"
    }
  }
}
