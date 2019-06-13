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
  let loading: Driver<Bool>
  let signedOut: Driver<Bool>
  
  init(signoutTap: Signal<Void>, dependency: (profileAPI: ProfileAPI, signinAPI: SigninAPI)) {
    let profileAPI = dependency.profileAPI
    let signinAPI = dependency.signinAPI
    
    let loadingUserInfo = ActivityIndicator()
    let signingOut = ActivityIndicator()
    loading = Driver.merge(loadingUserInfo.asDriver(), signingOut.asDriver())
    
    currentUser = profileAPI.queryUserInfo().trackActivity(loadingUserInfo).asDriver(onErrorJustReturn: User.current.value)
    
    signedOut = signoutTap.flatMapLatest { _ in
      signinAPI.signout().trackActivity(signingOut).asDriver(onErrorJustReturn: false)
    }
  }
}
