//
//  User.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import Foundation

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
//  var type: UserType
  
  static let current = User(json: [String: Any]())
  
  init(json: [String: Any]) {
    avatar = json["avatarUrl"] as? String ?? ""
    completeOrderNum = json["completeOrderNum"] as? Int ?? 0
    firstName = json["firstname"] as? String ?? ""
    lastName = json["lastname"] as? String ?? ""
    sex = Sex(rawValue: json["sex"] as? Int ?? 1) ?? .Male
  }
  
  func update(_ user: User) {
    self.avatar = user.avatar
    self.completeOrderNum = user.completeOrderNum
    self.firstName = user.firstName
    self.lastName = user.lastName
    self.sex = user.sex
  }
}
