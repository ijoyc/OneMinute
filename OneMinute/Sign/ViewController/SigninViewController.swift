//
//  SigninViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/5.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxGesture

class SigninViewController : UIViewController {
  private var logoImageView: UIImageView!
  private var titleLabel: UILabel!
  private var usernameField: InputField!
  private var passwordField: InputField!
  private var loginButton: UIButton!
  
  private let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initSubviews()
    initBinding()
  }
  
  private func initSubviews() {
    logoImageView = UIImageView(image: UIImage(named: "logo"))
    logoImageView.contentMode = .scaleAspectFill
    view.addSubview(logoImageView)
    logoImageView.snp.makeConstraints { (make) in
      make.size.equalTo(CGSize(width: 123, height: 43))
      make.centerX.equalTo(view)
      make.top.equalTo(82)
    }
    
    titleLabel = UILabel(frame: .zero)
    titleLabel.text = "One Minute 司机端"
    titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(logoImageView.snp_bottom).offset(28)
      make.centerX.equalTo(logoImageView)
    }
    
    usernameField = InputField(logo: "phone", text: "登录账号", placeholder: "请输入您的账号")
    usernameField.keyboardType = .phonePad
    view.addSubview(usernameField)
    usernameField.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp_bottom).offset(38)
      make.trailing.leading.equalTo(0)
      make.height.equalTo(InputField.height)
    }
    
    passwordField = InputField(logo: "lock", text: "登录密码", placeholder: "请输入您的密码")
    passwordField.isSecureTextEntry = true
    view.addSubview(passwordField)
    passwordField.snp.makeConstraints { (make) in
      make.top.equalTo(usernameField.snp_bottom).offset(30)
      make.trailing.leading.equalTo(0)
      make.height.equalTo(InputField.height)
    }
    
    loginButton = UIButton(type: .custom)
    loginButton.backgroundColor = UIColor.RGBA(132, 215, 207, 1)
    loginButton.layer.cornerRadius = 5
    loginButton.layer.masksToBounds = true
    loginButton.setTitle("马上登录", for: .normal)
    loginButton.setTitleColor(.white, for: .normal)
    loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
    view.addSubview(loginButton)
    loginButton.snp.makeConstraints { (make) in
      make.leading.equalTo(37)
      make.trailing.equalTo(-37)
      make.top.equalTo(passwordField.snp_bottom).offset(60)
      make.height.equalTo(44)
    }
  }
  
  private func initBinding() {
    view.rx.tapGesture().do(onNext: { [weak self] _ in
      self?.view.endEditing(true)
    }).subscribe()
      .disposed(by: bag)
  }
}
