//
//  PrimMazeGenerationViewController.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/7.
//

import UIKit
import Foundation

class PrimMazeGenerationViewController: UIViewController, ConfigurableType, MazeGeneratable {
    
    class func instantiate(config: MazeSizeGenerationConfigurations) -> PrimMazeGenerationViewController {
        let viewController = PrimMazeGenerationViewController()
        viewController.config = config
        return viewController
    }
    
    var config: MazeSizeGenerationConfigurations! = .init()
    
    lazy var maze: [[MazeUnit]] = {
        var units: [[MazeUnit]] = []
        var column: [MazeUnit] = []
        for _ in 1...config.shortEdge() {
            for _ in 1...config.longEdge() {
                column.append(.init())
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
        MazeUnit.WallDirection.allCases.forEach { dir in
            if let unit = self.find(x: x, y: y, of: dir),
               wallList[Set([maze[x][y], maze[unit.x][unit.y]])] != true,
               !unit.isMazeBorder,
               !unit.isVisited {
                wallList[Set([maze[x][y], maze[unit.x][unit.y]])] = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let startPointX = Int(config.startPoint().x)
        let startPointY = Int(config.startPoint().y)
        let endPointX = Int(config.endPoint().x)
        let endPointY = Int(config.endPoint().y)
        
        // Break start point left wall
        maze[startPointX][startPointY].view?.backgroundColor = .white
        maze[startPointX][startPointY].isMazeBorder = false
        breakWall(&maze, x: startPointX, y: startPointY, direction: .left)
        
        // Break End Point right wall
        maze[endPointX][endPointY].view?.backgroundColor = .white
        maze[endPointX][endPointY].isMazeBorder = false
        breakWall(&maze, x: endPointX, y: endPointY, direction: .right)
        
        // 1. Pick a cell, mark it as part of the maze.
        // Add the walls of the cell to the wall list.
        let initCoordinate = (x: Int.random(in: 1..<shortEdge()), y: Int.random(in: 1..<longEdge()))
        maze[initCoordinate.x][initCoordinate.y].isVisited = true
        addWallsToList(x: initCoordinate.x, y: initCoordinate.y)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.0001, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            
            // 2. While there are walls in the list
            guard !self.wallList.isEmpty else { t.invalidate(); return }
            
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
}
