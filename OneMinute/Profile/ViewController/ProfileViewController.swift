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

class ProfileViewController : BaseViewController {
  private var tableView: UITableView!
  private var headerView: ProfileHeaderView!
  private var loadingView: UIActivityIndicatorView!
  
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
    
    loadingView = UIActivityIndicatorView(style: .whiteLarge)
    loadingView.hidesWhenStopped = true
    view.addSubview(loadingView)
    loadingView.snp.makeConstraints { (make) in
      make.width.height.equalTo(40)
      make.center.equalTo(self.view)
    }
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
        let vc = ProfitViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
      case 1:
        // Change Language
        let vc = LanguageViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
      case 2:
        // Rules
        let vc = RuleViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
      case 3:
        // About one minute
        let vc = AboutViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
      default:
        return
      }
    }).disposed(by: bag)
    
    let signoutTap = tableView.rx.itemSelected.filter { $0.row == 4 }.map { _ in () }.asSignal(onErrorJustReturn: ())
    
    tableView.rx.setDelegate(self).disposed(by: bag)
    
    let viewModel = ProfileViewModel(
      signoutTap: signoutTap,
      dependency: (profileAPI: ProfileAPIImplementation.shared,
                   signinAPI: SigninServiceImplementation.shared))
    
    viewModel.currentUser.drive(onNext: { user in
      User.current.accept(user)
    }).disposed(by: bag)
    
    viewModel.currentUser.map { $0.avatar }.drive(onNext: { [weak self] urlString in
      guard let self = self else { return }
      
      self.headerView.profileView.rx.setImage(with: urlString).disposed(by: self.bag)
    }).disposed(by: bag)
    
    viewModel.currentUser.map { "\($0.firstName) \($0.lastName)" }.drive(headerView.nameLabel.rx.text).disposed(by: bag)
    viewModel.currentUser.map { "\($0.completeOrderNum) 笔" }.drive(headerView.ordersLabel.rx.text).disposed(by: bag)
    
    viewModel.loading.drive(loadingView.rx.isAnimating).disposed(by: bag)
    
    viewModel.signedOut.drive(onNext: { success in
      guard success == true else { return }
      
      // Sign out
      User.signInfo.signout()
      self.present(SigninViewController(), animated: true, completion: nil)
    }).disposed(by: bag)
  }
}

extension ProfileViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
