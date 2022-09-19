//
//  CGRect+additions.swift
//  TSP-Practice
//
//  Created by Benson Lin on 2022/9/18.
//

import Foundation

extension CGRect {
    func randomPoint(offset: CGPoint) -> CGPoint {
        return CGPoint(x: CGFloat.random(in: minX+offset.x...maxX-offset.x),
                       y: CGFloat.random(in: minY+offset.y...maxY-offset.y))
    }
}
