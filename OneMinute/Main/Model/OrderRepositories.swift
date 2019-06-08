//
//  OrderRepositories.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

struct OrderRepositoriesState {
  var searchURL: String
  var hasMore = true
  var orders = [Order]()
  var currentPage: Int = 0
  
  init(searchURL: String) {
    self.searchURL = searchURL
  }
}


