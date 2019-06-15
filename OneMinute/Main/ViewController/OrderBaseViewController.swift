//
//  OrderBaseViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/9.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import RxSwift
import RxCocoa

class OrderBaseViewController : BaseViewController {
  var tableView: UITableView!
  var loadingView: UIActivityIndicatorView!
  var refreshControl: UIRefreshControl!
  
  static let cellID = "orderCell"
  
  let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initSubviews()
    bindViewModel()
  }
  
  func initSubviews() {
    tableView = UITableView()
    tableView.separatorStyle = .none
    tableView.backgroundColor = .separateLine
    tableView.register(OrderCell.self, forCellReuseIdentifier: OrderBaseViewController.cellID)
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40));
    footerView.backgroundColor = .separateLine
    tableView.tableFooterView = footerView
    
    loadingView = UIActivityIndicatorView(style: .gray)
    loadingView.hidesWhenStopped = true
    footerView.addSubview(loadingView)
    loadingView.snp.makeConstraints { (make) in
      make.width.height.equalTo(40)
      make.center.equalTo(footerView)
    }
    
    refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = .separateLine
    refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新", attributes: [.foregroundColor: UIColor.black])
    tableView.addSubview(refreshControl)
  }
  
  func bindViewModel() {}
}
