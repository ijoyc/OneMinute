//
//  OrderDetailViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/9.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

class OrderDetailViewController : BaseViewController {
  var locationService: LBSService?
  
  private var mapView: MKMapView!
  private var orderView: UIView!
  
  private var topView: UIView!
  private var progressView: UIView!
  private var bottomView: UIView!
  
  private var iconImageView: UIImageView!
  private var typeLabel: UILabel!
  private var idLabel: UILabel!
  private var stateLabel: UILabel!
  private var noteLabel: UILabel!
  private var telButton: UIButton!
  private var dealButton: UIButton!
  
  private let orderID: Int
  private let bag = DisposeBag()
  private var orderDetail: OrderDetail?
  private let endPoint = BehaviorRelay<Int>(value: 0)
  private var calculatedOrderViewHeight: CGFloat?
  
  private let cellID = "orderDetailCellID"
  
  init(orderID: Int) {
    self.orderID = orderID
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "订单详情"
    
    initSubviews()
    bindViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    locationService?.start()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    locationService?.stop()
  }
  
  private func bindViewModel() {
    let changeStateTrigger = PublishSubject<OrderState>()
    let finishTrigger = PublishSubject<String>()
    
    let viewModel = OrderDetailViewModel(input: (
        orderID: orderID,
        changeStateSignal: changeStateTrigger.asSignal(onErrorJustReturn: .paying),
        finishTrigger.asSignal(onErrorJustReturn: "")
      ),
                                         api: OrderAPIImplementation.shared)
    
    let model = viewModel.queryResult.map { $0.orderDetail }.filter { $0 != nil }.map { $0! }

    model.do(onNext: { [weak self] orderDetail in
      self?.orderDetail = orderDetail
      self?.updateUI()
    }).drive().disposed(by: bag)
    
    viewModel.orderState.skip(2).subscribe(onNext: { [weak self] state in
      self?.orderDetail?.state = state
      
      if case .finished = state {
        DealPopupView.dismiss()
        ViewFactory.showAlert("订单已完成", message: nil)
      }
    }).disposed(by: bag)
    viewModel.operationText.bind(to: dealButton.rx.title()).disposed(by: bag)
    viewModel.stateText.map { "\($0) >" }.bind(to: stateLabel.rx.text).disposed(by: bag)
    
    // Disable deal button when changing state of order
    
    viewModel.changingOrderState.map(!).drive(dealButton.rx.isEnabled).disposed(by: bag)
    
    // show error message if any
    
    viewModel.queryResult.map { $0.result }.filter { !$0.success }.drive(onNext: { result in
      ViewFactory.showAlert(result.message, message: nil)
    }).disposed(by: bag)
    viewModel.errorMessage.filter { $0.count > 0 }.subscribe(onNext: {
      ViewFactory.showAlert($0, message: nil)
    }).disposed(by: bag)
    
    telButton.rx.tap.subscribe(onNext: { [weak self] _ in
      guard let self = self,
        let orderDetail = self.orderDetail,
        let url = URL(string: "tel://\(orderDetail.telephone)"),
        UIApplication.shared.canOpenURL(url) else { return }
      
      UIApplication.shared.openURL(url)
    }).disposed(by: bag)
    
    dealButton.rx.tap.subscribe(onNext: { [weak self] in
      guard let self = self,
        let orderDetail = self.orderDetail else { return }
      
      if orderDetail.shouldOpenCodePanel {
        DealPopupView.show(on: self.view)
      } else if orderDetail.state.rawValue <= OrderState.doing.rawValue {
        var nextState: OrderState = .doing
        if case .doing = orderDetail.state {
          nextState = .finished
        }
        changeStateTrigger.onNext(nextState)
      }
    }).disposed(by: bag)
    
    DealPopupView.shared.submitButton.rx.tap.map { DealPopupView.shared.code }.filter { $0.count == 4 }.subscribe(onNext: { code in
      finishTrigger.onNext(code)
    }).disposed(by: bag)
    
    // default: the last address.
    // tap: change endpoint address
    model.map { $0.progresses.count - 1 }.drive(endPoint).disposed(by: bag)
    progressView.rx.tapGesture().asLocation().map { location in
      self.progressView.subviews.firstIndex {
        location.y >= $0.frame.minY && location.y <= $0.frame.maxY
      } ?? 0
    }.bind(to: endPoint).disposed(by: bag)
    
    let expanded = BehaviorRelay<Bool>(value: true)
    let swipe = progressView.rx.swipeGesture([.down, .up]).asDriver()
    // Collapse order view
    swipe.filter { $0.direction == .down }.map { _ in false }.drive(expanded).disposed(by: bag)
    // Expand order view
    swipe.filter { $0.direction == .up }.map { _ in true }.drive(expanded).disposed(by: bag)
    expanded.skip(1).distinctUntilChanged().subscribe(onNext: { [weak self] expanded in
      guard let orderDetail = self?.orderDetail, orderDetail.progresses.count > 3 else { return }
      
      if expanded {
        self?.expandOrderView()
      } else {
        self?.collapseOrderView()
      }
    }).disposed(by: bag)
    
    endPoint.subscribe(onNext: { index in
      self.updateMapView(index)
    }).disposed(by: bag)
  }
}

