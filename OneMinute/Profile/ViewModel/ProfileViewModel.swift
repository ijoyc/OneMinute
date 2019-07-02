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
  private let loadingUserInfo = ActivityIndicator()
  private var profileAPI: ProfileAPI?
  
  private let bag = DisposeBag()
  
  // - Output
  
  let currentUser = BehaviorRelay<User?>(value: nil)
  let loading: Driver<Bool>
  let signedOut: Driver<Bool>
  
  init(signoutTap: Signal<Void>, dependency: (profileAPI: ProfileAPI, signinAPI: SigninAPI)) {
    profileAPI = dependency.profileAPI
    let signinAPI = dependency.signinAPI
    
    let signingOut = ActivityIndicator()
    loading = Driver.merge(loadingUserInfo.asDriver(), signingOut.asDriver())
    
    signedOut = signoutTap.flatMapLatest { _ in
      signinAPI.signout().trackActivity(signingOut).asDriver(onErrorJustReturn: false)
    }
  }
  
  func updateUserInfo() {
    guard let profileAPI = self.profileAPI else { return }
    
    profileAPI.queryUserInfo().trackActivity(loadingUserInfo).asDriver(onErrorJustReturn: User.current.value).drive(currentUser).disposed(by: bag)
  }
}
