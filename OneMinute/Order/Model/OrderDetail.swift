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
  var state: OrderState
  let progresses: [OrderProgress]
  let progress: Int
  let orderID: Int
  let orderNo: String
  let note: String
  let startPoint: Point
  
  public class Point : NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    
    override init() {
      self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    init(_ progress: OrderProgress?) {
      self.coordinate = CLLocationCoordinate2D(latitude: progress?.latitude ?? 0, longitude: progress?.longitude ?? 0)
    }
  }
  
  init(json: [String: Any]) {
    self.type = OrderType(rawValue: (json["orderType"] as? Int) ?? 1) ?? .buy
    self.state = OrderState(rawValue: (json["orderFlag"] as? Int ?? 0)) ?? .doing

    var progresses = [OrderProgress]()
    // add start point, see the comment of `init(orderJson:)` in `OrderProgress`
    let startPoint = OrderProgress(orderJson: json)
    progresses.append(startPoint)
    
    for progress in (json["addressReceiveList"] as? [[String: Any]] ?? []) {
      progresses.append(OrderProgress(json: progress))
    }
    self.progresses = progresses
    self.progress = 1
    
    self.orderID = json["id"] as? Int ?? 0
    self.orderNo = json["orderNo"] as? String ?? ""
    self.note = json["remark"] as? String ?? ""
    
    self.startPoint = Point(self.progresses.first)
  }
  
  var currentReceiverTelephone: String {
    guard progress < progresses.count else { return "" }
    return progresses[progress].contactPhone
  }
  
  var currentReceiverPoint: Point {
    guard progress < progresses.count else { return Point() }
    return Point(progresses[progress])
  }
  
  var currentOperationTitle: String {
    if case .grabed = state {
      switch type {
      case .buy:
        return "已买到商品"
      case .take, .send:
        return "已到达取货地"
      case .transfer:
        return "已到达出发地"
      default:
        break
      }
    } else if case .doing = state {
      return "已到达目的地"
    }
    
    return state.description
  }
  
  var shouldOpenCodePanel: Bool {
    if case .doing = state {
      switch type {
      case .buy, .take, .send:
        return true
      default:
        break
      }
    }
    
    return false
  }
}
