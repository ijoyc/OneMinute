//
//  ProfileViewModel.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

class ProfileViewModel {
  // - Output
  
  let currentUser: Driver<User>
  
  init(api: ProfileAPI) {
    currentUser = api.queryUserInfo().asDriver(onErrorJustReturn: User.current.value)
  }
}
