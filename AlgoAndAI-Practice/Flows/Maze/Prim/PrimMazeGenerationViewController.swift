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
    
    var mazeView: [[UIView]] = []
    var maze: [[any MazeUnitType]] = []
    
    class func instantiate(config: MazeSizeGenerationConfigurations) -> PrimMazeGenerationViewController {
        let viewController = PrimMazeGenerationViewController.instantiate()
        viewController.config = config
        return viewController
    }
    
    @IBOutlet weak var aboveContainerView: UIView!
    @IBOutlet weak var belowContainerView: UIView!
    
    var config: MazeSizeGenerationConfigurations! = .init()
//    var pathFindingModule: PathFindingAlgorithms?
//    var pathFindingModule2: PathFindingAlgorithms?
    
    lazy var generator = PrimMazeGenerator<CustomMazeUnit>(config: config)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        generator.delegate = self
        generator.start()
    }
}

extension PrimMazeGenerationViewController: MazeGenerationAlgorithmDelegate {
    func didInit(maze: [[CustomMazeUnit]]) {
        self.maze = maze
        self.mazeView = generateAndDrawInitializeMaze(in: self.view, maze: maze)
    }
    
    func didGeneratedUnit(unit: CustomMazeUnit) {
        mazeView[unit.x][unit.y].layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        mazeView[unit.x][unit.y].drawBorder(unit, withColor: UIColor.black.cgColor)
        mazeView[unit.x][unit.y].backgroundColor = .red
    }
    
    func didFinishGenerated(maze: [[CustomMazeUnit]]) {
        
    }
    
    func didWallListDidChanged(wallList: [(x1: Int, x2: Int, y1: Int, y2: Int)]) {
        wallList.forEach { (x1, x2, y1, y2) in
            if x1 == x2 {
                if y1 > y2 {
                    mazeView[x1][y1].addBorder(toSide: .north, withColor: UIColor.green.cgColor)
                } else {
                    mazeView[x1][y1].addBorder(toSide: .south, withColor: UIColor.green.cgColor)
                }
            } else {
                if x1 > x2 {
                    mazeView[x1][y1].addBorder(toSide: .west, withColor: UIColor.green.cgColor)
                } else {
                    mazeView[x1][y1].addBorder(toSide: .east, withColor: UIColor.green.cgColor)
                }
            }
        }
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

protocol MazeGenerationAlgorithmDelegate<MazeUnit> {
    associatedtype MazeUnit: MazeUnitType
    func didInit(maze: [[MazeUnit]])
    func didGeneratedUnit(unit: MazeUnit)
    func didFinishGenerated(maze: [[MazeUnit]])
    func didWallListDidChanged(wallList: [(x1: Int, x2: Int, y1: Int, y2: Int)])
}

extension MazeGenerationAlgorithm {
    var directions: [(dx: Int, dy: Int)] {
        return [(0, -1), (1, 0), (0, 1), (-1, 0),]
    }
}

protocol PrimMazeGenerationAlgorithm: MazeGenerationAlgorithm {}

final class PrimMazeGenerator<MazeUnit: MazeUnitType>: MazeSizeConfigurable & PrimMazeGenerationAlgorithm {
    
    var edge1: Int
    var edge2: Int
    var isRandomStartAndDestination: Bool
    var maze: [[MazeUnit]] = [[]]
    var walls: [(x1: Int, x2: Int, y1: Int, y2: Int)] = [] {
        didSet {
            delegate?.didWallListDidChanged(wallList: walls)
        }
    }
    
    var delegate: (any MazeGenerationAlgorithmDelegate<MazeUnit>)?
    
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
        
        // 1. Pick the start coordinate and add unit's walls to list.
        let (startX, startY) = pickStartCoordinate()
        maze[startX][startY].isVisited = true
        addWallsToList(from: maze[startX][startY])
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.0000001, repeats: true) { [unowned self] t in
            
            // 2. Check if generate finished
            guard !walls.isEmpty else {
                for x in 0..<min(edge1, edge2) {
                    for y in 0..<max(edge1, edge2) {
                        maze[x][y].isVisited = false
                    }
                }
                delegate?.didFinishGenerated(maze: maze)
                t.invalidate()
                return
            }
            
            // 3. Pick a random wall from the list.
            guard let randomWall = walls.randomElement() else {
                fatalError()
            }
            
            print("randomWall: \(randomWall)")
            
            // 4. If only one of the cells that the wall divides is visited
            guard (maze[randomWall.x1][randomWall.y1].isVisited && maze[randomWall.x2][randomWall.y2].isVisited) == false else {
                walls.remove(at: walls.firstIndex(where: {
                    return $0 == randomWall
                })!)
                return
            }
            // 5. Make the wall a passage and mark the unvisited cell as part of the maze
            breakWall(from: randomWall)
            
            // 6. Add the neighboring walls of the cell to the wall list
            addWallsToList(from: maze[randomWall.x1][randomWall.y1])
            addWallsToList(from: maze[randomWall.x2][randomWall.y2])
            
            // 7. Remove the wall from the list
            walls.remove(at: walls.firstIndex(where: {
                return $0 == randomWall
            })!)
            
            if maze[randomWall.x1][randomWall.y1].isVisited == false {
                delegate?.didGeneratedUnit(unit: maze[randomWall.x1][randomWall.y1])
            }
            
            if maze[randomWall.x2][randomWall.y2].isVisited == false {
                delegate?.didGeneratedUnit(unit: maze[randomWall.x2][randomWall.y2])
            }
            
            maze[randomWall.x1][randomWall.y1].isVisited = true
            maze[randomWall.x2][randomWall.y2].isVisited = true
        }
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
    
    private func addWallsToList(from unit: MazeUnit) {
        directions.enumerated().forEach { (idx, d) in
            let (dx, dy) = (d.dx, d.dy)
            let shiftAmount = 3 - idx
            let shiftedValue: Int8 = 0b1000 >> shiftAmount
            if (unit.walls & shiftedValue) != 0 {
                if let _ = walls.firstIndex(where: {
                    return $0.x1 == unit.x && $0.x2 == unit.x + dx && $0.y1 == unit.y && $0.y2 == unit.y + dy ||
                    $0.x1 == unit.x + dx && $0.x2 == unit.x && $0.y1 == unit.y + dy && $0.y2 == unit.y
                }) {} else {
                    guard
                        unit.x + dx >= 0 && unit.x + dx < min(edge1, edge2) &&
                        unit.y + dy >= 0 && unit.y + dy < max(edge1, edge2)
                    else { return }
                    walls.append((x1: unit.x, x2: unit.x + dx, y1: unit.y, y2: unit.y + dy))
                }
            }
        }
    }
    
    
    private func pickStartCoordinate() -> (x: Int, y: Int) {
        (x: Int.random(in: 0..<min(edge1, edge2)), y: Int.random(in: 0..<max(edge1, edge2)))
    }
}
