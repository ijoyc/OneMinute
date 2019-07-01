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
  private var grabingView: UIActivityIndicatorView!
  
  override func initSubviews() {
    super.initSubviews()
    
    grabingView = UIActivityIndicatorView(style: .gray)
    view.addSubview(grabingView)
    grabingView.snp.makeConstraints { (make) in
      make.width.height.equalTo(40)
      make.center.equalTo(self.view)
    }
  }
  
  override func bindViewModel() {
    tableView.rx.modelSelected(OrderCellModel.self).subscribe(onNext: { (value) in
      print("clicked \(value)")
    }).disposed(by: bag)
    
    tableView.rx.setDelegate(self).disposed(by: bag)
    
    LBSServiceImpl.shared.uploadSuccess.filter { $0 }.take(1).subscribe(onNext: { _ in
      self.bindGrabViewModel()
    }).disposed(by: bag)
  }
  
  func bindGrabViewModel() {
    let grabTrigger = PublishSubject<Int>()
    let automaticRefresh = PublishSubject<Void>()
    let tableView: UITableView = self.tableView
    
    let loadMoreTrigger = tableView.rx.contentOffset
      .asDriver()
      .distinctUntilChanged()
      .filter({ _ in tableView.isNearBottomEdge() }).map { _ in true }
    let refreshTrigger = Signal.merge(
      refreshControl.rx.controlEvent(.valueChanged).asSignal(),
      automaticRefresh.asSignal(onErrorJustReturn: ()))
      .map { _ in false }
    
    let loadTrigger = Signal.merge(loadMoreTrigger.asSignal(onErrorJustReturn: false), refreshTrigger)
    
    viewModel = GrabViewModel(input: (loadTrigger: loadTrigger,
                                      grabTrigger: grabTrigger.asSignal(onErrorJustReturn: -1)),
                              api: GrabAPIImplementation.shared)
    viewModel?.loading
      .drive(loadingView.rx.isAnimating)
      .disposed(by: bag)
    viewModel?.grabing
      .drive(grabingView.rx.isAnimating)
      .disposed(by: bag)
    
    viewModel?.cellModels
      .skip(1)
      .do(onNext: { [weak self] _ in
        self?.refreshControl.endRefreshing()
      })
      .bind(to: tableView.rx.items(cellIdentifier: OrderBaseViewController.cellID, cellType: OrderCell.self)) { [weak self] (row, element, cell) in
        guard let self = self else { return }
        
        cell.cellModel = element
        cell.rx.grabOrder.subscribe(onNext: {
          grabTrigger.onNext(element.model.id)
        }).disposed(by: self.bag)
      }.disposed(by: bag)
    
    viewModel?.grabResult.drive(onNext: { result in
      ViewFactory.showAlert(result.message, success: result.success)
      if result.success {
        automaticRefresh.onNext(())
      }
    }).disposed(by: bag)
  }
}

extension GrabViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let cellModel = viewModel?.cellModels.value[indexPath.row]
    return cellModel?.cellHeight ?? 0
  }
}
