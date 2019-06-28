//
//  RuleViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//


import UIKit

class RuleViewController : BaseViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = Config.localizedText(for: "setting_rule")
    view.backgroundColor = .white
  }
}
