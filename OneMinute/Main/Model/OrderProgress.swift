//
//  OrderProgress.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

public enum ProgressType : Int {
  case buy = 1
  case receive
  case get
  case take
  case send
  
  static func create(with orderType: OrderType, index: Int) -> ProgressType {
    switch orderType {
    case .buy:
      return index == 0 ? .buy : .receive
    case .take:
      return index == 0 ? .receive : .get
    case .send:
      return index == 0 ? .get : .receive
    case .transfer:
      return index == 0 ? .take : .send
    default:
      return .receive
    }
  }
}

struct OrderProgress {
  let title: String
  let desc: String
  let contactName: String
  let contactPhone: String
  let latitude: Double
  let longitude: Double
  
  init(title: String, desc: String) {
    self.title = title
    self.desc = desc
    self.contactPhone = ""
    self.contactName = ""
    self.latitude = 0
    self.longitude = 0
  }
  
  init(json: [String: Any]) {
    self.title = json["addressReceive"] as? String ?? ""
    self.desc = json["addressReceiveDetail"] as? String ?? ""
    self.contactName = json["contactName"] as? String ?? ""
    self.contactPhone = json["contactPhone"] as? String ?? ""
    self.latitude = Double(exactly: (json["latReceive"] as? NSNumber ?? 0)) ?? 0
    self.longitude = Double(exactly: (json["lngReceive"] as? NSNumber ?? 0)) ?? 0
  }
  
  // To fit the poor field design of server...
  // The first progress is out of `addressReceiveList` array in `OrderDetail`
  // so we need to handle it first.
  init(orderJson json: [String: Any]) {
    self.title = json["addressNameGet"] as? String ?? ""
    self.desc = json["addressDetailGet"] as? String ?? ""
    self.contactName = json["contactName"] as? String ?? ""
    self.contactPhone = json["contactPhone"] as? String ?? ""
    self.latitude = Double(exactly: (json["latGet"] as? NSNumber ?? 0)) ?? 0
    self.longitude = Double(exactly: (json["lngGet"] as? NSNumber ?? 0)) ?? 0
  }
  
  var location: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}
