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
import RxCocoa
import RxGesture

class SigninViewController : UIViewController {
  private var usernameField: InputField!
  private var passwordField: InputField!
  private var loginButton: UIButton!
  private var loadingView: UIActivityIndicatorView!
  private var rememberButton: UIButton!
  private var rememberLabel: UILabel!
  
  private let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initSubviews()
    bindViewModel()
  }
  
  private func initSubviews() {
    let logoImageView = UIImageView(image: UIImage(named: "logo"))
    logoImageView.contentMode = .scaleAspectFill
    view.addSubview(logoImageView)
    logoImageView.snp.makeConstraints { (make) in
      make.size.equalTo(CGSize(width: 123, height: 43))
      make.centerX.equalTo(view)
      make.top.equalTo(82)
    }
    
    let titleLabel = ViewFactory.label(withText: "One Minute 司机端", font: .boldSystemFont(ofSize: 17))
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(logoImageView.snp_bottom).offset(28)
      make.centerX.equalTo(logoImageView)
    }
    
    usernameField = InputField(logo: "phone", title: "登录账号", placeholder: "请输入您的账号")
    usernameField.textField.keyboardType = .phonePad
    view.addSubview(usernameField)
    usernameField.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp_bottom).offset(38)
      make.trailing.leading.equalTo(0)
      make.height.equalTo(InputField.height)
    }
    
    passwordField = InputField(logo: "lock", title: "登录密码", placeholder: "请输入您的密码")
    passwordField.textField.isSecureTextEntry = true
    view.addSubview(passwordField)
    passwordField.snp.makeConstraints { (make) in
      make.top.equalTo(usernameField.snp_bottom).offset(30)
      make.trailing.leading.equalTo(0)
      make.height.equalTo(InputField.height)
    }
    
    loginButton = ViewFactory.button(withTitle: "马上登录", font: .systemFont(ofSize: 18))
    loginButton.backgroundColor = .themeGreen
    loginButton.layer.cornerRadius = 5
    loginButton.layer.masksToBounds = true
    loginButton.setTitleColor(.white, for: .normal)
    view.addSubview(loginButton)
    loginButton.snp.makeConstraints { (make) in
      make.leading.equalTo(37)
      make.trailing.equalTo(-37)
      make.top.equalTo(passwordField.snp_bottom).offset(60)
      make.height.equalTo(44)
    }
    
    loadingView = UIActivityIndicatorView(style: .gray)
    loadingView.hidesWhenStopped = true
    view.addSubview(loadingView)
    loadingView.snp.makeConstraints { (make) in
      make.size.equalTo(CGSize(width: 40, height: 40))
      make.center.equalTo(loginButton.snp.center)
    }
    
    rememberButton = UIButton(type: .custom)
    rememberButton.setImage(UIImage(named: "right"), for: .selected)
    rememberButton.layer.borderColor = UIColor.themeGreen.cgColor
    rememberButton.layer.borderWidth = 1.0
    view.addSubview(rememberButton)
    rememberButton.snp.makeConstraints { (make) in
      make.width.height.equalTo(16)
      make.top.equalTo(passwordField.snp.bottom).offset(12)
      make.leading.equalTo(36)
    }
    
    rememberLabel = ViewFactory.label(withText: "记住密码", font: .systemFont(ofSize: 12))
    rememberLabel.textColor = .omTextGray
    view.addSubview(rememberLabel)
    rememberLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(rememberButton.snp.centerY)
      make.leading.equalTo(rememberButton.snp.trailing).offset(5)
    }
  }
  
  private func bindViewModel() {
    view.rx.tapGesture().do(onNext: { [weak self] _ in
      self?.view.endEditing(true)
    }).subscribe()
      .disposed(by: bag)
    
    Observable.merge(rememberButton.rx.controlEvent(.touchUpInside).asObservable(), rememberLabel.rx.tapGesture().asObservable().map { _ in () }).do(onNext: { [weak self] (_) in
      self?.rememberButton.isSelected = !(self?.rememberButton.isSelected ?? true)
    }).subscribe().disposed(by: bag)
    
    let usernameResult = BehaviorRelay<ValidationResult>(value: .ok)
    let passwordResult = BehaviorRelay<ValidationResult>(value: .ok)
    
    let viewModel = SigninViewModel(input: (
      username: usernameField.textField.rx.text.orEmpty.asDriver(),
      password: passwordField.textField.rx.text.orEmpty.asDriver(),
      validatedUsername: usernameResult.asDriver(onErrorJustReturn: .empty),
      validatedPassword: passwordResult.asDriver(onErrorJustReturn: .empty),
      loginTaps: loginButton.rx.tap.asSignal()
    ), dependency: (
      api: SigninServiceImplementation.shared,
      validation: ValidationServiceImplementation.shared
    ))
    
    viewModel.signinEnabled.drive(onNext: { [weak self] valid in
      self?.loginButton.isEnabled = valid
      self?.loginButton.alpha = valid ? 1.0 : 0.5
    }).disposed(by: bag)
    
    viewModel.signingIn.drive(loadingView.rx.isAnimating).disposed(by: bag)
    
    Driver.merge(viewModel.inputUsername, usernameResult.asDriver(onErrorJustReturn: .empty)).drive(usernameField.rx.validationResult).disposed(by: bag)
    Driver.merge(viewModel.inputPassword, passwordResult.asDriver(onErrorJustReturn: .empty)).drive(passwordField.rx.validationResult).disposed(by: bag)
    
    // remove error when retry 
    Driver.merge(viewModel.inputUsername, viewModel.inputPassword).do(onNext: { (_) in
      usernameResult.accept(.ok)
      passwordResult.accept(.ok)
    }).drive().disposed(by: bag)
    
    viewModel.signedIn.do(onNext: { result in
      guard case .failed = result.result else { return }
      
      if result.isUsername {
        usernameResult.accept(result.result)
      } else {
        passwordResult.accept(result.result)
      }
    }).do(onNext: { [weak self] result in
      guard case .ok = result.result else { return }
      
      if let needRemember = self?.rememberButton.isSelected, needRemember {
        let username = self?.usernameField.textField.text ?? ""
        let password = self?.passwordField.textField.text ?? ""
        
        // TODO: remember user
      } else {
        
      }
    }).drive(onNext: { signedIn in
      print("User signed in \(signedIn)")
    }).disposed(by: bag)
  }
}
