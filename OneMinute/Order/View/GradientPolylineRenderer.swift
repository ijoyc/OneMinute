//
//  GradientPolylineRenderer.swift
//  OneMinute
//
//  Created by yizhuo.cyz on 2019/6/21.
//  Copyright © 2019 yizhuo.cyz. All rights reserved.
//

import MapKit

class GradientPolylineRenderer: MKPolylineRenderer {
  var startColor: UIColor
  var endColor: UIColor
  
  init(overlay: MKOverlay, startColor: UIColor, endColor: UIColor) {
    self.startColor = startColor
    self.endColor = endColor
    super.init(overlay: overlay)
  }
  
  override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
    let boundingBox = path.boundingBox
    let mapRectCG = rect(for: mapRect)
    
    if !mapRectCG.intersects(boundingBox) {
      return
    }
    
    var sred: CGFloat = 0
    var sgreen: CGFloat = 0
    var sblue: CGFloat = 0
    var ered: CGFloat = 0
    var egreen: CGFloat = 0
    var eblue: CGFloat = 0
    startColor.getRed(&sred, green: &sgreen, blue: &sblue, alpha: nil)
    endColor.getRed(&ered, green: &egreen, blue: &eblue, alpha: nil)
    
    let redStride = (ered - sred) / CGFloat(polyline.pointCount)
    let blueStride = (eblue - sblue) / CGFloat(polyline.pointCount)
    let greenStride = (egreen - sgreen) / CGFloat(polyline.pointCount)
    
    var prevColor: CGColor?
    var currentColor: CGColor?
    
    for i in 0..<polyline.pointCount {
      let point = self.point(for: polyline.points()[i])
      let path = CGMutablePath()
      
      currentColor = UIColor(red: sred + CGFloat(i) * redStride, green: sgreen + CGFloat(i) * greenStride, blue: sblue + CGFloat(i) * blueStride, alpha: 1.0).cgColor
      
      if i != 0 {
        let prevPoint = self.point(for: polyline.points()[i - 1])
        path.move(to: prevPoint)
        path.addLine(to: point)
        
        let colors = [prevColor!, currentColor!] as CFArray
        let baseWidth = self.lineWidth / zoomScale
        
        context.saveGState()
        context.addPath(path)
        
        let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: [0, 1])
        
        context.setLineWidth(baseWidth)
        context.replacePathWithStrokedPath()
        context.clip()
        context.drawLinearGradient(gradient!, start: prevPoint, end: point, options: [])
        context.restoreGState()
      }
      
      prevColor = currentColor
    }
  }
}
