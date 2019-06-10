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
  
  private func initSubviews() {
    mapView = MKMapView()
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
    
    typeLabel = ViewFactory.label(withText: "", font: UIFont.systemFont(ofSize: 12))
    typeLabel.textColor = .themeGreen
    topView.addSubview(typeLabel)
    typeLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(iconImageView.snp.trailing).offset(6)
      make.centerY.equalTo(iconImageView)
    }
    
    idLabel = ViewFactory.label(withText: "", font: UIFont.systemFont(ofSize: 12))
    idLabel.textColor = .omTextGray
    topView.addSubview(idLabel)
    idLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(typeLabel.snp.trailing).offset(3)
      make.centerY.equalTo(iconImageView)
    }
    
    stateLabel = ViewFactory.label(withText: "", font: UIFont.systemFont(ofSize: 12))
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
  }
  
  private func addProgressView(model: OrderDetail) {
    progressView = UIView()
    orderView.addSubview(progressView)
    progressView.snp.makeConstraints { (make) in
      make.leading.trailing.height.equalTo(0)
      make.top.equalTo(topView.snp.bottom)
    }
    
    let total = model.progresses.count
    for i in 0 ..< total {
      let wrapper = UIView()
      progressView.addSubview(wrapper)
      
      let progress = model.progresses[i]
      let iconView = ViewFactory.label(withText: progress.type.description, font: UIFont.systemFont(ofSize: 10))
      iconView.textColor = .white
      iconView.textAlignment = .center
      iconView.backgroundColor = progress.type.iconColor
      iconView.layer.masksToBounds = true
      iconView.layer.cornerRadius = 15 / 2
      wrapper.addSubview(iconView)
      iconView.snp.makeConstraints { (make) in
        make.width.height.equalTo(15)
        make.leading.equalTo(12)
        make.top.equalTo(15)
      }
      
      let titleLabel = ViewFactory.label(withText: progress.title, font: UIFont.boldSystemFont(ofSize: 14))
      wrapper.addSubview(titleLabel)
      titleLabel.snp.makeConstraints { (make) in
        make.leading.equalTo(iconView.snp.trailing).offset(10)
        make.top.equalTo(17)
      }
      
      let descLabel = ViewFactory.label(withText: progress.desc, font: UIFont.systemFont(ofSize: 12))
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
      
      // current progress indicator
      if (i == model.progress - 1) {
        let indicator = UIImageView(image: UIImage(named: "progress"))
        wrapper.addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
          make.size.equalTo(CGSize(width: 8, height: 14))
          make.bottom.equalTo(-3)
          make.centerX.equalTo(iconView)
        }
      }
    }
  }
  
  private func initBottomView() {
    bottomView = UIView()
    orderView.addSubview(bottomView)
    bottomView.snp.makeConstraints { (make) in
      make.leading.trailing.bottom.height.equalTo(0)
    }
    
    noteLabel = ViewFactory.label(withText: "", font: UIFont.systemFont(ofSize: 12))
    noteLabel.textColor = .RGBA(235, 56, 26, 1)
    bottomView.addSubview(noteLabel)
    noteLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(16)
      make.top.equalTo(0)
    }
    
    telButton = ViewFactory.button(withTitle: "联系下单人", font: UIFont.boldSystemFont(ofSize: 17))
    telButton.backgroundColor = .white
    telButton.setTitleColor(.themeGreen, for: .normal)
    telButton.layer.cornerRadius = 5
    telButton.layer.masksToBounds = true
    telButton.layer.borderWidth = 1
    telButton.layer.borderColor = UIColor.themeGreen.cgColor
    bottomView.addSubview(telButton)
    
    dealButton = ViewFactory.button(withTitle: "", font: UIFont.boldSystemFont(ofSize: 17))
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
  
  private func updateUI() {
    guard let orderDetail = self.orderDetail else { return }
    
    typeLabel.text = orderDetail.type.description
    idLabel.text = "| \(orderDetail.orderID)"
    stateLabel.text = "\(orderDetail.state) >"
    
    addProgressView(model: orderDetail)
    
    noteLabel.text = "备注:\(orderDetail.note)"
    
    var top: CGFloat = 0
    let maxWidth = topView.frame.width - 41 - 16
    for i in 0 ..< orderDetail.progresses.count {
      let progress = orderDetail.progresses[i]
      let titleSize = progress.title.boundingSize(with: maxWidth, font: UIFont.boldSystemFont(ofSize: 14))
      let descSize = progress.desc.boundingSize(with: maxWidth, font: UIFont.systemFont(ofSize: 12))
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
    
    // Commit pending layout operations first,
    // so that the following animation will only work on orderView's height
    view.layoutIfNeeded()
    
    orderView.snp.updateConstraints { (make) in
      make.height.equalTo(40 + top + 87 + OMGetSafeArea().bottom)
    }
    view.setNeedsUpdateConstraints()
    
    
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }
  
  private func bindViewModel() {
    let viewModel = OrderDetailViewModel(orderID: orderID, api: OrderAPIImplementation.shared)
    
    viewModel.orderDetail.do(onNext: { [weak self] orderDetail in
      self?.orderDetail = orderDetail
      self?.updateUI()
    }).drive().disposed(by: bag)
  }
}
