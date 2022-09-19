//
//  Placement.swift
//  TSP-Practice
//
//  Created by Benson Lin on 2022/9/18.
//

import Foundation
import UIKit

struct Placement: Hashable {
    var id: UUID = UUID()
    var x: Float
    var y: Float
    var layer: CALayer?
    
    func distance(to otherPlace: Placement) -> Float {
        let xDistance = abs(x - otherPlace.x)
        let yDistance = abs(y - otherPlace.y)
        return sqrtf( pow(xDistance, 2) + pow(yDistance, 2) )
    }
    
    var point: CGPoint {
        return .init(x: x.toCGFloat, y: y.toCGFloat)
    }
    
    func drawArrow(to: Self, from view: UIView, lineDash: [NSNumber] = [], isFinal: Bool) -> CALayer {
        let p1 = self.point
        let p2 = to.point
        let arrow = UIBezierPath()
        arrow.addArrow(start: p1,
                      end: p2,
                      pointerLineLength: 5.0,
                      arrowAngle: CGFloat(Double.pi / 5))
        
        let arrowLayer = CAShapeLayer()
        let path = CGMutablePath()
        arrowLayer.strokeColor = isFinal ? UIColor.red.cgColor : UIColor.lightGray.cgColor
        arrowLayer.lineWidth = 1
        arrowLayer.opacity = 1
        if !lineDash.isEmpty {
            arrowLayer.lineDashPattern = lineDash
        }
        path.addPath(arrow.cgPath)
        path.addLines(between: [p1, p2])
        arrowLayer.path = path

        arrowLayer.fillColor = UIColor.clear.cgColor
        arrowLayer.lineJoin = CAShapeLayerLineJoin.round
        arrowLayer.lineCap = CAShapeLayerLineCap.round
        
        view.layer.addSublayer(arrowLayer)
        return arrowLayer
    }
}

extension Array where Element == Placement {
    func drawTourPath(isFinal: Bool = false, from view: UIView) -> [CALayer] {
        var routeLayer: [CALayer] = []
        for idx in 0 ..< self.count {
            if idx + 1 >= self.count {
                routeLayer.append(self[idx].drawArrow(to: self[0], from: view, isFinal: isFinal))
            } else {
                routeLayer.append(self[idx].drawArrow(to: self[idx+1], from: view, isFinal: isFinal))
            }
        }
        return routeLayer
    }
}
