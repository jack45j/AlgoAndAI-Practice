//
//  UIView+additions.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/2.
//

import UIKit
import Foundation

extension UIView {
    
    @discardableResult
    func addBorder(toSide side: MazeUnit.WallDirection, withColor color: CGColor, andThickness thickness: CGFloat = 1) -> CALayer {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .left:
            border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: thickness, height: bounds.height)
        case .right:
            border.frame = CGRect(x: bounds.maxX, y: bounds.minY, width: thickness, height: bounds.height)
        case .top:
            border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: bounds.minX, y: bounds.maxY, width: bounds.width, height: thickness)
        }
        
        layer.addSublayer(border)
        return border
    }
}
