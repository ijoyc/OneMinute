//
//  LBSServiceImpl.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/21.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

class LBSServiceImpl: NSObject, LBSService {
  static let shared = LBSServiceImpl()
  
  
  public let uploadSuccess = BehaviorRelay<Bool>(value: false)
  public let location = BehaviorRelay<CLLocation?>(value: nil)
  public private(set) var currentLocation: CLLocation?
  private var locationManager: CLLocationManager!
  private var timer: DisposeBag?
  
  private let bag = DisposeBag()
  
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
    locationManager.startUpdatingLocation()
  }
  
  func stop() {
    locationManager.stopUpdatingLocation()
  }
  
  func startUploadLocation() {
    guard timer == nil else { return }
    
    timer = DisposeBag()
    Observable
      .merge(.interval(.seconds(30), scheduler: MainScheduler.instance),
        location.filter { $0 != nil }.take(1).map { _ in 0 })
      .subscribe(onNext: { _ in
        self.uploadLocation()
      })
      .disposed(by: timer!)
  }
  
  func stopUploadLocation() {
    timer = nil
  }
  
  func uploadLocation() {
    guard let location = location.value else { return }
    let latitude = location.coordinate.latitude
    let longitude = location.coordinate.longitude
    
    OneMinuteAPI
      .post(.uploadLocation, parameters: ["lat": latitude, "lng": longitude])
      .map { json in
        Result(success: (json["code"] as? String ?? "") == "200", message: json["message"] as? String ?? "")
      }
      .do(onNext: { result in
        print("Upload Location (\(self.currentLocation?.coordinate.latitude ?? 0), \(self.currentLocation?.coordinate.longitude ?? 0)) result: success = \(result.success), message = \(result.message)")
      })
      .filter { $0.success }
      .map { _ in true }
      .bind(to: uploadSuccess)
      .disposed(by: bag)
  }
  
  private func hasAuthorization() -> Bool {
    let status = CLLocationManager.authorizationStatus()
    return !(status == .notDetermined || status == .denied || status == .restricted)
  }
}

extension LBSServiceImpl: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    location.accept(locations.last)
    currentLocation = locations.last
  }
}
