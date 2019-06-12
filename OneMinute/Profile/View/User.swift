//
//  User.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxCocoa

class User {
  enum Sex : Int {
    case Male = 1, Female
  }
  
//  enum UserType {
//
//  }
  
  var token = ""
  var driverToken = ""
  var avatar = ""
  var completeOrderNum = 0
  var firstName = ""
  var lastName = ""
  var sex: Sex = .Male
  var dailyProfit: Double = 0
  var withdraw: Double = 0
//  var type: UserType
  
  static let current = BehaviorRelay(value: User(json: [String: Any]()))
  
  init(json: [String: Any]) {
    avatar = json["avatarUrl"] as? String ?? ""
    completeOrderNum = json["completeOrderNum"] as? Int ?? 0
    firstName = json["firstname"] as? String ?? ""
    lastName = json["lastname"] as? String ?? ""
    sex = Sex(rawValue: json["sex"] as? Int ?? 1) ?? .Male
    dailyProfit = json["dailyProfit"] as? Double ?? 0
    withdraw = json["withdraw"] as? Double ?? 0
  }
  
  func update(_ user: User) {
    avatar = user.avatar
    completeOrderNum = user.completeOrderNum
    firstName = user.firstName
    lastName = user.lastName
    sex = user.sex
    dailyProfit = user.dailyProfit
    withdraw = user.withdraw
  }
}
