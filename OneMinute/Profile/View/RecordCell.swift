//
//  RecordCell.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

class RecordCell : UITableViewCell {
  private var titleLabel: UILabel!
  private var idLabel: UILabel!
  private var amountLabel: UILabel!
  private var timeLabel: UILabel!
  
  var record: Record? {
    didSet {
      setNeedsLayout()
    }
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    initSubviews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initSubviews() {
    titleLabel = ViewFactory.label(withText: "", font: .boldSystemFont(ofSize: 15))
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) in
      make.leading.equalTo(15)
      make.top.equalTo(21)
    }
    
    idLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 12))
    idLabel.textColor = .omTextGray
    contentView.addSubview(idLabel)
    idLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
      make.leading.equalTo(titleLabel)
    }
    
    amountLabel = ViewFactory.label(withText: "", font: .boldSystemFont(ofSize: 15))
    contentView.addSubview(amountLabel)
    amountLabel.snp.makeConstraints { (make) in
      make.trailing.equalTo(-15)
      make.top.equalTo(titleLabel)
    }
    
    timeLabel = ViewFactory.label(withText: "", font: .systemFont(ofSize: 12))
    contentView.addSubview(timeLabel)
    timeLabel.snp.makeConstraints { (make) in
      make.trailing.equalTo(amountLabel)
      make.top.equalTo(idLabel)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    guard let record = self.record else { return }
    
    titleLabel.text = "\(record.type.description)" + (record.remark.count > 0 ? " * \(record.remark)" : "")
    idLabel.text = record.orderID
    amountLabel.text = "+$\(String(format: "%.2f", record.amount))"
    timeLabel.text = record.time
  }
}
