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
  
  static func get(_ address: Config.Address, parameters: [String: String]?) -> Observable<[String: Any]> {
    print("[OneMinuteAPI] GET \(address.url) with parameters \(parameters ?? [:])")
    return networkService?.get(address, parameters: parameters).debug() ?? .empty()
  }
  
  static func post(_ address: Config.Address, parameters: [String: String]?) -> Observable<[String: Any]> {
    print("[OneMinuteAPI] POST \(address.url) with parameters \(parameters ?? [:])")
    return networkService?.post(address, parameters: parameters).debug() ?? .empty()
  }
}
