//
//  Direction.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/18.
//

import Foundation

enum Direction {
    case west
    case north
    case east
    case south
    case westNorth
    case northEast
    case eastSouth
    case southWest
    
    case same
    
    static var fourDirections: [Direction] {
        return [.west, .north, .east, .south]
    }
    
    var directions: [Direction] {
        switch self {
        case .west:         return [.west]
        case .north:        return [.north]
        case .east:         return [.east]
        case .south:        return [.south]
        case .westNorth:    return [.west, .north]
        case .northEast:    return [.north, .east]
        case .eastSouth:    return [.east, .south]
        case .southWest:    return [.south, .west]
        case .same:         return []
        }
    }
    
    var fourDirections: [Direction] {
        return self.directions + Direction.fourDirections.filter({ !self.directions.contains($0) })
    }
}
