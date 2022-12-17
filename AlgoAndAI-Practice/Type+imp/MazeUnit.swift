//
//  MazeUnit.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/2.
//

import UIKit
import Foundation

struct MazeUnit: Hashable {
    
    let id = UUID()
    
    var coordinate: Coordinate
    
    var x: Int {
        return coordinate.x
    }
    
    var y: Int {
        return coordinate.y
    }
    
    var isVisited = false {
        didSet {
            if isVisited {
                self.view?.backgroundColor = isDestination || isStartPoint ? self.view?.backgroundColor : .white
            }
        }
    }
    
    var isMazeBorder = false
    var isStartPoint = false
    var isDestination = false
    var view: UIView? = nil
    var walls: [Direction: CALayer] = {
        var result: [Direction: CALayer] = [:]
        Direction.fourDirections.forEach {
            result[$0] = .init()
        }
        return result
    }()
}

extension Array where Element == [MazeUnit] {
    func unit(_ coordinate: Coordinate) -> MazeUnit {
        return self[coordinate.x][coordinate.y]
    }
    
    func move(from unit: Coordinate, to direction: Direction) -> MazeUnit? {
        guard !self[unit.x][unit.y].walls.keys.contains(direction) else {
            return nil
        }
        return self[unit.move(direction).x][unit.move(direction).y]
    }
}
