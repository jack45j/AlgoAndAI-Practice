//
//  MazeUnit.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/2.
//

import UIKit
import Foundation

protocol MazeUnitType: Identifiable {
    var id: UUID { get }
    var x: Int { get }
    var y: Int { get }
    var walls: Int8 { get set }
}

extension MazeUnitType {
    var hasNorthWall: Bool {
        return (walls & 0b1000) != 0
    }
    
    var hasEastWall: Bool {
        return (walls & 0b0100) != 0
    }
    
    var hasSouthWall: Bool {
        return (walls & 0b0010) != 0
    }
    
    var hasWestWall: Bool {
        return (walls & 0b0001) != 0
    }
}

struct CustomMazeUnit: MazeUnitType {
    
    var id = UUID()
    var x: Int
    var y: Int
    
    var isVisited = false
    var isMazeBorder = false
    var isStartPoint = false
    var isDestination = false
    var walls: Int8 = 0b1111
}

protocol MazeGenerationAlgorithm {
    associatedtype MazeUnit: MazeUnitType
    func start()
    
    var onInitMaze: (([[MazeUnit]]) -> Void)? { get set }
    var onGeneratedUnit: ((MazeUnit) -> Void)? { get set }
    var onFinishMaze: (([[MazeUnit]]) -> Void)? { get set }
}

final class MazeConfigurator<T: MazeSizeConfigurable & MazeGenerationAlgorithm> {
    var generator: T
    
    init(generator: T) {
        self.generator = generator
        self.generator.start()
    }
}







//extension Array where Element == [MazeUnit] {
//    func unit(_ coordinate: Coordinate) -> MazeUnit {
//        return self[coordinate.x][coordinate.y]
//    }
//
//    func move(from unit: Coordinate, to direction: Direction) -> MazeUnit? {
//        guard !self[unit.x][unit.y].walls.keys.contains(direction) else {
//            return nil
//        }
//        return self[unit.move(direction).x][unit.move(direction).y]
//    }
//}
