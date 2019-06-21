//
//  LBSServiceImpl.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/21.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import CoreLocation

class LBSServiceImpl: NSObject, LBSService {
  static let shared = LBSServiceImpl()
  
  private var locationManager: CLLocationManager!
  public private(set) var currentLocation: CLLocation?
  
  private override init() {
    super.init()
    if Thread.current == .main {
      self.initLocationManager()
    } else {
      DispatchQueue.main.sync {
        self.initLocationManager()
      }
    }
  }
  
  private func initLocationManager() {
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }
  
  func requestAuthorization() {
    if hasAuthorization() { return }
    locationManager.requestWhenInUseAuthorization()
  }
  
  func start() {
    guard hasAuthorization() else { return }
    locationManager .startUpdatingLocation()
  }
  
  func stop() {
    locationManager.stopUpdatingLocation()
  }
  
  private func hasAuthorization() -> Bool {
    let status = CLLocationManager.authorizationStatus()
    return !(status == .notDetermined || status == .denied || status == .restricted)
  }
}

extension LBSServiceImpl: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations.last
  }
}