// MARK: - UI Initialize

extension OrderDetailViewController {
  private func initSubviews() {
    mapView = MKMapView()
    mapView.delegate = self
    mapView.showsUserLocation = true
    view.addSubview(mapView)
    mapView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    orderView = UIView()
    orderView.backgroundColor = .white
    view.addSubview(orderView)
    orderView.snp.makeConstraints { (make) in
      make.bottom.leading.trailing.height.equalTo(0)
    }
    
    initTopView()
    initBottomView()
  }
  
  private func initTopView() {
    topView = UIView()
    orderView.addSubview(topView)
    topView.snp.makeConstraints { (make) in
      make.leading.trailing.top.equalTo(0)
      make.height.equalTo(40)
    }
    
    iconImageView = UIImageView(image: UIImage(named: "buy_highlight"))
    topView.addSubview(iconImageView)
    iconImageView.snp.makeConstraints { (make) in
      make.width.height.equalTo(20)
      make.leading.equalTo(16)
      make.top.equalTo(10)
    }
    
    typeLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 12))
    typeLabel.textColor = .themeGreen
    topView.addSubview(typeLabel)
    typeLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(iconImageView.snp.trailing).offset(6)
      make.centerY.equalTo(iconImageView)
    }
    
    idLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 12))
    idLabel.textColor = .omTextGray
    topView.addSubview(idLabel)
    idLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(typeLabel.snp.trailing).offset(3)
      make.centerY.equalTo(iconImageView)
    }
    
    stateLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 12))
    topView.addSubview(stateLabel)
    stateLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(iconImageView)
      make.trailing.equalTo(topView).offset(-16)
    }
    
    let bottomLine = ViewFactory.separateLine()
    topView.addSubview(bottomLine)
    bottomLine.snp.makeConstraints { (make) in
      make.leading.trailing.equalTo(0)
      make.height.equalTo(1)
      make.bottom.equalTo(topView)
    }
    
    progressView = UIView()
    orderView.addSubview(progressView)
    progressView.snp.makeConstraints { (make) in
      make.leading.trailing.height.equalTo(0)
      make.top.equalTo(topView.snp.bottom)
    }
  }
  
  private func initBottomView() {
    bottomView = UIView()
    orderView.addSubview(bottomView)
    bottomView.snp.makeConstraints { (make) in
      make.leading.trailing.bottom.height.equalTo(0)
    }
    
    noteLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 12))
    noteLabel.textColor = .secondaryTextColor
    bottomView.addSubview(noteLabel)
    noteLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(16)
      make.top.equalTo(0)
    }
    
    telButton = ViewFactory.button(withTitle: "联系下单人", font: .boldSystemFont(ofSize: 17))
    telButton.backgroundColor = .white
    telButton.setTitleColor(.themeGreen, for: .normal)
    telButton.layer.cornerRadius = 5
    telButton.layer.masksToBounds = true
    telButton.layer.borderWidth = 1
    telButton.layer.borderColor = UIColor.themeGreen.cgColor
    bottomView.addSubview(telButton)
    
    dealButton = ViewFactory.button(withTitle: "", font: .boldSystemFont(ofSize: 17))
    dealButton.backgroundColor = .themeGreen
    dealButton.setTitleColor(.white, for: .normal)
    dealButton.layer.cornerRadius = 5
    dealButton.layer.masksToBounds = true
    bottomView.addSubview(dealButton)
    
    telButton.snp.makeConstraints { (make) in
      make.height.equalTo(48)
      make.top.equalTo(noteLabel.snp.bottom).offset(11)
      make.leading.equalTo(16)
    }
    dealButton.snp.makeConstraints { (make) in
      make.top.height.width.equalTo(telButton)
      make.trailing.equalTo(-16)
      make.leading.equalTo(telButton.snp.trailing).offset(10)
    }
  }
}

