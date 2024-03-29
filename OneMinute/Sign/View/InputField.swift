//
//  InputField.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/5.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class InputField : UIView {
  static let height = 85
  
  private let logo: String
  private let title: BehaviorRelay<String>
  private let placeholder: BehaviorRelay<String>
  
  public let textField = UITextField()
  fileprivate let errorLabel = UILabel()
  
  private let logoImageView = UIImageView()
  private let nameLabel = UILabel()
  
  private let bag = DisposeBag()
  
  init(logo: String, title: BehaviorRelay<String>, placeholder: BehaviorRelay<String>) {
    self.logo = logo
    self.title = title
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
      make.top.equalTo(0)
    }

    title.bind(to: nameLabel.rx.text).disposed(by: bag)
    nameLabel.font = .systemFont(ofSize: 16.0)
    addSubview(nameLabel)
    nameLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(logoImageView.snp_centerY)
      make.leading.equalTo(logoImageView.snp_trailing).offset(10)
    }
    
    placeholder.bind(to: textField.rx.placeholder).disposed(by: bag)
    addSubview(textField)
    textField.snp.makeConstraints { (make) in
      make.top.equalTo(logoImageView.snp_bottom).offset(20)
      make.leading.equalTo(logoImageView.snp_leading)
      make.trailing.equalTo(-37)
      make.height.equalTo(40)
    }
    
    let line = UIView()
    line.backgroundColor = UIColor.RGBA(221, 221, 221, 1)
    addSubview(line)
    line.snp.makeConstraints { (make) in
      make.leading.width.equalTo(textField)
      make.top.equalTo(textField.snp.bottom)
      make.height.equalTo(1)
    }
    
    errorLabel.textColor = UIColor.RGBA(232, 70, 90, 1.0)
    errorLabel.font = .systemFont(ofSize: 12)
    addSubview(errorLabel)
    errorLabel.snp.makeConstraints { (make) in
      make.right.equalTo(textField.snp.right)
      make.centerY.equalTo(textField.snp.centerY)
    }
  }
}

extension Reactive where Base: InputField {
  var validationResult: Binder<ValidationResult> {
    return Binder(base) { inputField, result in
      if case .failed(message: _) = result {
        inputField.errorLabel.isHidden = false
      } else {
        inputField.errorLabel.isHidden = true
      }
      
      if result.description.count > 0 {
        inputField.errorLabel.text = "* \(result.description)"
      }
    }
  }
}
