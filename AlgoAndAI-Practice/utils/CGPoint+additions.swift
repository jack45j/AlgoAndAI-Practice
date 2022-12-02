//
//  CGPoint+additions.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/1.
//

import Foundation

extension CGPoint {
    func coordinateOfCircle(radius: Float, angle: Float) -> CGPoint {
        let offsetAngle = angle - 90
        let x = (radius * cos(offsetAngle * Float.pi / 180) * 100).rounded(.toNearestOrEven) / 100.0
        let y = (radius * sin(offsetAngle * Float.pi / 180) * 100.0).rounded(.toNearestOrEven) / 100.0
        
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}