// MARK: - UI Update

extension OrderDetailViewController {
  private func addProgressView(model: OrderDetail) {
    let total = model.progresses.count
    for i in 0 ..< total {
      let wrapper = UIView()
      progressView.addSubview(wrapper)
      
      let progress = model.progresses[i]
      let progressType = ProgressType.create(with: model.type, index: i)
      let iconView = ViewFactory.label(withText: progressType.description, font: .systemFont(ofSize: 10))
      iconView.textColor = .white
      iconView.textAlignment = .center
      iconView.backgroundColor = progressType.iconColor
      iconView.layer.masksToBounds = true
      iconView.layer.cornerRadius = 15 / 2
      wrapper.addSubview(iconView)
      iconView.snp.makeConstraints { (make) in
        make.width.height.equalTo(15)
        make.leading.equalTo(12)
        make.top.equalTo(15)
      }
      
      let titleLabel = ViewFactory.label(withText: progress.title, font: .boldSystemFont(ofSize: 14))
      wrapper.addSubview(titleLabel)
      titleLabel.snp.makeConstraints { (make) in
        make.leading.equalTo(iconView.snp.trailing).offset(10)
        make.top.equalTo(17)
      }
      
      let descLabel = ViewFactory.label(withText: progress.desc, font: .systemFont(ofSize: 12))
      descLabel.textColor = .omTextGray
      descLabel.numberOfLines = 0
      wrapper.addSubview(descLabel)
      descLabel.snp.makeConstraints { (make) in
        make.leading.equalTo(titleLabel)
        make.trailing.equalTo(-16)
        make.top.equalTo(titleLabel.snp.bottom).offset(8)
      }
      
      let separateLine = ViewFactory.separateLine()
      wrapper.addSubview(separateLine)
      separateLine.snp.makeConstraints { (make) in
        make.leading.equalTo(titleLabel)
        make.trailing.equalTo(descLabel)
        make.bottom.equalTo(wrapper)
        make.height.equalTo(1)
      }
      
      if i != 0 {
        let topLine = ViewFactory.separateLine()
        wrapper.addSubview(topLine)
        topLine.snp.makeConstraints { (make) in
          make.top.equalTo(0)
          make.bottom.equalTo(iconView.snp.top)
          make.width.equalTo(1)
          make.centerX.equalTo(iconView)
        }
      }
      
      if i != total - 1 {
        let bottomLine = ViewFactory.separateLine()
        wrapper.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
          make.top.equalTo(iconView.snp.bottom)
          make.bottom.equalTo(wrapper)
          make.width.equalTo(1)
          make.centerX.equalTo(iconView)
        }
      }
    }
  }
  
  private func updateUI() {
    guard let orderDetail = self.orderDetail else { return }
    
    typeLabel.text = orderDetail.type.description
    idLabel.text = "| \(orderDetail.orderNo)"
    
    addProgressView(model: orderDetail)
    
    noteLabel.text = "备注:\(orderDetail.note)"
    
    var top: CGFloat = 0
    let maxWidth = topView.frame.width - 41 - 16
    for i in 0 ..< orderDetail.progresses.count {
      let progress = orderDetail.progresses[i]
      let titleSize = progress.title.boundingSize(with: maxWidth, font: .boldSystemFont(ofSize: 14))
      let descSize = progress.desc.boundingSize(with: maxWidth, font: .systemFont(ofSize: 12))
      let height = 17 + titleSize.height + 8 + descSize.height + 12
      progressView.subviews[i].frame = CGRect(x: 0, y: top, width: topView.frame.width, height: height)
      top += height
    }
    
    progressView.snp.updateConstraints { (make) in
      make.height.equalTo(top)
    }
    
    bottomView.snp.remakeConstraints { (make) in
      make.leading.trailing.equalTo(0)
      make.top.equalTo(progressView.snp.bottom)
      make.height.equalTo(87)
    }
    
    let orderViewHeight = 40 + top + 87 + OMGetSafeArea().bottom
    calculatedOrderViewHeight = orderViewHeight
    
    mapView.snp.updateConstraints { (make) in
      make.bottom.equalTo(-orderViewHeight)
    }
    
    // Commit pending layout operations first,
    // so that the following animation will only work on orderView's height
    view.layoutIfNeeded()
    
    orderView.snp.updateConstraints { (make) in
      make.height.equalTo(orderViewHeight)
    }
    view.setNeedsUpdateConstraints()
    
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
  
  private func updateMapView(_ index: Int) {
    guard let orderDetail = self.orderDetail, let location = locationService?.currentLocation else { return }
    
    // Clear last route
    mapView.removeAnnotations(mapView.annotations)
    mapView.removeOverlays(mapView.overlays)
    
    // Add current points and route
    let startPoint = OrderDetail.Point(location.coordinate)
    startPoint.isDriver = true
    let endPoint = orderDetail.pointAt(index)!

    let annotations = [startPoint, endPoint]
    mapView.addAnnotations(annotations)
    mapView.showAnnotations(annotations, animated: true)

    // Show Route
    if #available(iOS 10.0, *) {
      let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: startPoint.coordinate))
      let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: endPoint.coordinate))

      let directionRequest = MKDirections.Request()
      directionRequest.source = sourceItem
      directionRequest.destination = destinationItem
      directionRequest.transportType = .automobile

      let directions = MKDirections(request: directionRequest)
      directions.calculate { (response, error) in
        guard let response = response else {
          if let error = error {
            print("Failed to calculate route on map: \(error)")
          }
          return
        }

        let route = response.routes[0]
        self.mapView.addOverlay(route.polyline, level: .aboveRoads)
      }
    } else {
      // Fallback on earlier versions
    }
  }
  
  func collapseOrderView() {
    mapView.snp.updateConstraints { (make) in
      make.bottom.equalTo(-100)
    }
    orderView.snp.updateConstraints { (make) in
      make.height.equalTo(100)
    }
    view.setNeedsUpdateConstraints()
    
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
  
  func expandOrderView() {
    guard let height = calculatedOrderViewHeight else { return }
    mapView.snp.updateConstraints { (make) in
      make.bottom.equalTo(-height)
    }
    orderView.snp.updateConstraints { (make) in
      make.height.equalTo(height)
    }
    view.setNeedsUpdateConstraints()
    
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
}

// MARK: - MKMapViewDelegate

extension OrderDetailViewController : MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let annotation = annotation as? OrderDetail.Point else { return nil }
    let view = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
    view.image = annotation.isDriver ? UIImage(named: "driver") : UIImage(named: "receiver")
    return view
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = GradientPolylineRenderer(overlay: overlay, startColor: .red, endColor: .themeGreen)
    renderer.lineWidth = 5
    return renderer
  }
}

