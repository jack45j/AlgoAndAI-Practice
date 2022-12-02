//
//  PlacementGeneratable.swift
//  AlgoAndAI-Practice
//
//  Created by Benson Lin on 2022/9/18.
//

import Foundation
import UIKit

protocol PlacementGeneratable {
    var placements: [Placement] { get set }
}

extension PlacementGeneratable where Self: UIViewController {
    func generatePlacement(_ count: Int, dotSize: CGFloat = 10, offset: CGPoint = .init(x: 20, y: 60)) -> [Placement] {
        var placements: [Placement] = []
        for idx in 0 ..< count {
            var placement = Placement(x: view.frame.randomPoint(offset: offset).x.toFloat,
                                      y: view.frame.randomPoint(offset: offset).y.toFloat)
            
            let dotBezier = UIBezierPath(ovalIn: .init(origin: .init(x: placement.x.toCGFloat - dotSize/2,
                                                                     y: placement.y.toCGFloat - dotSize/2),
                                                       size: CGSize(width: dotSize, height: dotSize)))
            let layer = CAShapeLayer()
            layer.path = dotBezier.cgPath
            layer.fillColor = idx == 0 ? UIColor.purple.cgColor : UIColor.green.cgColor
            view.layer.addSublayer(layer)
            placement.layer = layer
            placements.append(placement)
        }
        return placements
    }
    
    func drawPlacements(_ placements: [Placement], dotSize: CGFloat = 10, offset: CGPoint = .init(x: 20, y: 60)) {
        for idx in 0..<placements.count {
            var placement = placements[idx]
            let dotBezier = UIBezierPath(ovalIn: .init(origin: .init(x: placement.x.toCGFloat - dotSize/2,
                                                                     y: placement.y.toCGFloat - dotSize/2),
                                                       size: CGSize(width: dotSize, height: dotSize)))
            let layer = CAShapeLayer()
            layer.path = dotBezier.cgPath
            layer.fillColor = idx == 0 ? UIColor.purple.cgColor : UIColor.green.cgColor
            view.layer.addSublayer(layer)
            placement.layer = layer
        }
    }
    
    func generagePentagon() -> [Placement] {
        var placements: [Placement] = []
        let pentagonSize = min(view.frame.width, view.frame.height) - 40
        let centerPoint = CGPoint(x: view.frame.midX, y: view.frame.midY)
        func gen(radius: CGFloat, degreeOffset: CGFloat) {
            var degree = 0.0 + degreeOffset
            for _ in 1...5 {
                let point = centerPoint.coordinateOfCircle(radius: Float(radius) / 2,
                                                           angle: Float(degree))
                placements.append(Placement(x: Float(centerPoint.x + point.x),
                                            y: Float(centerPoint.y + point.y)))
                degree += 72
            }
        }
        gen(radius: pentagonSize, degreeOffset: 0)
        gen(radius: pentagonSize / 1.5, degreeOffset: 0)
        gen(radius: pentagonSize / 3.5, degreeOffset: 180)
        return placements
    }
}


