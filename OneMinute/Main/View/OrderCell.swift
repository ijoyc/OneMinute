//
//  OrderCell.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OrderCell : UITableViewCell {
  private var mainView: UIView!
  private var wrapperView: UIView! // for shadow & corner radius
  private var topView: UIView!
  private var progressView: UIView!
  private var bottomView: UIView!
  
  private var iconImageView: UIImageView!
  private var typeLabel: UILabel!
  private var timeLabel: UILabel!
  private var distanceLabel: UILabel!
  private var profitLabel: UILabel!
  private var scheduleLabel: UILabel!
  fileprivate var grabButton: UIButton!
  
  private let bag = DisposeBag()
  
  var cellModel: OrderCellModel? {
    didSet {
      setNeedsLayout()
    }
  }
  
  private var model: Order? {
    return cellModel?.model
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    initSubviews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    guard let cellModel = self.cellModel, let model = self.model else {
      return
    }
    
    resetProgressView(model: model)
    
    mainView.frame = cellModel.mainFrame
    wrapperView.frame = CGRect(x: 0, y: 0, width: cellModel.mainFrame.width, height: cellModel.mainFrame.height)
    topView.frame = cellModel.topViewFrame
    progressView.frame = cellModel.progressViewFrame
    for i in 0 ..< progressView.subviews.count {
      progressView.subviews[i].frame = cellModel.progressFrames[i]
    }
    
    bottomView.frame = cellModel.bottomViewFrame ?? .zero
    if !model.isGrabable {
      bottomView.isHidden = true
    }
    
    typeLabel.text = model.type.localizedText.value
    timeLabel.text = model.scheduleTime
    scheduleLabel.text = model.scheduleFlag == 0 ? Config.localizedText(for: "order_instant").value : Config.localizedText(for: "order_scheduled").value
    profitLabel.text = "\(Config.localizedText(for: "order_predict_profit").value): \(String(format: "$%.2f", model.profit))"
    
    if model.isGrabable {
      distanceLabel.text = String(format: "\(Config.localizedText(for: "order_distance").value)%.1fkm", model.distance)
      distanceLabel.textColor = .secondaryTextColor
    } else {
      distanceLabel.text = model.state.localizedText.value
      distanceLabel.textColor = model.state.color
    }
  }
}

// MARK: - UI

extension OrderCell {
  private func initSubviews() {
    selectionStyle = .none
    backgroundColor = .clear
    
    mainView = UIView()
    mainView.layer.shadowOffset = CGSize(width: 0, height: 0)
    mainView.layer.shadowOpacity = 0.3
    mainView.layer.shadowRadius = 5
    contentView.addSubview(mainView)
    
    wrapperView = UIView()
    wrapperView.backgroundColor = .white
    wrapperView.layer.masksToBounds = true
    wrapperView.layer.cornerRadius = 5
    mainView.addSubview(wrapperView)
    
    initTopView()
    initBottomView()
  }
  
  private func initTopView() {
    topView = UIView()
    wrapperView.addSubview(topView)
    
    iconImageView = UIImageView(image: UIImage(named: "buy"))
    topView.addSubview(iconImageView)
    iconImageView.snp.makeConstraints { (make) in
      make.width.height.equalTo(24)
      make.leading.equalTo(12)
      make.top.equalTo(10)
    }
    
    typeLabel = ViewFactory.label(withText: "", font: .boldSystemFont(ofSize: 15))
    topView.addSubview(typeLabel)
    typeLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(iconImageView.snp.trailing).offset(5)
      make.centerY.equalTo(iconImageView)
    }
    
    timeLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 12))
    topView.addSubview(timeLabel)
    timeLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(topView)
      make.centerY.equalTo(iconImageView)
    }
    
    distanceLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 12))
    topView.addSubview(distanceLabel)
    distanceLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(iconImageView)
      make.trailing.equalTo(topView).offset(-12)
    }
    
    let bottomLine = ViewFactory.separateLine()
    topView.addSubview(bottomLine)
    bottomLine.snp.makeConstraints { (make) in
      make.leading.equalTo(12)
      make.trailing.equalTo(-12)
      make.height.equalTo(1)
      make.bottom.equalTo(topView)
    }
  }
  
  private func resetProgressView(model: Order) {
    // remove previous first
    if progressView != nil {
      progressView.removeFromSuperview()
    }
    
    progressView = UIView()
    wrapperView.addSubview(progressView)
    
    let total = model.progresses.count
    for i in 0 ..< total {
      let wrapper = UIView()
      progressView.addSubview(wrapper)
      
      let progress = model.progresses[i]
      let iconView = UIView()
      iconView.backgroundColor = .white
      iconView.layer.borderColor = i == 0 ? UIColor.RGBA(129, 215, 207, 1).cgColor : UIColor.RGBA(238, 54, 0, 1).cgColor
      iconView.layer.borderWidth = 2.0
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
  
  func initBottomView() {
    bottomView = UIView()
    bottomView.backgroundColor = .themeGreen
    wrapperView.addSubview(bottomView)
    
    let labelWrapper = UIView()
    bottomView.addSubview(labelWrapper)
    
    scheduleLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 12))
    scheduleLabel.textColor = .RGBA(39, 149, 138, 1)
    labelWrapper.addSubview(scheduleLabel)
    
    profitLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 15))
    profitLabel.textColor = .white
    labelWrapper.addSubview(profitLabel)
    
    scheduleLabel.snp.makeConstraints { (make) in
      make.top.leading.trailing.equalTo(0)
      make.bottom.equalTo(profitLabel.snp.top).offset(-4)
    }
    
    profitLabel.snp.makeConstraints { (make) in
      make.leading.trailing.bottom.equalTo(0)
    }
    
    labelWrapper.snp.makeConstraints { (make) in
      make.leading.equalTo(13)
      make.centerY.equalTo(bottomView)
    }
    
    grabButton = ViewFactory.button(withTitle: "", font: .boldSystemFont(ofSize: 14))
    Config.localizedText(for: "order_grab").bind(to: grabButton.rx.title(for: .normal)).disposed(by: bag)
    grabButton.backgroundColor = .white
    grabButton.setTitleColor(.themeGreen, for: .normal)
    grabButton.layer.cornerRadius = 5
    grabButton.layer.masksToBounds = true
    bottomView.addSubview(grabButton)
    grabButton.snp.makeConstraints { (make) in
      make.width.equalTo(120)
      make.height.equalTo(32)
      make.centerY.equalTo(bottomView)
      make.trailing.equalTo(-13)
    }
  }
}

extension Reactive where Base: OrderCell {
  var grabOrder: ControlEvent<Void> {
    return base.grabButton.rx.tap
  }
}
