//
//  ProfileHeaderView.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

class ProfileHeaderView : UIView {
  var profileView: UIImageView!
  var nameLabel: UILabel!
  var ordersLabel: UILabel!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    initSubviews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initSubviews() {    
    let mainView = UIView()
    mainView.layer.shadowColor = UIColor.themeGreen.cgColor
    mainView.layer.shadowOffset = CGSize(width: 0, height: 2)
    mainView.layer.shadowRadius = 5
    mainView.layer.shadowOpacity = 1
    addSubview(mainView)
    mainView.snp.makeConstraints { (make) in
      make.top.equalTo(22)
      make.leading.equalTo(16)
      make.trailing.equalTo(-16)
      make.height.equalTo(89)
    }
    
    let contentView = UIView()
    contentView.backgroundColor = .themeGreen
    contentView.layer.cornerRadius = 5
    contentView.layer.masksToBounds = true
    mainView.addSubview(contentView)
    contentView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    profileView = UIImageView()
    profileView.backgroundColor = .white
    profileView.layer.cornerRadius = 26
    profileView.layer.masksToBounds = true
    profileView.layer.borderColor = UIColor.white.cgColor
    profileView.layer.borderWidth = 2.0
    contentView.addSubview(profileView)
    profileView.snp.makeConstraints { (make) in
      make.width.height.equalTo(52)
      make.leading.equalTo(15)
      make.centerY.equalTo(contentView)
    }
    
    nameLabel = ViewFactory.label(withText: "", font: .boldSystemFont(ofSize: 15))
    nameLabel.textColor = .white
    contentView.addSubview(nameLabel)
    nameLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(profileView.snp.trailing).offset(10)
      make.bottom.equalTo(contentView.snp.centerY).offset(-6)
    }
    
    let descLabel = ViewFactory.label(withText: Config.localizedText(for: "user_desc"), font: .systemFont(ofSize: 14))
    descLabel.textColor = .white
    contentView.addSubview(descLabel)
    descLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(nameLabel)
      make.top.equalTo(nameLabel.snp.bottom).offset(12)
    }
    
    ordersLabel = ViewFactory.label(withText: "2983 \(Config.localizedText(for: "user_order_unit"))", font: .boldSystemFont(ofSize: 14))
    ordersLabel.textColor = .white
    contentView.addSubview(ordersLabel)
    ordersLabel.snp.makeConstraints { (make) in
      make.trailing.equalTo(-12)
      make.centerY.equalTo(contentView)
    }
    
    let orderIcon = UIImageView(image: UIImage(named: "order_orange"))
    contentView.addSubview(orderIcon)
    orderIcon.snp.makeConstraints { (make) in
      make.width.height.equalTo(20)
      make.centerY.equalTo(contentView)
      make.trailing.equalTo(ordersLabel.snp.leading).offset(-4)
    }
  }
  
  override func updateConstraints() {
    super.updateConstraints()
  }
}
