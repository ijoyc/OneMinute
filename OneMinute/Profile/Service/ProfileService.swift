//
//  ProfileService.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

protocol ProfileAPI {
  func queryUserInfo() -> Observable<User>
  func queryRecords(withPage page: Int, size: Int) -> Observable<(records: [Record], hasMore: Bool)>
  func withdraw(with amount: Double, account: String, accountType: WithdrawAccount) -> Observable<Result>
}
