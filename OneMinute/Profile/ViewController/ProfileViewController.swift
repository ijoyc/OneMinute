//
//  ProfileViewController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/6.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileViewController : UIViewController {
  private var tableView: UITableView!
  private var headerView: ProfileHeaderView!
  private var settings: [SettingItem]!
  private let bag = DisposeBag()
  
  private static let cellID = "SettingCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initSubviews()
    bindViewModel()
  }
  
  private func initSubviews() {
    tableView = UITableView(frame: view.bounds)
    tableView.separatorStyle = .none
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: ProfileViewController.cellID)
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    headerView = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 125))
    tableView.tableHeaderView = headerView
  }
  
  private func bindViewModel() {
    settings = [
      SettingItem(iconName: "wallet", title: "我的收益"),
      SettingItem(iconName: "change", title: "切换中英文"),
      SettingItem(iconName: "question", title: "员工守则"),
      SettingItem(iconName: "about", title: "关于one minute"),
      SettingItem(iconName: "shutdown", title: "退出登录")
    ]
    
    Driver.just(settings).drive(tableView.rx.items(cellIdentifier: ProfileViewController.cellID, cellType: UITableViewCell.self)) { (row, element, cell) in
      cell.textLabel?.text = element.title
      cell.imageView?.image = UIImage(named: element.iconName)
      cell.accessoryView = UIImageView(image: UIImage(named: "right_arrow"))
    }.disposed(by: bag)
    
    tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
      guard let self = self else { return }
      self.tableView.deselectRow(at: indexPath, animated: true)
      
      switch indexPath.row {
      case 0:
        // My Profits
        self.navigationController?.pushViewController(ProfitViewController(), animated: true)
      case 1:
        // Change Language
        self.navigationController?.pushViewController(LanguageViewController(), animated: true)
      case 2:
        // Rules
        self.navigationController?.pushViewController(RuleViewController(), animated: true)
      case 3:
        // About one minute
        self.navigationController?.pushViewController(AboutViewController(), animated: true)
      case 4:
        // Sign out
        // TODO: sign out
        return
      default:
        return
      }
    }).disposed(by: bag)
    
    tableView.rx.setDelegate(self).disposed(by: bag)
    
    let viewModel = ProfileViewModel(api: ProfileAPIImplementation.shared)
    viewModel.currentUser.drive(onNext: { user in
      User.current.accept(user)
    }).disposed(by: bag)
    
    viewModel.currentUser.map { $0.avatar }.drive(onNext: { [weak self] urlString in
      guard let self = self else { return }
      
      self.headerView.profileView.rx.setImage(with: urlString).disposed(by: self.bag)
    }).disposed(by: bag)
    
    viewModel.currentUser.map { "\($0.firstName) \($0.lastName)" }.drive(headerView.nameLabel.rx.text).disposed(by: bag)
    viewModel.currentUser.map { "\($0.completeOrderNum) 笔" }.drive(headerView.ordersLabel.rx.text).disposed(by: bag)
  }
}

extension ProfileViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
