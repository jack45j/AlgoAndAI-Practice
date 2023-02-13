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
    private var mazeStack: [MazeUnit] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        generateAndDrawInitializeMaze(in: view, maze: &maze)
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
    
    private func startPathFinding() {
        let (startPoint, destinationPoint) = config.isRandomStartAndDestination ? generateRandomStartAndDestination() : (config.startPoint(), config.endPoint())
        maze[startPoint.x][startPoint.y].isStartPoint = true
        maze[startPoint.x][startPoint.y].view?.backgroundColor = .red
        maze[destinationPoint.x][destinationPoint.y].isDestination = true
        maze[destinationPoint.x][destinationPoint.y].view?.backgroundColor = .green
        
        dfs = DfsPathFinding(mazeData: maze, startPoint: startPoint, destinationPoint: destinationPoint)
        
        dfs?.onPointDidVisit = { [weak self] coordinate in
            if coordinate != startPoint && coordinate != destinationPoint {
                self?.maze[coordinate.x][coordinate.y].view?.backgroundColor = .init(red: 0, green: 0, blue: 1, alpha: 0.3)
            }
        }
        
        dfs?.onFindedPath = { path in
            var idx = 0
            func draw() {
                guard idx < path.count else { return }
                let coordinate = path[idx]
                if coordinate != startPoint && coordinate != destinationPoint {
                    UIView.animate(withDuration: 0.002, delay: 0) {
                        self.maze[coordinate.x][coordinate.y].view?.backgroundColor = .init(red: CGFloat(Double(idx + 1) / Double(path.count)),
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
        
        dfs?.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // push start unit into stack and start recursive
        mazeStack.append(maze[0][0])
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.0001, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            guard !self.mazeStack.isEmpty else {
                t.invalidate()
                
                self.startPathFinding()
                
                return
            }
            
            guard let x = self.mazeStack.last?.x,
                  let y = self.mazeStack.last?.y else { t.invalidate(); return }
            
            var available: [MazeUnit: Direction] = [:]
            
            Direction.fourDirections.forEach { dir in
                if let unit = self.find(x: x, y: y, of: dir),
//                   !unit.isMazeBorder,
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

final class DfsMazeGenerator<MazeUnit: MazeUnitType>: MazeSizeConfigurable & MazeGenerationAlgorithm {
    var edge1: Int
    var edge2: Int
    var isRandomStartAndDestination: Bool
    
    var onInitMaze: (([[MazeUnit]]) -> Void)?
    var onGeneratedUnit: ((MazeUnit) -> Void)?
    var onFinishMaze: (([[MazeUnit]]) -> Void)?
    
    init(edge1: Int, edge2: Int, isRandomStartAndDestination: Bool) {
        self.edge1 = edge1
        self.edge2 = edge2
        self.isRandomStartAndDestination = isRandomStartAndDestination
    }
    
    func start() {
        
    }
}
