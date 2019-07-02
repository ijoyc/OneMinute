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
  
  private var viewModel: ProfileViewModel?
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
      SettingItem(iconName: "wallet", title: Config.localizedText(for: "setting_profit")),
      SettingItem(iconName: "change", title: Config.localizedText(for: "setting_language")),
      SettingItem(iconName: "question", title: Config.localizedText(for: "setting_rule")),
      SettingItem(iconName: "about", title: Config.localizedText(for: "setting_about")),
      SettingItem(iconName: "shutdown", title: Config.localizedText(for: "setting_signout"))
    ]
    
    Driver.just(settings).drive(tableView.rx.items(cellIdentifier: ProfileViewController.cellID, cellType: UITableViewCell.self)) { (row, element, cell) in
      element.title.bind(to: cell.textLabel!.rx.text).disposed(by: self.bag)
      cell.imageView?.image = UIImage(named: element.iconName)
      cell.accessoryView = UIImageView(image: UIImage(named: "right_arrow"))
    }.disposed(by: bag)
    
    tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
      guard let self = self else { return }
      self.tableView.deselectRow(at: indexPath, animated: true)
      
      switch indexPath.row {
      case 0:
        // My Profits
        let vc = ProfitViewController(viewModel: self.viewModel)
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
    
    viewModel.currentUser.asDriver().drive(onNext: { user in
      guard let user = user else { return }
      User.current.accept(user)
      User.reportAlias()
    }).disposed(by: bag)
    
    viewModel.currentUser.asDriver().map { $0?.avatar }.drive(onNext: { [weak self] urlString in
      guard let self = self, let urlString = urlString else { return }
      
      self.headerView.profileView.rx.setImage(with: urlString).disposed(by: self.bag)
    }).disposed(by: bag)
    
    viewModel.currentUser.asDriver().filter { $0 != nil }.map { "\($0!.firstName) \($0!.lastName)" }.drive(headerView.nameLabel.rx.text).disposed(by: bag)
    viewModel.currentUser
      .asDriver()
      .filter { $0 != nil }
      .withLatestFrom(Config.localizedText(for: "user_order_unit").asDriver()) { ($0, $1) }
      .map { "\($0.0!.completeOrderNum) \($0.1)" }
      .drive(headerView.ordersLabel.rx.text)
      .disposed(by: bag)
    
    viewModel.loading.drive(loadingView.rx.isAnimating).disposed(by: bag)
    
    viewModel.signedOut.drive(onNext: { success in
      guard success == true else { return }
      
      // Sign out
      User.signout()
      self.present(SigninViewController(), animated: true, completion: nil)
    }).disposed(by: bag)
    
    self.viewModel = viewModel
  }
}

extension ProfileViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
