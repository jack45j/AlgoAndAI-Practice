//
//  DfsMazeGenerationViewController.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/1.
//

import UIKit
import Foundation

class DfsMazeGenerationViewController: UIViewController, ConfigurableType, MazeGeneratable {
    
    class func instantiate(config: MazeSizeGenerationConfigurations) -> DfsMazeGenerationViewController {
        let viewController = DfsMazeGenerationViewController()
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
    private var mazeStack: [MazeUnit] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        generateAndDrawMaze(maze: &maze)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let startPointX = Int(config.startPoint().x)
        let startPointY = Int(config.startPoint().y)
        let endPointX = Int(config.endPoint().x)
        let endPointY = Int(config.endPoint().y)
        
        // Break start point left wall
        maze[startPointX][startPointY].view?.backgroundColor = .white
        breakWall(&maze, x: startPointX, y: startPointY, direction: .left)
        
        // Break End Point right wall
        maze[endPointX][endPointY].view?.backgroundColor = .white
        maze[endPointX][endPointY].isMazeBorder = false
        breakWall(&maze, x: endPointX, y: endPointY, direction: .right)
        
        // push start unit into stack and start recursive
        mazeStack.append(maze[startPointX][startPointY])
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            guard !self.mazeStack.isEmpty else { t.invalidate(); return }
            
            guard let x = self.mazeStack.last?.x,
                  let y = self.mazeStack.last?.y else { t.invalidate(); return }
            
            var available: [MazeUnit: MazeUnit.WallDirection] = [:]
            
            MazeUnit.WallDirection.allCases.forEach { dir in
                if let unit = self.find(x: x, y: y, of: dir),
                   !unit.isMazeBorder,
                   !self.mazeStack.map({ $0.id }).contains(unit.id),
                   !unit.isVisited {
                    
                    available[unit] = dir
                }
            }
            
            if !available.isEmpty {
                guard let unit = available.randomElement() else { t.invalidate(); return }
                self.mazeStack.append(unit.key)
                unit.key.view?.backgroundColor = .red
                self.breakWall(&self.maze, x: x, y: y, direction: unit.value)
                self.maze[x][y].view?.backgroundColor = .lightGray
            } else {
                self.maze[x][y].isVisited = true
                self.mazeStack.removeLast()
                self.maze[x][y].view?.backgroundColor = .white
            }
        }
    }
}

