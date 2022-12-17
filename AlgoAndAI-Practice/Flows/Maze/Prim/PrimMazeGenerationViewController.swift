//
//  PrimMazeGenerationViewController.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/7.
//

import UIKit
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

class PrimMazeGenerationViewController: UIViewController, ConfigurableType, MazeGeneratable {
    
    class func instantiate(config: MazeSizeGenerationConfigurations) -> PrimMazeGenerationViewController {
        let viewController = PrimMazeGenerationViewController()
        viewController.config = config
        return viewController
    }
    
    var config: MazeSizeGenerationConfigurations! = .init()
    
    var dfs: DfsPathFinding?
    
    lazy var maze: [[MazeUnit]] = {
        var units: [[MazeUnit]] = []
        var column: [MazeUnit] = []
        for x in 1...config.shortEdge() {
            for y in 1...config.longEdge() {
                column.append(.init(coordinate: .init(x: x, y: y)))
            }
            units.append(column)
            column = []
        }
        return units
    }()
    
    private var wallList: [Set<MazeUnit>: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        generateAndDrawMaze(maze: &maze)
    }
    
    private func addWallsToList(x: Int, y: Int) {
        Direction.fourDirections.forEach { dir in
            if let unit = self.find(x: x, y: y, of: dir),
               wallList[Set([maze[x][y], maze[unit.x][unit.y]])] != true,
//               !unit.isMazeBorder,
               !unit.isVisited {
                wallList[Set([maze[x][y], maze[unit.x][unit.y]])] = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let startPointX = Int(config.startPoint().x)
//        let startPointY = Int(config.startPoint().y)
//        let endPointX = Int(config.endPoint().x)
//        let endPointY = Int(config.endPoint().y)
        
        // Break start point left wall
//        maze[startPointX][startPointY].view?.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 0.3)
//        maze[startPointX][startPointY].isMazeBorder = false
//        maze[startPointX][startPointY].isStartPoint = true
//        breakWall(&maze, x: startPointX, y: startPointY, direction: .left)
        
        // Break End Point right wall
//        maze[endPointX][endPointY].view?.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 0.3)
//        maze[endPointX][endPointY].isMazeBorder = false
//        maze[endPointX][endPointY].isDestination = true
//        breakWall(&maze, x: endPointX, y: endPointY, direction: .right)
        
        // 1. Pick a cell, mark it as part of the maze.
        // Add the walls of the cell to the wall list.
        let initCoordinate = (x: Int.random(in: 1..<shortEdge()), y: Int.random(in: 1..<longEdge()))
        maze[initCoordinate.x][initCoordinate.y].isVisited = true
        addWallsToList(x: initCoordinate.x, y: initCoordinate.y)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.0001, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            
            // 2. While there are walls in the list
            guard !self.wallList.isEmpty else {
                t.invalidate()
                let (startPoint, destinationPoint) = self.generateRandomStartAndDestination()
                self.maze[startPoint.x][startPoint.y].isStartPoint = true
                self.maze[startPoint.x][startPoint.y].view?.backgroundColor = .red
                self.maze[destinationPoint.x][destinationPoint.y].isDestination = true
                self.maze[destinationPoint.x][destinationPoint.y].view?.backgroundColor = .green
                
                self.dfs = DfsPathFinding(mazeData: self.maze, startPoint: startPoint, destinationPoint: destinationPoint)
                
                self.dfs?.onPointDidVisit = { coordinate in
                    if coordinate != startPoint && coordinate != destinationPoint {
                        self.maze[coordinate.x][coordinate.y].view?.backgroundColor = .orange
                    }
                }
                
                self.dfs?.onFindedPath = { path in
                    var idx = 0
                    func draw() {
                        guard idx < path.count else { return }
                        let coordinate = path[idx]
                        if coordinate != startPoint && coordinate != destinationPoint {
                            UIView.animate(withDuration: 0.002, delay: 0) {
                                self.maze[coordinate.x][coordinate.y].view?.backgroundColor = .yellow
                            } completion: { _ in
                                idx += 1
                                draw()
                            }
                        } else {
                            idx += 1
                            draw()
                        }
                    }
                    
                    draw()

                    
//                    for coordinate in path {
//                        if coordinate != startPoint && coordinate != destinationPoint {
//                            UIView.animate(withDuration: 2, delay: 0) {
//                                self.maze[coordinate.x][coordinate.y].view?.backgroundColor = .yellow
//                            }
//                        }
//                    }
                }
                
                self.dfs?.start()
                
                
                return
            }
            
            // 3. Pick a random wall from the list.
            guard let randomWall = self.wallList.randomElement() else { fatalError() }
            let unitsArray = Array(randomWall.key)
            let (x1, y1, x2, y2) = (unitsArray[0].x, unitsArray[0].y, unitsArray[1].x, unitsArray[1].y)
            
            // 4. If only one of the cells that the wall divides is visited
            guard (self.maze[x1][y1].isVisited && self.maze[x2][y2].isVisited) == false else {
                self.wallList.removeValue(forKey: randomWall.key)
                return
            }
            
            // 5. Make the wall a passage and mark the unvisited cell as part of the maze
            let unVisitedUnit: MazeUnit!
            if !self.maze[x1][y1].isVisited {
                unVisitedUnit = self.maze[x1][y1]
            } else if !self.maze[x2][y2].isVisited {
                unVisitedUnit = self.maze[x2][y2]
            } else {
                return
            }
            
            self.maze[unVisitedUnit.x][unVisitedUnit.y].isVisited = true
            self.breakWall(in: &self.maze, between: (first: unitsArray[0], second: unitsArray[1]))
            
            // 6. Add the neighboring walls of the cell to the wall list
            self.addWallsToList(x: unVisitedUnit.x, y: unVisitedUnit.y)
            
            // 7. Remove the wall from the list
            self.wallList.removeValue(forKey: randomWall.key)
        }
    }
    
    private func generateRandomStartAndDestination() -> (start: Coordinate, destination: Coordinate) {
        var startPoint: Coordinate = .init(x: 0, y: 0)
        var destinationPoint: Coordinate = .init(x: 0, y: 0)
        while destinationPoint == startPoint {
            startPoint = .init(x: Int.random(in: 0..<shortEdge()), y: Int.random(in: 0..<shortEdge()))
            destinationPoint = .init(x: Int.random(in: 0..<shortEdge()), y: Int.random(in: 0..<shortEdge()))
        }
        
        return (startPoint, destinationPoint)
    }
}

class Vertex {
    var id: UUID = .init()
    var coordinate: Coordinate
    var isVisited: Bool = false
    var adjacent = [Vertex]()
    var depth: Int
    var parentNode: Vertex?
    
