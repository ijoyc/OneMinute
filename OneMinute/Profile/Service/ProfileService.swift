//
//  ProfileService.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

protocol ProfileAPI {
  func queryUserInfo(token: String, driverToken: String) -> Observable<User>
}
