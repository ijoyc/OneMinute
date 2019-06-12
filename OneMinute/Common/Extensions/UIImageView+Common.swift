//
//  UIImageView+Common.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/12.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIImageView {
  func setImage(with urlString: String) -> Disposable {
    guard let url = URL(string: urlString) else { return Disposables.create() }
    let request = URLRequest(url: url)
    return URLSession.shared.rx
      .data(request: request)
      .map { UIImage(data: $0) }
      .asDriver(onErrorJustReturn: nil)
      .drive(image)
  }
}
