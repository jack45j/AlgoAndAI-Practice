//
//  DfsMazeGenerator.swift
//  AlgoAndAI-Practice
//
//  Created by 林翌埕-20001107 on 2023/2/15.
//

import Foundation

protocol DfsMazeGenerationAlgorithm: MazeGenerationAlgorithm where MazeUnit: MazeUnitType {
    var mazeStack: [MazeUnit] { get set }
}

protocol DfsMazeGenerationAlgorithmDelegate<MazeUnit>: MazeGenerationAlgorithmDelegate where MazeUnit: MazeUnitType {
    func didPassThrough(unit: MazeUnit)
}

final class DfsMazeGenerator<MazeUnit: MazeUnitType>: MazeSizeConfigurable & DfsMazeGenerationAlgorithm {
    
    var edge1: Int
    var edge2: Int
    var isRandomStartAndDestination: Bool
    var maze: [[MazeUnit]] = [[]]
    var walls: [(x1: Int, x2: Int, y1: Int, y2: Int)] = []
    var mazeStack: [MazeUnit] = []
    
    var delegate: (any DfsMazeGenerationAlgorithmDelegate<MazeUnit>)?
    
    init(config: MazeSizeConfigurable) {
        self.edge1 = config.edge1
        self.edge2 = config.edge2
        self.isRandomStartAndDestination = config.isRandomStartAndDestination
        self.maze = initMaze()
    }
    
    private func initMaze() -> [[MazeUnit]] {
        var units: [[MazeUnit]] = []
        var column: [MazeUnit] = []
        for x in 0..<min(edge1, edge2) {
            for y in 0..<max(edge1, edge2) {
                column.append(MazeUnit.init(x: x, y: y))
            }
            units.append(column)
            column = []
        }
        return units
    }
    
    func start() {
        delegate?.didInit(maze: self.maze)
        
        // 1. push start unit into stack and start recursive
        let start = pickStartCoordinate()
        mazeStack.append(maze[start.x][start.y])
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: true) { [unowned self] t in
            
            // 2. Check if generate finished
            guard !mazeStack.isEmpty else {
                for x in 0..<min(edge1, edge2) {
                    for y in 0..<max(edge1, edge2) {
                        maze[x][y].isVisited = false
                    }
                }
                delegate?.didFinishGenerated(maze: maze)
                t.invalidate()
                return
            }
            
            guard let lastUnit = self.mazeStack.last else { t.invalidate(); return }
            
            let availableUnitsNearby = availableUnit(from: maze[lastUnit.x][lastUnit.y])
            
            if availableUnitsNearby.isEmpty {
                delegate?.didGeneratedUnit(unit: maze[lastUnit.x][lastUnit.y])
                maze[lastUnit.x][lastUnit.y].isVisited = true
                mazeStack.removeLast()
            } else {
                guard let availableUnit = availableUnitsNearby.randomElement() else { fatalError() }
                self.mazeStack.append(availableUnit)
                breakWall(from: (lastUnit.x, availableUnit.x, lastUnit.y, availableUnit.y))
                delegate?.didGeneratedUnit(unit: maze[availableUnit.x][availableUnit.y])
                delegate?.didGeneratedUnit(unit: maze[lastUnit.x][lastUnit.y])
                delegate?.didPassThrough(unit: maze[lastUnit.x][lastUnit.y])
            }
        }
    }
    
    private func availableUnit(from unit: MazeUnit) -> [MazeUnit] {
        var available: [MazeUnit] = []
        directions.forEach { (dx, dy) in
            if let availableUnit = maze[safe: unit.x + dx]?[safe: unit.y + dy], !mazeStack.map({ $0.id }).contains(availableUnit.id), !availableUnit.isVisited {
                available.append(availableUnit)
            }
        }
        return available
    }
    
    private func breakWall(from wall: (x1: Int, x2: Int, y1: Int, y2: Int)) {
        if wall.x1 == wall.x2 {
            // vertical
            maze[wall.x1][min(wall.y1, wall.y2)].walls &= 0b1101
            maze[wall.x1][max(wall.y1, wall.y2)].walls &= 0b0111
        } else {
            // horizontal
            maze[min(wall.x1, wall.x2)][wall.y1].walls &= 0b1011
            maze[max(wall.x1, wall.x2)][wall.y1].walls &= 0b1110
        }
    }
    
    private func pickStartCoordinate() -> (x: Int, y: Int) {
        (x: Int.random(in: 0..<min(edge1, edge2)), y: Int.random(in: 0..<max(edge1, edge2)))
    }
}


extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
