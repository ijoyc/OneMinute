//
//  StorageService.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/13.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import Foundation

protocol StorageService {
  func setValue(_ value: String, for key: String) throws
  func value(for key: String) throws -> String?
  func removeValue(for key: String) throws
  func removeAllValues() throws
}
