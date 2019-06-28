//
//  User.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxCocoa

struct SignInfo {
  var token: String?
  
  static let tokenKey = "tokenKey"
  
  init() {
    do {
      guard let key = try Config.storage?.value(for: SignInfo.tokenKey) else {
        return
      }
      
      token = key
    } catch {
      print(error.localizedDescription)
    }
  }
  
  mutating func signin(withToken token: String) {
    self.token = token
    do {
      try Config.storage?.setValue(token, for: SignInfo.tokenKey)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  mutating func signout() {
    self.token = nil
    do {
      try Config.storage?.removeAllValues()
    } catch {
      print(error.localizedDescription)
    }
  }
}

class User {
  enum Sex : Int {
    case male, female
  }
  
  enum UserType : Int, CustomStringConvertible {
    case fulltime, parttime
    
    var description: String {
      switch self {
      case .fulltime: return Config.localizedText(for: "user_fulltime")
      case .parttime: return Config.localizedText(for: "user_parttime")
      }
    }
  }
  
  static var signInfo = SignInfo()
  
  var id = 0
  var avatar = ""
  var completeOrderNum = 0
  var firstName = ""
  var lastName = ""
  var sex: Sex = .male
  var dailyProfit: Double = 0
  var withdraw: Double = 0
  var type: UserType
  
  static let current = BehaviorRelay(value: User(json: [String: Any]()))
  
  init(json: [String: Any]) {
    id = json["driverId"] as? Int ?? 0
    avatar = json["avatarUrl"] as? String ?? ""
    completeOrderNum = json["completeOrderNum"] as? Int ?? 0
    firstName = json["firstname"] as? String ?? ""
    lastName = json["lastname"] as? String ?? ""
    sex = Sex(rawValue: json["sex"] as? Int ?? 0) ?? .male
    type = UserType(rawValue: json["type"] as? Int ?? 0) ?? .parttime
    dailyProfit = json["dailyProfit"] as? Double ?? 0
    withdraw = json["balance"] as? Double ?? 0
  }
  
  func update(_ user: User) {
    id = user.id
    avatar = user.avatar
    completeOrderNum = user.completeOrderNum
    firstName = user.firstName
    lastName = user.lastName
    sex = user.sex
    type = user.type
    dailyProfit = user.dailyProfit
    withdraw = user.withdraw
  }
  
}
