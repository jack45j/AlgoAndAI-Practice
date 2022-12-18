//
//  Coordinate.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/18.
//

import Foundation

struct Coordinate: Hashable, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    var x: Int
    var y: Int
    
    func move(_ direction: Direction) -> Coordinate {
        switch direction {
        case .west:         return .init(x: self.x - 1, y: self.y)
        case .north:        return .init(x: self.x, y: self.y - 1)
        case .east:         return .init(x: self.x + 1, y: self.y)
        case .south:        return .init(x: self.x, y: self.y + 1)
        case .westNorth:    return .init(x: self.x - 1, y: self.y - 1)
        case .northEast:    return .init(x: self.x + 1, y: self.y - 1)
        case .eastSouth:    return .init(x: self.x + 1, y: self.y + 1)
        case .southWest:    return .init(x: self.x - 1, y: self.y + 1)
        case .same:         return self
        }
    }
    
    static func findDirection(start: Coordinate, dest: Coordinate) -> Direction {
        guard start != dest else { return .same }
        if start.x == dest.x {
            if start.y < dest.y {
                return .south
            } else {
                return .north
            }
        } else if start.y == dest.y {
            if start.x < dest.x {
                return .west
            } else {
                return .east
            }
        } else {
            if start.x < dest.x {
                // east side
                if start.y < dest.y {
                    return .eastSouth
                } else {
                    return .northEast
                }
            } else {
                // west side
                if start.y < dest.y {
                    return .southWest
                } else {
                    return .westNorth
                }
            }
        }
    }
}
