//
//  GrabViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/6.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GrabViewController : UIViewController {
  private var tableView: UITableView!
  private var loadingView: UIActivityIndicatorView!
  private var refreshControl: UIRefreshControl!
  private var viewModel: GrabViewModel?
  
  private let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initSubviews()
    bindViewModel()
  }
  
  func initSubviews() {
    tableView = UITableView()
    tableView.separatorStyle = .none
    tableView.backgroundColor = .separateLine
    tableView.register(OrderCell.self, forCellReuseIdentifier: "GrabOrderCell")
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40));
    footerView.backgroundColor = .separateLine
    tableView.tableFooterView = footerView
    
    loadingView = UIActivityIndicatorView(style: .gray)
    loadingView.hidesWhenStopped = true
    footerView .addSubview(loadingView)
    loadingView.snp.makeConstraints { (make) in
      make.width.height.equalTo(40)
      make.center.equalTo(footerView)
    }
    
    refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = .separateLine
    refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新", attributes: [.foregroundColor: UIColor.black])
    tableView.addSubview(refreshControl)
  }
  
  func bindViewModel() {
    let tableView: UITableView = self.tableView
    let loadMoreTrigger = tableView.rx.contentOffset
      .asDriver()
      .distinctUntilChanged()
      .filter({ _ in tableView.isNearBottomEdge() }).map { _ in true }
    let refreshTrigger = refreshControl.rx
      .controlEvent(.valueChanged)
      .asSignal()
      .map { _ in false }
    
    let trigger = Signal.merge(loadMoreTrigger.asSignal(onErrorJustReturn: false), refreshTrigger)
    
    viewModel = GrabViewModel(loadTrigger: trigger, api: GrabAPIImplementation.shared)
    
    viewModel?.loading.drive(loadingView.rx.isAnimating).disposed(by: bag)
    
    viewModel?.cellModels
      .skip(1)
      .do(onNext: { [weak self] _ in
        self?.refreshControl.endRefreshing()
      })
      .bind(to: tableView.rx.items(cellIdentifier: "GrabOrderCell", cellType: OrderCell.self)) { (row, element, cell) in
        cell.cellModel = element
      }.disposed(by: bag)
    
    tableView.rx.modelSelected(OrderCellModel.self).subscribe(onNext: { (value) in
      print("clicked \(value)")
    }).disposed(by: bag)
    
    tableView.rx.setDelegate(self).disposed(by: bag)
  }
}

extension GrabViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let cellModel = viewModel?.cellModels.value[indexPath.row]
    return cellModel?.cellHeight ?? 0
  }
}
