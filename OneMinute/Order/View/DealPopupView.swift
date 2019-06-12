//
//  DealPopupView.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/11.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class DealPopupView : UIView {
  
  private static let shared = DealPopupView(frame: .zero)
  fileprivate var submitButton: UIButton!
  private let bag = DisposeBag()
  private var inputViews: [UITextField] = []
  
  private static let confirmCodeLength = 4
  private var currentCodeLength = 0
  
  class func show(on view: UIView) {
    dismiss()
    
    view.addSubview(shared)
    shared.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
  }
  
  class func dismiss() {
    if let _ = shared.superview {
      shared.removeFromSuperview()
    }
  }
  
  private override init(frame: CGRect) {
    super.init(frame: frame)
    initSubviews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initSubviews() {
    backgroundColor = .RGBA(0, 0, 0, 0.6)
    
    let contentView = UIView()
    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = true
    addSubview(contentView)
    contentView.snp.makeConstraints { (make) in
      make.center.equalTo(self)
      make.size.equalTo(CGSize(width: 280, height: 261))
    }
    
    let closeBackground = UIView()
    closeBackground.backgroundColor = .RGBA(233, 234, 236, 1)
    closeBackground.layer.cornerRadius = 36
    closeBackground.layer.masksToBounds = true
    contentView.addSubview(closeBackground)
    closeBackground.snp.makeConstraints { (make) in
      make.top.equalTo(-36)
      make.trailing.equalTo(36)
      make.width.height.equalTo(72)
    }
    
    let closeButton = ViewFactory.button(withTitle: "")
    closeButton.setImage(UIImage(named: "close"), for: .normal)
    contentView.addSubview(closeButton)
    closeButton.snp.makeConstraints { (make) in
      make.width.height.equalTo(36)
      make.top.equalTo(-5)
      make.trailing.equalTo(5)
    }
    closeButton.rx.tap.subscribe(onNext: {
      DealPopupView.dismiss()
    }).disposed(by: bag)
    
    let titleLabel = ViewFactory.label(withText: "订单完成", font: .boldSystemFont(ofSize: 16))
    titleLabel.textAlignment = .center
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.top.leading.trailing.equalTo(0)
      make.height.equalTo(55)
    }
    
    let bottomLine = ViewFactory.separateLine()
    contentView.addSubview(bottomLine)
    bottomLine.snp.makeConstraints { (make) in
      make.leading.trailing.equalTo(0)
      make.height.equalTo(1)
      make.top.equalTo(titleLabel.snp.bottom)
    }
    
    let tipLabel = ViewFactory.label(withText: "请向对方索要确认码,正确输入后完成订单", font: .systemFont(ofSize: 11))
    tipLabel.textColor = .secondaryTextColor
    tipLabel.textAlignment = .center
    contentView.addSubview(tipLabel)
    tipLabel.snp.makeConstraints { (make) in
      make.top.equalTo(bottomLine.snp.bottom)
      make.leading.trailing.equalTo(0)
      make.height.equalTo(51)
    }
    
    var lastView: UITextField?
    for _ in 0 ..< DealPopupView.confirmCodeLength {
      let inputView = UITextField()
      inputView.layer.borderColor = UIColor.separateLine.cgColor
      inputView.layer.borderWidth = 1.0
      inputView.layer.cornerRadius = 10
      inputView.layer.masksToBounds = true
      inputView.keyboardType = .numberPad
      inputView.tintColor = .clear
      inputView.font = .boldSystemFont(ofSize: 24)
      inputView.textAlignment = .center
      inputView.delegate = self
      inputViews.append(inputView)
      contentView.addSubview(inputView)
      inputView.snp.makeConstraints { (make) in
        make.width.height.equalTo(55)
        make.top.equalTo(tipLabel.snp.bottom)
        if let lastView = lastView {
          make.leading.equalTo(lastView.snp.trailing).offset(10)
        } else {
          make.leading.equalTo(contentView).offset(15)
        }
      }
      lastView = inputView
    }
    
    submitButton = ViewFactory.button(withTitle: "提交", font: .boldSystemFont(ofSize: 17))
    submitButton.backgroundColor = .themeGreen
    submitButton.setTitleColor(.white, for: .normal)
    submitButton.layer.cornerRadius = 4
    submitButton.layer.masksToBounds = true
    contentView.addSubview(submitButton)
    submitButton.snp.makeConstraints { (make) in
      make.leading.equalTo(15)
      make.trailing.equalTo(-15)
      make.top.equalTo(lastView?.snp.bottom ?? 0).offset(25)
      make.bottom.equalTo(-26)
    }
  }
}

// MARK: - UITextFieldDelegate

extension DealPopupView : UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if (textField.text as NSString? ?? "").replacingCharacters(in: range, with: string).count < 2 {
      if string.count == 0 {
        inputViews[currentCodeLength].text = ""
        currentCodeLength = max(0, currentCodeLength - 1)
        inputViews[currentCodeLength].becomeFirstResponder()
      } else {
        inputViews[currentCodeLength].text = string
      }
    } else {
      let index = inputViews.firstIndex(of: textField) ?? 0
      
      if index < inputViews.count - 1 {
        currentCodeLength = index + 1
        inputViews[currentCodeLength].becomeFirstResponder()
        inputViews[currentCodeLength].text = string
      }
    }
    
    return false
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    let index = inputViews.firstIndex(of: textField)
    return index == currentCodeLength
  }
  
  
}
