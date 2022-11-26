//
//  SolutionType.swift
//  AlgoAndAI-Practice
//
//  Created by 林翌埕-20001107 on 2022/9/21.
//

import Foundation

protocol SolutionType {
    var placements: [Placement] { get set }
    var totalDistance: Double { get }
}

extension SolutionType {
    var totalDistance: Double {
        var distance: Double = 0.0
        for idx in 0..<placements.count {
            if idx + 1 >= placements.count {
                distance += placements[idx].distance(to: placements[0])
            } else {
                distance += placements[idx].distance(to: placements[idx + 1])
            }
        }
        return distance
    }
}

struct Solution: SolutionType, Equatable {
    var placements: [Placement]
}
