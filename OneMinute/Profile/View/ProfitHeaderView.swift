//
//  ProfitHeaderView.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

class ProfitHeaderView : UIView {
  var profitLabel: UILabel!
  var withdrawLabel: UILabel!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initSubviews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initSubviews() {
    let mainView = UIView()
    mainView.layer.shadowColor = UIColor.RGBA(155, 155, 155, 0.2).cgColor
    mainView.layer.shadowOffset = CGSize(width: 0, height: 0)
    mainView.layer.shadowRadius = 12.5
    mainView.layer.shadowOpacity = 1
    addSubview(mainView)
    mainView.snp.makeConstraints { (make) in
      make.top.equalTo(10)
      make.leading.equalTo(15)
      make.trailing.equalTo(-15)
      make.height.equalTo(129)
    }
    
    let contentView = UIView()
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 10
    contentView.layer.masksToBounds = true
    mainView.addSubview(contentView)
    contentView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    let profitTipLabel = ViewFactory.label(withText: "今日收益", font: .systemFont(ofSize: 12))
    contentView.addSubview(profitTipLabel)
    profitTipLabel.snp.makeConstraints { (make) in
      make.top.equalTo(42)
      make.centerX.equalTo(contentView).multipliedBy(0.5)
    }
    
    let dollarLabel = ViewFactory.label(withText: "$", font: .systemFont(ofSize: 20))
    contentView.addSubview(dollarLabel)
    dollarLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(33)
      make.top.equalTo(profitTipLabel.snp.bottom).offset(15)
    }
    
    profitLabel = ViewFactory.label(withText: "00.00", font: .boldSystemFont(ofSize: 24))
    contentView.addSubview(profitLabel)
    profitLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(dollarLabel.snp.trailing).offset(2)
      make.bottom.equalTo(dollarLabel)
    }
    
    let line = UIView()
    line.backgroundColor = .RGBA(155, 155, 155, 0.2)
    contentView.addSubview(line)
    line.snp.makeConstraints { (make) in
      make.center.equalTo(contentView)
      make.width.equalTo(1)
      make.height.equalTo(34)
    }
    
    let withdrawTipLabel = ViewFactory.label(withText: "可提现收益", font: .systemFont(ofSize: 12))
    contentView.addSubview(withdrawTipLabel)
    withdrawTipLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(contentView.snp.trailing).multipliedBy(0.75)
      make.top.equalTo(profitTipLabel.snp.top)
    }
    
    withdrawLabel = ViewFactory.label(withText: "00.00", font: .boldSystemFont(ofSize: 24))
    contentView.addSubview(withdrawLabel)
    withdrawLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(withdrawTipLabel)
      make.top.equalTo(profitLabel.snp.top)
    }
    
    let dollarLabel2 = ViewFactory.label(withText: "$", font: .systemFont(ofSize: 20))
    contentView.addSubview(dollarLabel2)
    dollarLabel2.snp.makeConstraints { (make) in
      make.trailing.equalTo(withdrawLabel.snp.leading).offset(-2)
      make.bottom.equalTo(withdrawLabel.snp.bottom)
    }
  }
}
