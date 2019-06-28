//
//  Config.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import Foundation

enum Language : Int {
  case Chinese = 1, English
}

struct Config {
  private static let languageKey = "language"
  
  static var language: Language {
    get {
      return Language(rawValue: UserDefaults.standard.integer(forKey: Config.languageKey)) ?? .Chinese
    }
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: Config.languageKey)
      UserDefaults.standard.synchronize()
    }
  }
  
  private static var _storage: StorageService?
  static var storage: StorageService? {
    get {
      return _storage
    }
    set {
      _storage = newValue
    }
  }
  
  static func localizedText(for key: String) -> String {
    let lan = language == .Chinese ? "zh-Hans" : "en"
    let path = Bundle.main.path(forResource: lan, ofType: "lproj")!
    return Bundle(path: path)?.localizedString(forKey: key, value: nil, table: nil) ?? key
  }
  
  enum Address: String {
    case signin = "driver/login"
    case userInfo = "driver/getDriverInfo"
    case orders = "order/findOrderInfoPage"
    case orderDetail = "order/driver/findOrder"
    case grabOrder = "driver/catchOrder"
    case changeOrderState = "order/updateOrderStatus"
    case finishOrder = "order/completeOrder"
    case records = "driver/findIncome"
    case withdraw = "driver/withdraw"
    
    private var baseURL: String { return "http://47.252.8.20:8080/api/" }
    var url: String {
      return baseURL.appending(rawValue)
    }
  }
}
