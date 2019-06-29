//
//  SettingItem.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

struct SettingItem {
  let iconName: String
  let title: BehaviorRelay<String>
}
