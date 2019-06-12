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
  struct LanguageOption {
    let title: String
    let language: Language
  }
  
  private var tableView: UITableView!
  private let bag = DisposeBag()
  
  private var options: [LanguageOption] = []
  private var buttons: [UIButton] = []
  
  private static let cellID = "LanguageCellID"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "切换中英文"
    
    options.append(LanguageOption(title: "中文", language: .Chinese))
    options.append(LanguageOption(title: "English", language: .English))
    
    initSubviews()
    bindViewModels()
  }
  
  private func initSubviews() {
    tableView = UITableView()
    tableView.tableFooterView = UIView()
    tableView.isScrollEnabled = false
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: LanguageViewController.cellID)
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
  }
  
  private func bindViewModels() {
    let initialLanguage = Config.language
    let initialSelectedIndex = options.firstIndex { (option) -> Bool in
      option.language == initialLanguage
    }
    
    Driver.just(options)
      .map { $0.map { $0.title } }
      .drive(tableView.rx.items(cellIdentifier: LanguageViewController.cellID, cellType: UITableViewCell.self)) { (row, element, cell) in
        cell.textLabel?.text = element
        cell.selectionStyle = .none
        
        let switchButton = UIButton(type: .custom)
        switchButton.setImage(UIImage(named: "option"), for: .normal)
        switchButton.setImage(UIImage(named: "option_selected"), for: .selected)
        cell.contentView.addSubview(switchButton)
        if row == initialSelectedIndex {
          switchButton.isSelected = true
        }
        
        self.buttons.append(switchButton)
        
        switchButton.snp.makeConstraints({ (make) in
          make.width.height.equalTo(24)
          make.right.equalTo(-16)
          make.centerY.equalTo(cell.contentView)
        })
        switchButton.rx.tap.subscribe(onNext: { [weak self] in
          self?.toggleLanguage(row)
        }).disposed(by: self.bag)
    }.disposed(by: bag)
    
    tableView.rx.itemSelected.subscribe(onNext: { indexPath in
      self.toggleLanguage(indexPath.row)
    }).disposed(by: bag)
    
    tableView.rx.setDelegate(self).disposed(by: bag)
  }
  
  private func toggleLanguage(_ index: Int) {
    for button in self.buttons {
      button.isSelected = false
    }
    
    buttons[index].isSelected = true
    Config.language = options[index].language
    // TODO: toggle language
  }
}

extension LanguageViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
