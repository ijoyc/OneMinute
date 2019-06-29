//
//  AboutViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift

class AboutViewController : BaseViewController {
  private let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    Config.localizedText(for: "about").bind(to: rx.title).disposed(by: bag)
    view.backgroundColor = .white
  }
}
