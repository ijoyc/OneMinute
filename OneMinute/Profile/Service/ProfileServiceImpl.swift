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
  
  func queryUserInfo(token: String, driverToken: String) -> Observable<User> {
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
}
