//
//  OrderCellModel.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/7.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import UIKit

class OrderCellModel {
  
  private(set) var cellHeight: CGFloat = 0
  
  private(set) var mainFrame: CGRect!
  private(set) var topViewFrame: CGRect!
  private(set) var progressViewFrame: CGRect!
  private(set) var progressFrames = [CGRect]()
  private(set) var bottomViewFrame: CGRect?
  
  let model: Order
  
  init(model: Order) {
    self.model = model
    measure()
  }
  
  func measure() {
    var height: CGFloat = 44
    
    mainFrame = CGRect(x: 16, y: 8, width: UIScreen.main.bounds.width - 32, height: 0)
    
    topViewFrame = CGRect(x: 0, y: 0, width: mainFrame.width, height: height)
    
    var top: CGFloat = 0
    let maxWidth = mainFrame.width - 37 - 16
    for progress in model.progresses {
      let titleSize = progress.title.boundingSize(with: maxWidth, font: .boldSystemFont(ofSize: 14))
      let descSize = progress.desc.boundingSize(with: maxWidth, font: .systemFont(ofSize: 12))
      let height = 17 + titleSize.height + 8 + descSize.height + 12
      progressFrames.append(CGRect(x: 0, y: top, width: mainFrame.width, height: height))
      top += height
    }
    
    progressViewFrame = CGRect(x: 0, y: height, width: mainFrame.width, height: top)
    
    height += top
    
    if model.isGrabable {
      bottomViewFrame = CGRect(x: 0, y: height, width: mainFrame.width, height: 49)
      mainFrame.size.height = bottomViewFrame!.maxY
    } else {
      mainFrame.size.height = height
    }
    
    
    cellHeight = mainFrame.maxY + 8
  }
}
