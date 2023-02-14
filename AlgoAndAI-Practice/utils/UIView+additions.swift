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
    func addBorder(toSide side: Direction, withColor color: CGColor, andThickness thickness: CGFloat = 1) -> CALayer {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .west:
            border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: thickness, height: bounds.height)
        case .east:
            border.frame = CGRect(x: bounds.maxX, y: bounds.minY, width: thickness, height: bounds.height)
        case .north:
            border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: thickness)
        case .south:
            border.frame = CGRect(x: bounds.minX, y: bounds.maxY, width: bounds.width, height: thickness)
        default: fatalError()
        }
        
        layer.addSublayer(border)
        return border
    }
    
    @discardableResult
    func drawBorder(_ unit: any MazeUnitType, withColor color: CGColor, andThickness thickness: CGFloat = 1) -> CALayer {
        
        let border = CALayer()
        border.backgroundColor = color
        
        if unit.hasNorthWall {
            border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: thickness)
        }
        
        if unit.hasEastWall {
            border.frame = CGRect(x: bounds.maxX, y: bounds.minY, width: thickness, height: bounds.height)
        }
        
        if unit.hasSouthWall {
            border.frame = CGRect(x: bounds.minX, y: bounds.maxY, width: bounds.width, height: thickness)
        }
        
        if unit.hasWestWall {
            border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: thickness, height: bounds.height)
        }
        
        layer.addSublayer(border)
        return border
    }
}
