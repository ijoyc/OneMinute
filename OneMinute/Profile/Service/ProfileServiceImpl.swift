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
    return Observable.just(User(json: [
      "avatarUrl": "https://wx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJOd6bIE19NzmGnBzL6dl6aicsye2e74C0sjQCmFbqgdZbfezRdAYQXbBS17Pjm4ibXpZWwzRoQowibg/132",
      "completeOrderNum": 12,
      "firstname": "三",
      "lastname": "张",
      "sex": 1,
      "dailyProfit": 8125.29,
      "withdraw": 105.29
      ])).delay(.seconds(1), scheduler: MainScheduler.instance)
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
