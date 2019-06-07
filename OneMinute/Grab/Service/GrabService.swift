//
//  GrabService.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

protocol GrabAPI {
  func queryGrabOrders() -> Observable<[Order]>
}
