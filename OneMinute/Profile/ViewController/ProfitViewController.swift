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
  private var headerView: ProfitHeaderView!
  private var settings: [SettingItem]!
  
  private let bag = DisposeBag()
  
  private static let cellID = "ProfitCellID"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "我的收益"
    
    initSubviews()
    bindViewModel()
  }
  
  private func initSubviews() {
    tableView = UITableView(frame: view.bounds)
    tableView.tableFooterView = UIView()
    tableView.separatorStyle = .none
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: ProfitViewController.cellID)
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    headerView = ProfitHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150))
    tableView.tableHeaderView = headerView
  }
  
  private func bindViewModel() {
    settings = [
      SettingItem(iconName: "withdraw", title: "申请提现"),
      SettingItem(iconName: "records", title: "明细记录")
    ]
    
    Driver.just(settings).drive(tableView.rx.items(cellIdentifier: ProfitViewController.cellID, cellType: UITableViewCell.self)) { (row, element, cell) in
      cell.textLabel?.text = element.title
      cell.imageView?.image = UIImage(named: element.iconName)
      cell.accessoryView = UIImageView(image: UIImage(named: "right_arrow"))
    }.disposed(by: bag)
    
    tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
      guard let self = self else { return }
      self.tableView.deselectRow(at: indexPath, animated: true)
      
      switch indexPath.row {
      case 0:
        // Apply withdraw
        self.navigationController?.pushViewController(ApplyWithdrawController(), animated: true)
      case 1:
        // Records
        self.navigationController?.pushViewController(RecordsViewController(), animated: true)
      default:
        return
      }
    }).disposed(by: bag)
    
    tableView.rx.setDelegate(self).disposed(by: bag)
    
    User.current.map { "\(String(format: "%.2f", $0.withdraw))" }.bind(to: headerView.withdrawLabel.rx.text).disposed(by: bag)
    User.current.map { "\(String(format: "%.2f", $0.dailyProfit))" }.bind(to: headerView.profitLabel.rx.text).disposed(by: bag)
  }
}

extension ProfitViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
