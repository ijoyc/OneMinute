//
//  OneMinuteAPI.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/14.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

struct OneMinuteAPI {
  static var networkService: NetworkService?
  
  static let notSigninNotification = Notification.Name(rawValue: "notSigninNotification")
  
  private static let notSignin = "60014"
  
  static func get(_ address: Config.Address, parameters: [String: Any]?) -> Observable<[String: Any]> {
    print("[OneMinuteAPI] GET \(address.url) with parameters \(parameters ?? [:])")
    return networkService?.get(address, parameters: parameters).debug().do(onNext: { json in
      let code = (json["code"] as? String ?? "")
      if code == notSignin {
        NotificationCenter.default.post(name: notSigninNotification, object: nil)
      }
    }) ?? .empty()
  }
  
  static func post(_ address: Config.Address, parameters: [String: Any]?) -> Observable<[String: Any]> {
    print("[OneMinuteAPI] POST \(address.url) with parameters \(parameters ?? [:])")
    return networkService?.post(address, parameters: parameters).debug().do(onNext: { json in
      let code = (json["code"] as? String ?? "")
      if code == notSignin {
        NotificationCenter.default.post(name: notSigninNotification, object: nil)
      }
    }) ?? .empty()
  }
}
