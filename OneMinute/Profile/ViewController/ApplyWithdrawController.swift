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
  
  private let amountField = UITextField()
  private let withdrawAllButton = ViewFactory.button(withTitle: "", font: .boldSystemFont(ofSize: 15))
  private var accountTypeField: UITextField!
  private let accountTypePicker = UIPickerView()
  private let cardNumberField = UITextField()
  private var loadingView: UIActivityIndicatorView!
  
  private var profileViewModel: ProfileViewModel?
  private var viewModel: ApplyWithdrawViewModel!
  private let available = BehaviorRelay<String>(value: "")
  private let bag = DisposeBag()
  
  init(viewModel: ProfileViewModel?) {
    self.profileViewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    Config.localizedText(for: "profit_withdraw_title").bind(to: rx.title).disposed(by: bag)
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
    
    let tipLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 12))
    Config.localizedText(for: "user_withdrawable").bind(to: tipLabel.rx.text).disposed(by: bag)
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
    
    submitButton = ViewFactory.button(withTitle: "", font: .boldSystemFont(ofSize: 16))
    Config.localizedText(for: "profit_apply").bind(to: submitButton.rx.title(for: .normal)).disposed(by: bag)
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
    
    loadingView = UIActivityIndicatorView(style: .gray)
    loadingView.hidesWhenStopped = true
    view.addSubview(loadingView)
    loadingView.snp.makeConstraints { (make) in
      make.size.equalTo(CGSize(width: 40, height: 40))
      make.center.equalTo(submitButton.snp.center)
    }
    
    let tipLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 12))
    Config.localizedText(for: "profit_tip").bind(to: tipLabel.rx.text).disposed(by: bag)
    tipLabel.textColor = .secondaryTextColor
    footerView.addSubview(tipLabel)
    tipLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(footerView)
      make.top.equalTo(submitButton.snp.bottom).offset(16)
    }
  }
  
  private func bindViewModel() {
    Config.localizedText(for: "profit_withdraw_all").bind(to: withdrawAllButton.rx.title(for: .normal)).disposed(by: bag)
    
    let withdraw = User.current.map { "\(String(format: "%.2f", $0.withdraw))" }
    withdraw.bind(to: amountLabel.rx.text).disposed(by: bag)
    withdraw.bind(to: available).disposed(by: bag)
    
    Observable.combineLatest(amountField.rx.text, cardNumberField.rx.text) { amount, cardNumber in
      (amount?.count ?? 0) > 0 && (cardNumber?.count ?? 0) > 0
    }.bind(to: submitButton.rx.isEnabled).disposed(by: bag)
    
    withdrawAllButton.rx.tap.subscribe(onNext: { [weak self] in
      self?.amountField.text = self?.available.value
    }).disposed(by: bag)
    
    let amount = amountField.rx.text.map { Double(($0 as NSString?)?.floatValue ?? 0) }.asDriver(onErrorJustReturn: 0.0)
    let account = cardNumberField.rx.text.filter { $0?.count == 0 }.map { $0! }.asDriver(onErrorJustReturn: "")
    let accountType = accountTypePicker.rx.itemSelected.map { (row, component) in 
      WithdrawAccount.allCases[row]
    }.asDriver(onErrorJustReturn: .paypal).startWith(.paypal)
    let withdrawTrigger = PublishSubject<Void>()
    
    viewModel = ApplyWithdrawViewModel(input: (amount: amount, account: account, accountType: accountType, withdrawTrigger: withdrawTrigger.asSignal(onErrorJustReturn: ())), api: ProfileAPIImplementation.shared)
    
    viewModel.loading.drive(loadingView.rx.isAnimating).disposed(by: bag)
    viewModel.result.skip(1).subscribe(onNext: { [weak self] result in
      ViewFactory.showAlert(result.message, success: result.success)
      if result.success {
        self?.profileViewModel?.updateUserInfo()
      }
    }).disposed(by: bag)
    
    submitButton.rx.tap.subscribe(onNext: { [weak self] in
      // check amount
      guard let self = self else { return }
      let available = (self.available.value as NSString).floatValue
      let amount = (self.amountField.text as NSString?)?.floatValue ?? 0
      if amount > available {
        ViewFactory.showAlert(Config.localizedText(for: "alert_insufficient_balance").value, success: false)
        return
      }
      
      withdrawTrigger.onNext(())
    }).disposed(by: bag)
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
      Config.localizedText(for: "profit_amount_text").bind(to: cell.textLabel!.rx.text).disposed(by: bag)
      
      amountField.frame = CGRect(x: 94, y: 0, width: UIScreen.main.bounds.width - 94 - 96, height: 50)
      Config.localizedText(for: "profit_amount_placeholder").bind(to: amountField.rx.placeholder).disposed(by: bag)
      amountField.font = .systemFont(ofSize: 15)
      amountField.keyboardType = .numberPad
      cell.contentView.addSubview(amountField)
      
      withdrawAllButton.sizeToFit()
      withdrawAllButton.frame.origin = CGPoint(x: UIScreen.main.bounds.width - 16 - withdrawAllButton.bounds.width, y: 25 - withdrawAllButton.bounds.height / 2)
      withdrawAllButton.setTitleColor(.themeGreen, for: .normal)
      cell.contentView.addSubview(withdrawAllButton)
      
      break
    case 1:
      Config.localizedText(for: "profit_account_type_text").bind(to: cell.textLabel!.rx.text).disposed(by: bag)
      
      accountTypeField = UITextField(frame: CGRect(x: 94, y: 0, width: UIScreen.main.bounds.width - 94 - 16, height: 50))
      accountTypeField.font = .boldSystemFont(ofSize: 15)
      accountTypeField.delegate = self
      cell.contentView.addSubview(accountTypeField)
      
      accountTypePicker.delegate = self
      accountTypePicker.dataSource = self
      accountTypeField.inputView = accountTypePicker
      pickerView(accountTypePicker, didSelectRow: 0, inComponent: 0)
    case 2:
      Config.localizedText(for: "profit_account_text").bind(to: cell.textLabel!.rx.text).disposed(by: bag)
      
      cardNumberField.frame = CGRect(x: 94, y: 0, width: UIScreen.main.bounds.width - 94 - 16, height: 50)
      Config.localizedText(for: "profit_account_placeholder").bind(to: cardNumberField.rx.placeholder).disposed(by: bag)
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
    return WithdrawAccount.allCases.count
  }
}

extension ApplyWithdrawController : UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return WithdrawAccount.allCases[row].description
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    accountTypeField.text = WithdrawAccount.allCases[row].description
  }
}

extension ApplyWithdrawController : UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return false
  }
}
