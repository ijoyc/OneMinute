//
//  InputField.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/5.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import SnapKit

class InputField : UIView {
  static let height = 85
  
  var keyboardType: UIKeyboardType = .default {
    didSet {
      textField.keyboardType = keyboardType
    }
  }
  var isSecureTextEntry = false {
    didSet {
      textField.isSecureTextEntry = isSecureTextEntry
    }
  }
  
  private let logo: String
  private let text: String
  private let placeholder: String

  private let logoImageView = UIImageView()
  private let nameLabel = UILabel()
  private let textField = UITextField()
  
  init(logo: String, text: String, placeholder: String) {
    self.logo = logo
    self.text = text
    self.placeholder = placeholder
    super.init(frame: .zero)
    
    self.initSubviews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initSubviews() {
    logoImageView.image = UIImage(named: logo)
    logoImageView.contentMode = .scaleAspectFill
    addSubview(logoImageView)
    logoImageView.snp.makeConstraints { (make) in
      make.width.height.equalTo(24)
      make.leading.equalTo(34)
    }

    nameLabel.text = text
    nameLabel.font = UIFont.systemFont(ofSize: 16.0)
    addSubview(nameLabel)
    nameLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(logoImageView.snp_centerY)
      make.leading.equalTo(logoImageView.snp_trailing).offset(10)
    }
    
    textField.placeholder = placeholder
    addSubview(textField)
    textField.snp.makeConstraints { (make) in
      make.top.equalTo(logoImageView.snp_bottom).offset(20)
      make.leading.equalTo(logoImageView.snp_leading)
      make.trailing.equalTo(-37)
      make.height.equalTo(40)
    }
  }
}
