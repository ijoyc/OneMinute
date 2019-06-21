//
//  LBSService.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/21.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import CoreLocation

protocol LBSService {
  func start()
  func stop()
  var currentLocation: CLLocation? { get }
}
