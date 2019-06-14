//
//  ProfileServiceImpl.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

class ProfileAPIImplementation : ProfileAPI {
  
  static let shared = ProfileAPIImplementation()
  
  func queryUserInfo() -> Observable<User> {
    return OneMinuteAPI.get(.userInfo, parameters: nil)
      .map { User(json: $0["data"] as? [String: Any] ?? [:]) }
  }
  
  func queryRecords(withPage page: Int, size: Int) -> Observable<(records: [Record], hasMore: Bool)> {
    return Observable.just((records: [
      Record(json: [
        "amount": 8,
        "createTime": "05.21 15:38",
        "orderNo": "A20190415293841",
        "orderType": 1
        ]),
      Record(json: [
        "amount": 18.74,
        "createTime": "05.21 15:38",
        "orderNo": "A20190415293841",
        "orderType": 2
        ]),
      Record(json: [
        "amount": 24.95,
        "createTime": "05.21 15:38",
        "orderNo": "A20190415293841",
        "orderType": 3
        ]),
      Record(json: [
        "amount": 56,
        "createTime": "05.21 15:38",
        "orderNo": "A20190415293841",
        "orderType": 4
        ]),
      Record(json: [
        "amount": 8.97,
        "createTime": "05.21 15:38",
        "orderNo": "A20190415293841",
        "orderType": 5,
        "remark": "现金收款扣除"
        ]),
      Record(json: [
        "amount": 2000,
        "createTime": "05.21 15:38",
        "orderNo": "A20190415293841",
        "orderType": 6,
        ])
      ], hasMore: true)).delay(.seconds(1), scheduler: MainScheduler.instance)
  }
}
