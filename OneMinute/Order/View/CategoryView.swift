//
//  CategoryView.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/8.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class CategoryView : UIView {
  var selectedIndex = BehaviorRelay<Int>(value: 0)
  
  private let categories: [String]
  private var labels = [UILabel]()
  private var line: UIView!
  
  private let bag = DisposeBag()
  
  init(frame: CGRect, categories: [String]) {
    self.categories = categories
    super.init(frame: frame)
    
    initSubviews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initSubviews() {
    backgroundColor = .white
    
    let itemWidth = bounds.width / CGFloat(categories.count)
    for i in 0 ..< categories.count {
      let label = ViewFactory.label(withText: categories[i], font: UIFont.systemFont(ofSize: 14))
      label.frame = CGRect(x: CGFloat(i) * itemWidth, y: 0, width: itemWidth, height: bounds.height)
      label.textAlignment = .center
      labels.append(label)
      addSubview(label)
    }
    
    line = UIView(frame: CGRect(x: labels[0].center.x - 10, y: bounds.height - 4, width: 20, height: 4))
    line.backgroundColor = .themeGreen
    line.layer.cornerRadius = 2
    line.layer.masksToBounds = true
    addSubview(line)
    
    selectedIndex.subscribe(onNext: { index in
      self.updateUI(with: index)
    }).disposed(by: bag)
    
    rx.tapGesture().asLocation().map { point in
      Int(point.x / (self.bounds.width / CGFloat(self.categories.count)))
    }.bind(to: selectedIndex).disposed(by: bag)
  }
  
  private func updateUI(with selectedIndex: Int) {
    for i in 0 ..< self.labels.count {
      self.labels[i].textColor = i == selectedIndex ? .themeGreen : .black
    }
    UIView.animate(withDuration: 0.2) {
      self.line.center.x = self.labels[selectedIndex].center.x
    }
  }
}
