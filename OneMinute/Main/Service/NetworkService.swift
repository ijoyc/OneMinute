//
//  NetworkService.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/14.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

protocol NetworkService {
  func get(_ address: Config.Address, parameters: [String: String]?) -> Observable<[String: Any]>
  func post(_ address: Config.Address, parameters: [String: String]?) -> Observable<[String: Any]>
}
