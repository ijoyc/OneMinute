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
  private var loadingView: UIActivityIndicatorView!
  
  private static let cellID = "RecordsCellID"
  
  private let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "明细记录"
    
    initSubviews()
    bindViewModel()
  }
  
  private func initSubviews() {
    tableView = UITableView()
    tableView.register(RecordCell.self, forCellReuseIdentifier: RecordsViewController.cellID)
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40));
    tableView.tableFooterView = footerView
    
    loadingView = UIActivityIndicatorView(style: .gray)
    loadingView.hidesWhenStopped = true
    footerView.addSubview(loadingView)
    loadingView.snp.makeConstraints { (make) in
      make.width.height.equalTo(40)
      make.center.equalTo(footerView)
    }
  }
  
  private func bindViewModel() {
    let tableView: UITableView = self.tableView
    
    let loadTrigger = tableView.rx.contentOffset
      .filter({ _ in tableView.isNearBottomEdge() })
      .distinctUntilChanged()
      .map {_ in ()}
      .asSignal(onErrorJustReturn: ())
    
    let viewModel = RecordsViewModel(loadTrigger: loadTrigger, api: ProfileAPIImplementation.shared)
    viewModel.loading.drive(loadingView.rx.isAnimating).disposed(by: bag)
    
    viewModel.records
      .skip(1)
      .bind(to: tableView.rx.items(cellIdentifier: RecordsViewController.cellID, cellType: RecordCell.self)) { (row, element, cell) in
        cell.selectionStyle = .none
        cell.record = element
      }.disposed(by: bag)
    
    tableView.rx.setDelegate(self).disposed(by: bag)
  }
}

extension RecordsViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72
  }
}

