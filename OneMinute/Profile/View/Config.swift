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
}
