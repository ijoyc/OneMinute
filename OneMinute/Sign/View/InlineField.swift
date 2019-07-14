//
//  InlineField.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/7/14.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class InlineField : UIView {
  static let height = 44
  
  private let title: BehaviorRelay<String>
  private let placeholder: BehaviorRelay<String>
  
  public let textField = UITextField()
  
  private let nameLabel = UILabel()
  
  private let bag = DisposeBag()
  
  init(title: BehaviorRelay<String>, placeholder: BehaviorRelay<String>) {
    self.title = title
    self.placeholder = placeholder
    super.init(frame: .zero)
    
    self.initSubviews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initSubviews() {
    title.bind(to: nameLabel.rx.text).disposed(by: bag)
    nameLabel.font = .systemFont(ofSize: 16.0)
    addSubview(nameLabel)
    nameLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.leading.equalTo(12)
      make.width.equalTo(78)
    }
    
    placeholder.bind(to: textField.rx.placeholder).disposed(by: bag)
    addSubview(textField)
    textField.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.leading.equalTo(nameLabel.snp.trailing).offset(8)
      make.trailing.equalTo(-12)
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
  }
}
