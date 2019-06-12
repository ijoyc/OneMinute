//
//  LanguageViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LanguageViewController : UIViewController {
  private var tableView: UITableView!
  private let bag = DisposeBag()
  
  private static let cellID = "LanguageCellID"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "切换中英文"
    
    initSubviews()
    bindViewModels()
  }
  
  private func initSubviews() {
    tableView = UITableView()
    tableView.tableFooterView = UIView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: LanguageViewController.cellID)
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
  }
  
  private func bindViewModels() {
    Driver.just(["中文", "English"]).drive(tableView.rx.items(cellIdentifier: LanguageViewController.cellID, cellType: UITableViewCell.self)) { (row, element, cell) in
      cell.textLabel?.text = element
      cell.accessoryView = UISwitch()
      cell.selectionStyle = .none
      }.disposed(by: bag)
  }
}
