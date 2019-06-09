//
//  OrderCell.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

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
    if model.profit == nil {
      bottomView.isHidden = true
    }
    
    typeLabel.text = model.type.description
    timeLabel.text = model.timeString
    profitLabel.text = "预计收益: \(model.profit ?? "")"
    
    if let state = model.state {
      distanceLabel.text = state.description
      distanceLabel.textColor = state.color
    } else {
      distanceLabel.text = model.distance ?? ""
      distanceLabel.textColor = .RGBA(235, 56, 15, 1)
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
    
    typeLabel = ViewFactory.label(withText: "", font: UIFont.boldSystemFont(ofSize: 15))
    topView.addSubview(typeLabel)
    typeLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(iconImageView.snp.trailing).offset(5)
      make.centerY.equalTo(iconImageView)
    }
    
    timeLabel = ViewFactory.label(withText: "", font: UIFont.systemFont(ofSize: 12))
    topView.addSubview(timeLabel)
    timeLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(topView)
      make.centerY.equalTo(iconImageView)
    }
    
    distanceLabel = ViewFactory.label(withText: "", font: UIFont.systemFont(ofSize: 12))
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
  
  func initBottomView() {
    bottomView = UIView()
    bottomView.backgroundColor = .themeGreen
    wrapperView.addSubview(bottomView)
    
    profitLabel = ViewFactory.label(withText: "", font: UIFont.systemFont(ofSize: 15))
    profitLabel.textColor = .white
    bottomView.addSubview(profitLabel)
    profitLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(13)
      make.centerY.equalTo(bottomView)
    }
    
    let grabButton = ViewFactory.button(withTitle: "确认抢单", font: UIFont.boldSystemFont(ofSize: 14))
    grabButton.backgroundColor = .white
    grabButton.setTitleColor(.themeGreen, for: .normal)
    grabButton.layer.cornerRadius = 5
    grabButton.layer.masksToBounds = true
    bottomView.addSubview(grabButton)
    grabButton.snp.makeConstraints { (make) in
      make.width.equalTo(120)
      make.height.equalTo(32)
      make.centerY.equalTo(profitLabel)
      make.trailing.equalTo(-13)
    }
  }
}
