//
//  PrimMazeGenerationViewController.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/7.
//

import UIKit
import Reusable
import Foundation

class PrimMazeGenerationViewController: UIViewController, ConfigurableType, MazeGeneratable, StoryboardBased {
    
    class func instantiate(config: MazeSizeGenerationConfigurations) -> PrimMazeGenerationViewController {
        let viewController = PrimMazeGenerationViewController.instantiate()
        viewController.config = config
        return viewController
    }
    
    @IBOutlet weak var aboveContainerView: UIView!
    @IBOutlet weak var belowContainerView: UIView!
    
    var config: MazeSizeGenerationConfigurations! = .init()
    var pathFindingModule: PathFindingAlgorithms?
    var pathFindingModule2: PathFindingAlgorithms?
    
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
    
    lazy var maze2: [[MazeUnit]] = {
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
        
        generateAndDrawInitializeMaze(in: aboveContainerView, maze: &maze)
        generateAndDrawInitializeMaze(in: belowContainerView, maze: &maze2)
        startGenerateMaze()
    }
    
    private func addWallsToList(x: Int, y: Int) {
        Direction.fourDirections.forEach { dir in
            if let unit = self.find(x: x, y: y, of: dir),
               wallList[Set([maze[x][y], maze[unit.x][unit.y]])] != true,
               !unit.isVisited {
                wallList[Set([maze[x][y], maze[unit.x][unit.y]])] = true
            }
        }
    }
    
    private func startPathFinding(in maze: inout [[MazeUnit]], startPoint: Coordinate, destinationPoint: Coordinate) {
        maze[startPoint.x][startPoint.y].isStartPoint = true
        maze[startPoint.x][startPoint.y].view?.backgroundColor = .red
        maze[destinationPoint.x][destinationPoint.y].isDestination = true
        maze[destinationPoint.x][destinationPoint.y].view?.backgroundColor = .green
        
        pathFindingModule = .init(maze: maze, startPoint: startPoint, destinationPoint: destinationPoint, algo: .dfs)
        
        pathFindingModule?.onPointDidVisit = { [weak self, maze] coordinate in
            if coordinate != startPoint && coordinate != destinationPoint {
                maze[coordinate.x][coordinate.y].view?.backgroundColor = .init(red: 0, green: 0, blue: 1, alpha: 0.3)
            }
        }
        
        pathFindingModule?.onFindedPath = { [weak self, maze] path in
            var idx = 0
            func draw() {
                guard idx < path.count else { return }
                let coordinate = path[idx]
                if coordinate != startPoint && coordinate != destinationPoint {
                    UIView.animate(withDuration: 0.002, delay: 0) {
                        maze[coordinate.x][coordinate.y].view?.backgroundColor = .init(red: CGFloat(Double(idx + 1) / Double(path.count)),
                                                                                            green: CGFloat(Double(path.count - idx) / Double(path.count)),
                                                                                            blue: 0, alpha: 1)
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
        }
        
        pathFindingModule?.start()
    }
    
    private func startPathFinding2(in maze: inout [[MazeUnit]], startPoint: Coordinate, destinationPoint: Coordinate) {
        maze[startPoint.x][startPoint.y].isStartPoint = true
        maze[startPoint.x][startPoint.y].view?.backgroundColor = .red
        maze[destinationPoint.x][destinationPoint.y].isDestination = true
        maze[destinationPoint.x][destinationPoint.y].view?.backgroundColor = .green
        
        pathFindingModule2 = .init(maze: maze, startPoint: startPoint, destinationPoint: destinationPoint, algo: .astar)
        
        pathFindingModule2?.onPointDidVisit = { [weak self, maze] coordinate in
            if coordinate != startPoint && coordinate != destinationPoint {
                maze[coordinate.x][coordinate.y].view?.backgroundColor = .init(red: 0, green: 0, blue: 1, alpha: 0.3)
            }
        }
        
        pathFindingModule2?.onFindedPath = { [weak self, maze] path in
            var idx = 0
            func draw() {
                guard idx < path.count else { return }
                let coordinate = path[idx]
                if coordinate != startPoint && coordinate != destinationPoint {
                    UIView.animate(withDuration: 0.002, delay: 0) {
                        maze[coordinate.x][coordinate.y].view?.backgroundColor = .init(red: CGFloat(Double(idx + 1) / Double(path.count)),
                                                                                            green: CGFloat(Double(path.count - idx) / Double(path.count)),
                                                                                            blue: 0, alpha: 1)
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
        }
        
        pathFindingModule2?.start()
    }
    
    private func startGenerateMaze() {
        // 1. Pick a cell, mark it as part of the maze.
        // Add the walls of the cell to the wall list.
        let initCoordinate = (x: Int.random(in: 1..<shortEdge()), y: Int.random(in: 1..<longEdge()))
        maze[initCoordinate.x][initCoordinate.y].isVisited = true
        maze2[initCoordinate.x][initCoordinate.y].isVisited = true
        addWallsToList(x: initCoordinate.x, y: initCoordinate.y)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.0001, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            
            // 2. While there are walls in the list
            guard !self.wallList.isEmpty else {
                t.invalidate()
                
                let (startPoint, destinationPoint) = self.config.isRandomStartAndDestination ? self.generateRandomStartAndDestination() : (self.config.startPoint(), self.config.endPoint())
                
                self.startPathFinding(in: &self.maze, startPoint: startPoint, destinationPoint: destinationPoint)
                self.startPathFinding2(in: &self.maze2, startPoint: startPoint, destinationPoint: destinationPoint)
                
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
            self.maze2[unVisitedUnit.x][unVisitedUnit.y].isVisited = true
            self.breakWall(in: &self.maze, between: (first: unitsArray[0], second: unitsArray[1]))
            self.breakWall(in: &self.maze2, between: (first: unitsArray[0], second: unitsArray[1]))
            
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


