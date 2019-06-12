//
//  RecordsViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RecordsViewController : UIViewController {
  private var tableView: UITableView!
  
  private static let cellID = "RecordsCellID"
  
  private let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "明细记录"
    initSubviews()
  }
  
  private func initSubviews() {
    tableView = UITableView()
    tableView.isScrollEnabled = false
    tableView.tableFooterView = UIView()
    tableView.register(RecordCell.self, forCellReuseIdentifier: RecordsViewController.cellID)
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
  }
  
  private func bindViewModel() {
    
  }
}

