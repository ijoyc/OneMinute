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
import RxSwift
import RxCocoa

class OrderDetail {
  let type: OrderType
  var state: OrderState
  let progresses: [OrderProgress]
  let orderID: Int
  let orderNo: String
  let note: String
  let startPoint: Point
  
  public class Point : NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    public var isDriver = false
    
    override init() {
      self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    init(_ progress: OrderProgress?) {
      self.coordinate = CLLocationCoordinate2D(latitude: progress?.latitude ?? 0, longitude: progress?.longitude ?? 0)
    }
    
    init(_ coordinate: CLLocationCoordinate2D) {
      self.coordinate = coordinate
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
    
    self.orderID = json["id"] as? Int ?? 0
    self.orderNo = json["orderNo"] as? String ?? ""
    self.note = json["remark"] as? String ?? ""
    
    self.startPoint = Point(self.progresses.first)
  }
  
  var telephone: String {
    guard let last = progresses.last else { return "" }
    return last.contactPhone
  }
  
  var currentOperationTitle: BehaviorRelay<String> {
    if case .grabed = state {
      switch type {
      case .buy:
        return Config.localizedText(for: "operation_bought")
      case .take, .send:
        return Config.localizedText(for: "operation_take")
      case .transfer:
        return Config.localizedText(for: "operation_transfer")
      default:
        break
      }
    } else if case .doing = state {
      return Config.localizedText(for: "operation_reached")
    }
    
    return BehaviorRelay(value: state.localizedText.value)
  }
  
  var shouldOpenCodePanel: Bool {
    if case .doing = state {
//      switch type {
//      case .buy, .take, .send:
//        return true
//      default:
//        break
//      }
      // Although `transfer` should not open code panel in PRD,
      // the current implementation is different.
      return true
    }
    
    return false
  }
  
  func pointAt(_ index: Int) -> Point? {
    guard index >= 0 && index < progresses.count else { return nil }
    return Point(progresses[index])
  }
}
