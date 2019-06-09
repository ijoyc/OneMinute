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

class GrabViewController : OrderBaseViewController {
  private var viewModel: GrabViewModel?
  
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
    
    let trigger = Signal.merge(loadMoreTrigger.asSignal(onErrorJustReturn: false), refreshTrigger)
    
    viewModel = GrabViewModel(loadTrigger: trigger, api: GrabAPIImplementation.shared)
    
    viewModel?.loading.drive(loadingView.rx.isAnimating).disposed(by: bag)
    
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

extension GrabViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let cellModel = viewModel?.cellModels.value[indexPath.row]
    return cellModel?.cellHeight ?? 0
  }
}
