//
//  NetworkServiceImpl.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/14.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import Alamofire
import RxAlamofire

class NetworkServiceImpl : NetworkService {
  static let shared = NetworkServiceImpl()
  
  private static let tokenKey = "tokenDriver"
  
  private init() {}
  
  func get(_ address: Config.Address, parameters: [String : Any]?) -> Observable<[String : Any]> {
    var headers: [String: String] = [:]
    if let token = User.signInfo.token, token.count > 0 {
      headers[NetworkServiceImpl.tokenKey] = token
    }
    
    return json(.get, address.url, parameters: parameters, encoding: JSONEncoding.default, headers: headers).map {
      return $0 as? [String: Any] ?? [:]
    }
  }
  
  func post(_ address: Config.Address, parameters: [String : Any]?) -> Observable<[String : Any]> {
    var headers: [String: String] = [:]
    if let token = User.signInfo.token, token.count > 0 {
      headers[NetworkServiceImpl.tokenKey] = token
    }
    
    return json(.post, address.url, parameters: parameters, encoding: JSONEncoding.default, headers: headers).map {
      return $0 as? [String: Any] ?? [:]
    }
  }
}
