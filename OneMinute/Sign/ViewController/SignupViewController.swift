//
//  SignupViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/7/14.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignupViewController: UIViewController {
  private var usernameField: InlineField!
  private var passwordField: InlineField!
  private var firstNameField: InlineField!
  private var lastNameField: InlineField!
  private var cardNoField: InlineField!
  private var signupButton: UIButton!
  private var loadingView: UIActivityIndicatorView!
  private var backButton: UIButton!
  
  private let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initSubviews()
    bindViewModel()
  }
  
  private func initSubviews() {
    view.backgroundColor = .white
    
    let padding = 12
    
    let logoImageView = UIImageView(image: UIImage(named: "logo"))
    logoImageView.contentMode = .scaleAspectFill
    view.addSubview(logoImageView)
    logoImageView.snp.makeConstraints { (make) in
      make.size.equalTo(CGSize(width: 123, height: 43))
      make.centerX.equalTo(view)
      make.top.equalTo(OMGetSafeArea().top + 12)
    }
    
    let titleLabel = ViewFactory.label(withText: "", font: .boldSystemFont(ofSize: 17))
    Config.localizedText(for: "signin_title").bind(to: titleLabel.rx.text).disposed(by: bag)
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(logoImageView.snp_bottom).offset(padding)
      make.centerX.equalTo(logoImageView)
    }
    
    usernameField = InlineField(title: Config.localizedText(for: "signin_username"), placeholder: Config.localizedText(for: "signin_username_placeholder"))
    usernameField.textField.keyboardType = .phonePad
    view.addSubview(usernameField)
    usernameField.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp_bottom).offset(padding)
      make.trailing.leading.equalTo(0)
      make.height.equalTo(InlineField.height)
    }
    
    passwordField = InlineField(title: Config.localizedText(for: "signin_password"), placeholder: Config.localizedText(for: "signin_password_placeholder"))
    passwordField.textField.isSecureTextEntry = true
    view.addSubview(passwordField)
    passwordField.snp.makeConstraints { (make) in
      make.top.equalTo(usernameField.snp_bottom).offset(padding)
      make.trailing.leading.equalTo(0)
      make.height.equalTo(InlineField.height)
    }
    
    firstNameField = InlineField(title: Config.localizedText(for: "signup_firstname"), placeholder: Config.localizedText(for: "signup_firstname_placeholder"))
    view.addSubview(firstNameField)
    firstNameField.snp.makeConstraints { (make) in
      make.top.equalTo(passwordField.snp.bottom).offset(padding)
      make.trailing.leading.equalTo(0)
      make.height.equalTo(InlineField.height)
    }
    
    lastNameField = InlineField(title: Config.localizedText(for: "signup_lastname"), placeholder: Config.localizedText(for: "signup_lastname_placeholder"))
    view.addSubview(lastNameField)
    lastNameField.snp.makeConstraints { (make) in
      make.top.equalTo(firstNameField.snp.bottom).offset(padding)
      make.trailing.leading.equalTo(0)
      make.height.equalTo(InlineField.height)
    }
    
    cardNoField = InlineField(title: Config.localizedText(for: "signup_card"), placeholder: Config.localizedText(for: "signup_card_placeholder"))
    view.addSubview(cardNoField)
    cardNoField.snp.makeConstraints { (make) in
      make.top.equalTo(lastNameField.snp.bottom).offset(padding)
      make.trailing.leading.equalTo(0)
      make.height.equalTo(InlineField.height)
    }
    
    signupButton = ViewFactory.button(withTitle: Config.localizedText(for: "signup_button_text").value, font: .systemFont(ofSize: 18))
    signupButton.backgroundColor = .themeGreen
    signupButton.layer.cornerRadius = 5
    signupButton.layer.masksToBounds = true
    signupButton.setTitleColor(.white, for: .normal)
    view.addSubview(signupButton)
    signupButton.snp.makeConstraints { (make) in
      make.leading.equalTo(37)
      make.trailing.equalTo(-37)
      make.top.equalTo(cardNoField.snp_bottom).offset(2 * padding)
      make.height.equalTo(44)
    }
    
    backButton = ViewFactory.button(withTitle: Config.localizedText(for: "signup_back").value, font: .systemFont(ofSize: 18))
    backButton.backgroundColor = .themeGreen
    backButton.layer.cornerRadius = 5
    backButton.layer.masksToBounds = true
    backButton.setTitleColor(.white, for: .normal)
    view.addSubview(backButton)
    backButton.snp.makeConstraints { (make) in
      make.leading.trailing.height.equalTo(signupButton)
      make.top.equalTo(signupButton.snp.bottom).offset(padding)
    }
    
    loadingView = UIActivityIndicatorView(style: .gray)
    loadingView.hidesWhenStopped = true
    view.addSubview(loadingView)
    loadingView.snp.makeConstraints { (make) in
      make.size.equalTo(CGSize(width: 40, height: 40))
      make.center.equalTo(signupButton.snp.center)
    }
  }
  
  private func bindViewModel() {
    view.rx.tapGesture().do(onNext: { [weak self] _ in
      self?.view.endEditing(true)
    }).subscribe()
      .disposed(by: bag)
    
    let viewModel = SignupViewModel(input: (
      username: usernameField.textField.rx.text.orEmpty.asDriver(),
      password: passwordField.textField.rx.text.orEmpty.asDriver(),
      firstName: firstNameField.textField.rx.text.orEmpty.asDriver(),
      lastName: lastNameField.textField.rx.text.orEmpty.asDriver(),
      cardNo: cardNoField.textField.rx.text.orEmpty.asDriver(),
      signupTaps: signupButton.rx.tap.asSignal()
      ), dependency: (
        api: SigninServiceImplementation.shared,
        validation: ValidationServiceImplementation.shared
    ))
    
    viewModel.signupEnabled.drive(onNext: { [weak self] valid in
      self?.signupButton.isEnabled = valid
      self?.signupButton.alpha = valid ? 1.0 : 0.5
    }).disposed(by: bag)
    
    viewModel.signingUp.drive(loadingView.rx.isAnimating).disposed(by: bag)
    
    viewModel.signedUp.do(onNext: { pair in
      let result = pair.result
      let token = pair.token
      ViewFactory.showAlert(result.message, message: nil, success: result.success, completion: {
        if result.success {
          User.signInfo.signin(withToken: token)
          LBSServiceImpl.shared.startUploadLocation()
          UIApplication.shared.delegate?.window??.rootViewController = LauncherViewController()
        }
      })
    }).drive(onNext: { signedUp in
      print("User signed up \(signedUp)")
    }).disposed(by: bag)
    
    backButton.rx.tap.subscribe(onNext: {
      self.dismiss(animated: true, completion: nil)
    }).disposed(by: bag)
  }
}
