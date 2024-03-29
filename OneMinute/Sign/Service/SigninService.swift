//
//  SigninService.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/5.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

protocol SigninAPI {
  func signin(withUsername username: String, password: String) -> Observable<LoginResult>
  func signup(with signupInfo: SignupInfo) -> Observable<(result: Result, token: String)>
  func signout() -> Observable<Bool>
}

protocol validationService {
  func validateUsername(_ username: String) -> ValidationResult
  func validatePassword(_ password: String) -> ValidationResult
}
