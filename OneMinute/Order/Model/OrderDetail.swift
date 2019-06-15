//
//  OrderDetail.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/9.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class OrderDetail {
  let type: OrderType
  let state: OrderState
  let progresses: [OrderProgress]
  let progress: Int
  let orderID: String
  let note: String
  let telephone: String
  let start: CLLocationCoordinate2D
  let end: CLLocationCoordinate2D
  let startPoint: Point
  let endPoint: Point
  
  public class Point : NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    
    init(_ coordinate: CLLocationCoordinate2D) {
      self.coordinate = coordinate
    }
  }
  
  init(json: [String: Any]) {
    self.type = OrderType(rawValue: (json["type"] as? Int) ?? 1) ?? .buy
    self.state = OrderState(rawValue: (json["state"] as? Int ?? 0)) ?? .doing
    
//    var progresses = [OrderProgress]()
//    for progress in (json["progresses"] as? Array ?? []) {
//      guard let progress = progress as? [String: Any] else { continue }
//      progresses.append(OrderProgress(json: progress))
//    }
//    self.progresses = progresses
    self.progresses = []
    self.progress = json["progress"] as? Int ?? 1
    
    self.orderID = json["orderID"] as? String ?? ""
    self.note = json["note"] as? String ?? ""
    self.telephone = json["telephone"] as? String ?? ""
    self.start = CLLocationCoordinate2D(latitude: json["startLatitude"] as? CLLocationDegrees ?? 0, longitude: json["startLongitude"] as? CLLocationDegrees ?? 0)
    self.end = CLLocationCoordinate2D(latitude: json["endLatitude"] as? CLLocationDegrees ?? 0, longitude: json["endLongitude"] as? CLLocationDegrees ?? 0)
    
    self.startPoint = Point(self.start)
    self.endPoint = Point(self.end)
  }
}
