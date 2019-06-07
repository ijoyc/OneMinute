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
  
  private let bag = DisposeBag()
  private let viewModel = GrabViewModel(api: GrabAPIImplementation.shared)
  
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
    tableView.tableFooterView = UIView()
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
  }
  
  func bindViewModel() {
    viewModel.cellModels.bind(to: tableView.rx.items(cellIdentifier: "GrabOrderCell", cellType: OrderCell.self)) { (row, element, cell) in
        cell.cellModel = element
    }.disposed(by: bag)
    
    tableView.rx.modelSelected(OrderCellModel.self).subscribe(onNext: { (value) in
      print("Tapped \(value)")
    }).disposed(by: bag)
    
    tableView.rx.setDelegate(self).disposed(by: bag)
  }
}

extension GrabViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let cellModel = viewModel.cellModels.value[indexPath.row]
    return cellModel.cellHeight
  }
}
