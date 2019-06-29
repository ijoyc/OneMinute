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

class ProfitViewController : BaseViewController {
  private var tableView: UITableView!
  private var headerView: ProfitHeaderView!
  private var settings: [SettingItem]!
  
  private var profileViewModel: ProfileViewModel?
  private let bag = DisposeBag()
  
  private static let cellID = "ProfitCellID"
  
  init(viewModel: ProfileViewModel?) {
    self.profileViewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    Config.localizedText(for: "setting_profit").bind(to: rx.title).disposed(by: bag)
    
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
      SettingItem(iconName: "withdraw", title: Config.localizedText(for: "profit_apply")),
      SettingItem(iconName: "records", title: Config.localizedText(for: "profit_records"))
    ]
    
    Driver.just(settings).drive(tableView.rx.items(cellIdentifier: ProfitViewController.cellID, cellType: UITableViewCell.self)) { (row, element, cell) in
      if let label = cell.textLabel {
        element.title.bind(to: label.rx.text).disposed(by: self.bag)
      }
      cell.imageView?.image = UIImage(named: element.iconName)
      cell.accessoryView = UIImageView(image: UIImage(named: "right_arrow"))
    }.disposed(by: bag)
    
    tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
      guard let self = self else { return }
      self.tableView.deselectRow(at: indexPath, animated: true)
      
      switch indexPath.row {
      case 0:
        // Apply withdraw
        self.navigationController?.pushViewController(ApplyWithdrawController(viewModel: self.profileViewModel), animated: true)
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
