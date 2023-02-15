//
//  DfsMazeGenerationViewController.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/1.
//

import UIKit
import Reusable
import Foundation

class DfsMazeGenerationViewController: UIViewController, ConfigurableType, MazeGeneratable {
    
    class func instantiate(config: MazeSizeGenerationConfigurations) -> DfsMazeGenerationViewController {
        let viewController = DfsMazeGenerationViewController()
        viewController.config = config
        return viewController
    }
    
//    private static func instantiate() -> Self {
//        guard let dfsViewController = sceneStoryboard.instantiateInitialViewController() as? Self else {
//            fatalError()
//        }
//        return dfsViewController
//    }
    
    var mazeView: [[UIView]] = []
    var maze: [[any MazeUnitType]] = []
    
    var config: MazeSizeGenerationConfigurations! = .init()
    private lazy var finding = PathFindingAlgorithms(maze: self.maze, startPoint: startPoint, destinationPoint: endPoint, algo: .astar)
    private lazy var generator = DfsMazeGenerator<CustomMazeUnit>(config: config)
    private lazy var startPoint = generator.startPoint()
    private lazy var endPoint = generator.endPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generator.delegate = self
        generator.start()
        self.view.backgroundColor = .white
    }
}

extension DfsMazeGenerationViewController: DfsMazeGenerationAlgorithmDelegate {
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
        self.mazeView[startPoint.x][startPoint.y].backgroundColor = .red
        self.mazeView[endPoint.x][endPoint.y].backgroundColor = .green
        
        finding.onPointDidVisit = { coordinate in
            if coordinate == self.startPoint || coordinate == self.endPoint {
                return
            }
            self.mazeView[coordinate.x][coordinate.y].backgroundColor = .orange.withAlphaComponent(0.2)
        }
        
        finding.onFindedPath = { path in
            path.enumerated().forEach { (offset, element) in
                if offset == 0 || offset == path.count - 1 {
                    return
                }
                UIView.animate(withDuration: 0.1, delay: 0.01 * Double(offset)) {
                    self.mazeView[element.x][element.y].backgroundColor = UIColor.purple.withAlphaComponent(0.4)
                }
            }
        }
        
        finding.start()
    }
    
    func didPassThrough(unit: CustomMazeUnit) {
        mazeView[unit.x][unit.y].drawBorder(unit, withColor: UIColor.black.cgColor)
        mazeView[unit.x][unit.y].backgroundColor = .lightGray.withAlphaComponent(0.3)
    }
}

//final class DfsMazeGenerator<MazeUnit: MazeUnitType>: MazeSizeConfigurable & MazeGenerationAlgorithm {
//    var edge1: Int
//    var edge2: Int
//    var isRandomStartAndDestination: Bool
//
//    var onInitMaze: (([[MazeUnit]]) -> Void)?
//    var onGeneratedUnit: ((MazeUnit) -> Void)?
//    var onFinishMaze: (([[MazeUnit]]) -> Void)?
//
//    init(edge1: Int, edge2: Int, isRandomStartAndDestination: Bool) {
//        self.edge1 = edge1
//        self.edge2 = edge2
//        self.isRandomStartAndDestination = isRandomStartAndDestination
//    }
//
//    func start() {
//
//    }
//}