    init(coordinate: Coordinate, depth: Int) {
        self.depth = depth
        self.coordinate = coordinate
    }
}

class DfsPathFinding {
    var startPoint: Coordinate
    var destinationPoint: Coordinate
    var maze: [[MazeUnit]]
    
    var currentVertex: Vertex
    
    var paths: Vertex
    
    var visitedList: [Coordinate] = []
    var frontierList: [Vertex] = []
    
//    var onPointWillVisit: ((Coordinate) -> Void)?
    var onPointDidVisit: ((Coordinate) -> Void)?
    var onFindedPath: (([Coordinate]) -> Void)?
    
    init(mazeData: [[MazeUnit]], startPoint: Coordinate, destinationPoint: Coordinate) {
        self.maze = mazeData
        self.startPoint = startPoint
        self.destinationPoint = destinationPoint
        self.paths = .init(coordinate: startPoint, depth: 0)
        self.currentVertex = self.paths
    }
    
    func visit(_ vertex: Vertex) {
        frontierList.append(vertex)
        visitedList.append(vertex.coordinate)
        vertex.isVisited = true
    }
    
    func start() {
        // findingDirectionOrder
        let findingDirections: [Direction] = Coordinate.findDirection(start: startPoint, dest: destinationPoint).fourDirections
        
        // start point
        visit(currentVertex)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] t in
            guard let self = self else { return }
            
            guard let frontier = self.frontierList.last else { fatalError() }
            self.currentVertex = frontier
            self.frontierList.removeLast(1)
            
            for direction in findingDirections {
                if let currentCoordinate = self.maze.move(from: self.currentVertex.coordinate, to: direction)?.coordinate {
                    if !self.visitedList.contains(currentCoordinate) {
                        let vertex = Vertex(coordinate: currentCoordinate, depth: self.currentVertex.depth + 1)
                        vertex.parentNode = self.currentVertex
                        self.currentVertex.adjacent.append(vertex)
                        self.visit(vertex)
                        self.onPointDidVisit?(vertex.coordinate)
                    }
                } else {
                    // do nothing
                }
            }
            
            // Result
            guard self.currentVertex.coordinate != self.destinationPoint else {
                var path: [Coordinate] = [self.currentVertex.coordinate]
                var pathVertex = self.currentVertex.parentNode
                while let vertex = pathVertex {
                    path.append(vertex.coordinate)
                    pathVertex = vertex.parentNode
                }
                self.onFindedPath?(path)
                t.invalidate()
                return
            }
        }
    }
}
