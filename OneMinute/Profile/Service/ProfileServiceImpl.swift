//
//  ProfileServiceImpl.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift

class ProfileAPIImplementation : ProfileAPI {
  
  static let shared = ProfileAPIImplementation()
  
  func queryUserInfo() -> Observable<User> {
    return OneMinuteAPI.get(.userInfo, parameters: nil)
      .map { User(json: $0["data"] as? [String: Any] ?? [:]) }
  }
  
  func queryRecords(withPage page: Int, size: Int) -> Observable<(records: [Record], hasMore: Bool)> {
    return OneMinuteAPI.get(.records, parameters: ["pageNum": page, "pageSize": size]).map { json in
      var hasMore = true
      guard let data = json["data"] as? [String: Any] else {
        return (records: [], hasMore: hasMore)
      }
      
      guard let list = data["list"] as? [[String: Any]], list.count > 0 else {
        return (records: [], hasMore: hasMore)
      }
      
      let records = list.map { Record(json: $0) }
      
      if let pages = data["pages"] as? Int, page >= pages {
        hasMore = false
      }
      
      return (records: records, hasMore: hasMore)
    }
  }
}
