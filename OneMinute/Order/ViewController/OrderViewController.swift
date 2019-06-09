//
//  OrderViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/6.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OrderViewController : OrderBaseViewController {
  private var categoryView: CategoryView!
  private var refreshLoadingView: UIActivityIndicatorView!
  private var viewModel: OrderViewModel?
  
  override func initSubviews() {
    super.initSubviews()
    
    categoryView = CategoryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45), categories: ["全部", "进行中", "已完成", "已取消"])
    tableView.tableHeaderView = categoryView
    
    refreshLoadingView = UIActivityIndicatorView(style: .gray)
    refreshLoadingView.hidesWhenStopped = true
    refreshLoadingView.color = .red
    view.addSubview(refreshLoadingView)
    refreshLoadingView.snp.makeConstraints { (make) in
      make.center.equalTo(self.view)
    }
  }
  
  override func bindViewModel() {
    let tableView: UITableView = self.tableView
    let loadMoreTrigger = tableView.rx.contentOffset
      .asDriver()
      .distinctUntilChanged()
      .filter({ _ in tableView.isNearBottomEdge() }).map { _ in true }
    let refreshTrigger = refreshControl.rx
      .controlEvent(.valueChanged)
      .asSignal()
      .map { _ in false }
    let categoryTrigger = categoryView.selectedIndex.asSignal(onErrorJustReturn: 0)
    
    let loadTrigger = Signal.merge(loadMoreTrigger.asSignal(onErrorJustReturn: false), refreshTrigger)
    
    viewModel = OrderViewModel(input: (loadTrigger: loadTrigger, categoryTrigger: categoryTrigger), api: OrderAPIImplementation.shared)
    
    viewModel?.loading.drive(loadingView.rx.isAnimating).disposed(by: bag)
    viewModel?.refreshing.drive(refreshLoadingView.rx.isAnimating).disposed(by: bag)
    viewModel?.refreshing.map { !$0 }.drive(view.rx.isUserInteractionEnabled).disposed(by: bag)
    
    viewModel?.cellModels
      .skip(1)
      .do(onNext: { [weak self] _ in
        self?.refreshControl.endRefreshing()
      })
      .bind(to: tableView.rx.items(cellIdentifier: OrderBaseViewController.cellID, cellType: OrderCell.self)) { (row, element, cell) in
        cell.cellModel = element
      }.disposed(by: bag)
    
    tableView.rx.modelSelected(OrderCellModel.self).subscribe(onNext: { (value) in
      print("clicked \(value)")
    }).disposed(by: bag)
    
    tableView.rx.setDelegate(self).disposed(by: bag)
  }
}

extension OrderViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let cellModel = viewModel?.cellModels.value[indexPath.row]
    return cellModel?.cellHeight ?? 0
  }
}

