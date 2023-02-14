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
    private lazy var finding = PathFindingAlgorithms(maze: self.maze, startPoint: startPoint, destinationPoint: endPoint, algo: .astar)
    private lazy var generator = PrimMazeGenerator<CustomMazeUnit>(config: config)
    private lazy var startPoint = generator.startPoint()
    private lazy var endPoint = generator.endPoint()
    
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
        mazeView[unit.x][unit.y].backgroundColor = .white
    }
    
    func didFinishGenerated(maze: [[CustomMazeUnit]]) {
        self.maze = maze
        self.mazeView[startPoint.x][startPoint.y].backgroundColor = .blue
        self.mazeView[endPoint.x][endPoint.y].backgroundColor = .brown
        
        finding.onPointDidVisit = { coordinate in
            if coordinate == self.startPoint || coordinate == self.endPoint {
                return
            }
            self.mazeView[coordinate.x][coordinate.y].backgroundColor = .green
        }
        
        finding.onFindedPath = { path in
            path.enumerated().forEach { (offset, element) in
                if offset == 0 || offset == path.count - 1 {
                    return
                }
                UIView.animate(withDuration: 0.1, delay: 0.01 * Double(offset)) {
                    self.mazeView[element.x][element.y].backgroundColor = .red
                }
            }
        }
        
        finding.start()
    }
}

protocol MazeGenerationAlgorithmDelegate<MazeUnit> {
    associatedtype MazeUnit: MazeUnitType
    func didInit(maze: [[MazeUnit]])
    func didGeneratedUnit(unit: MazeUnit)
    func didFinishGenerated(maze: [[MazeUnit]])
}

extension MazeGenerationAlgorithm {
    var directions: [(dx: Int, dy: Int)] {
        return [(0, -1), (1, 0), (0, 1), (-1, 0),]
    }
}

