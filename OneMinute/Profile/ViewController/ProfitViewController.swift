//
//  ProfitViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfitViewController : UIViewController {
  private var tableView: UITableView!
  private let bag = DisposeBag()
  
  private static let cellID = "ProfitCellID"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "我的收益"
    
    initSubviews()
  }
  
  private func initSubviews() {
    tableView = UITableView()
    tableView.tableFooterView = UIView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: ProfitViewController.cellID)
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
  }
}
