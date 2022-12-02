//
//  MazeUnit.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/2.
//

import UIKit
import Foundation

struct MazeUnit: Hashable {
    enum WallDirection: CaseIterable {
        case top
        case bottom
        case left
        case right
    }
    let id = UUID()
    var x: Int = 0
    var y: Int = 0
    var isVisited = false
    var isMazeBorder = false
    var view: UIView? = nil
    var walls: [WallDirection: CALayer] = {
        var result: [WallDirection: CALayer] = [:]
        WallDirection.allCases.forEach {
            result[$0] = .init()
        }
        return result
    }()
}
