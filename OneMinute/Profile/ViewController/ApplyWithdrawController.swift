//
//  ApplyWithdrawController.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ApplyWithdrawController : UIViewController {
  private var tableView: UITableView!
  private var amountLabel: UILabel!
  private var submitButton: UIButton!
  
  private var amountField: UITextField!
  private var withdrawAllButton: UIButton!
  private var accountTypeField: UITextField!
  private var accountTypePicker: UIPickerView!
  private var cardNumberField: UITextField!
  
  private let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "提现"
    initSubviews()
    bindViewModel()
  }
  
  private func initSubviews() {
    tableView = UITableView(frame: view.bounds)
    tableView.isScrollEnabled = false
    tableView.dataSource = self
    tableView.delegate = self
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    initHeaderView()
    initFooterView()
    
    view.rx.tapGesture().subscribe(onNext: { [weak self] _ in
      self?.view.endEditing(true)
    }).disposed(by: bag)
  }
  
  private func initHeaderView() {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 123))
    headerView.backgroundColor = .separateLine
    tableView.tableHeaderView = headerView
    
    let topLine = ViewFactory.separateLine()
    headerView.addSubview(topLine)
    topLine.snp.makeConstraints { (make) in
      make.top.leading.trailing.equalTo(0)
      make.height.equalTo(8)
    }
    
    let bottomLine = ViewFactory.separateLine()
    headerView.addSubview(bottomLine)
    bottomLine.snp.makeConstraints { (make) in
      make.bottom.leading.trailing.equalTo(0)
      make.height.equalTo(8)
    }
    
    let contentView = UIView()
    contentView.backgroundColor = .white
    headerView.addSubview(contentView)
    contentView.snp.makeConstraints { (make) in
      make.top.equalTo(topLine.snp.bottom)
      make.bottom.equalTo(bottomLine.snp.top)
      make.leading.trailing.equalTo(0)
    }
    
    let tipLabel = ViewFactory.label(withText: "可提现收益", font: .systemFont(ofSize: 12))
    contentView.addSubview(tipLabel)
    tipLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(contentView)
      make.top.equalTo(31)
    }
    
    amountLabel = ViewFactory.label(withText: "00.00", font: .boldSystemFont(ofSize: 24.0))
    contentView.addSubview(amountLabel)
    amountLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(contentView).offset(8)
      make.top.equalTo(tipLabel.snp.bottom).offset(12)
    }
    
    let dollarLabel = ViewFactory.label(withText: "$", font: .systemFont(ofSize: 20))
    contentView.addSubview(dollarLabel)
    dollarLabel.snp.makeConstraints { (make) in
      make.trailing.equalTo(amountLabel.snp.leading).offset(-2)
      make.bottom.equalTo(amountLabel)
    }
  }
  
  private func initFooterView() {
    let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 72))
    footerView.backgroundColor = .white
    tableView.tableFooterView = footerView
    
    submitButton = ViewFactory.button(withTitle: "申请提现", font: .boldSystemFont(ofSize: 16))
    submitButton.backgroundColor = .themeGreen
    submitButton.setTitleColor(.white, for: .normal)
    submitButton.layer.cornerRadius = 5
    submitButton.layer.masksToBounds = true
    footerView.addSubview(submitButton)
    submitButton.snp.makeConstraints { (make) in
      make.top.leading.equalTo(16)
      make.trailing.equalTo(-16)
      make.height.equalTo(44)
    }
    
    let tipLabel = ViewFactory.label(withText: "申请后的三个工作日内完成提现", font: .systemFont(ofSize: 12))
    tipLabel.textColor = .secondaryTextColor
    footerView.addSubview(tipLabel)
    tipLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(footerView)
      make.top.equalTo(submitButton.snp.bottom).offset(16)
    }
  }
  
  private func bindViewModel() {
    User.current.map { "\(String(format: "%.2f", $0.withdraw))" }.bind(to: amountLabel.rx.text).disposed(by: bag)
  }
}

extension ApplyWithdrawController : UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
    cell.selectionStyle = .none
    cell.textLabel?.font = .boldSystemFont(ofSize: 15)
    
    switch indexPath.row {
    case 0:
      cell.textLabel?.text = "提现金额"
      
      amountField = UITextField(frame: CGRect(x: 94, y: 0, width: UIScreen.main.bounds.width - 94 - 96, height: 50))
      amountField.placeholder = "请输入提现金额"
      amountField.font = .systemFont(ofSize: 15)
      amountField.keyboardType = .numberPad
      cell.contentView.addSubview(amountField)
      
      withdrawAllButton = ViewFactory.button(withTitle: "全部提现", font: .boldSystemFont(ofSize: 15))
      withdrawAllButton.sizeToFit()
      withdrawAllButton.frame.origin = CGPoint(x: UIScreen.main.bounds.width - 16 - withdrawAllButton.bounds.width, y: 25 - withdrawAllButton.bounds.height / 2)
      withdrawAllButton.setTitleColor(.themeGreen, for: .normal)
      cell.contentView.addSubview(withdrawAllButton)
      
      break
    case 1:
      cell.textLabel?.text = "提现账户"
      
      accountTypeField = UITextField(frame: CGRect(x: 94, y: 0, width: UIScreen.main.bounds.width - 94 - 16, height: 50))
      accountTypeField.font = .boldSystemFont(ofSize: 15)
      accountTypeField.delegate = self
      cell.contentView.addSubview(accountTypeField)
      
      accountTypePicker = UIPickerView()
      accountTypePicker.delegate = self
      accountTypePicker.dataSource = self
      accountTypeField.inputView = accountTypePicker
      pickerView(accountTypePicker, didSelectRow: 0, inComponent: 0)
    case 2:
      cell.textLabel?.text = "卡号/账户"
      
      cardNumberField = UITextField(frame: CGRect(x: 94, y: 0, width: UIScreen.main.bounds.width - 94 - 16, height: 50))
      cardNumberField.placeholder = "请输入卡号/账户号"
      cell.contentView.addSubview(cardNumberField)
    default:
      break
    }
    
    return cell
  }
}

extension ApplyWithdrawController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}

extension ApplyWithdrawController : UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 1
  }
}

extension ApplyWithdrawController : UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return "PAYPAL"
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    accountTypeField.text = "PAYPAL"
  }
}

extension ApplyWithdrawController : UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return false
  }
}
