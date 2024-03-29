//
//  PathFindingAlgorithm.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/18.
//

import UIKit
import Foundation

protocol PathFindingOutput {
    var onPointDidVisit: ((Coordinate) -> Void)? { get set }
    var onFindedPath: (([Coordinate]) -> Void)? { get set }
}

protocol PathFindingDelegate {
    func didVisitUnit(_ coordinate: Coordinate)
    func didFindPath(_ path: [Coordinate])
}

class PathFindingAlgorithms: PathFindingOutput {
    
    enum PathFindingAlgorithm {
        case dfs
        case astar
    }
    
    var delegate: PathFindingDelegate?
    
    var onPointDidVisit: ((Coordinate) -> Void)?
    var onFindedPath: (([Coordinate]) -> Void)?
    
    
    var maze: [[any MazeUnitType]]
    var startPoint: Coordinate
    var destinationPoint: Coordinate
    
    var algo: PathFindingAlgorithm
    
//    lazy var dfs = DfsPathFinding(mazeData: maze, startPoint: startPoint, destinationPoint: destinationPoint)
    lazy var aStar = AStarPathFinding(mazeData: maze, startPoint: startPoint, destinationPoint: destinationPoint)
    
    init(maze: [[any MazeUnitType]], startPoint: Coordinate, destinationPoint: Coordinate, algo: PathFindingAlgorithm) {
        self.maze = maze
        self.startPoint = startPoint
        self.destinationPoint = destinationPoint
        self.algo = algo
    }
    
    func start() {
        switch algo {
        case .dfs: return
//            startDfsPathFinding()
        case .astar:
            startAStarPathFinding()
        }
    }
    
//    private func startDfsPathFinding() {
//        dfs.onPointDidVisit = onPointDidVisit
//        dfs.onFindedPath = onFindedPath
//        dfs.start()
//    }
    
    private func startAStarPathFinding() {
        aStar.onPointDidVisit = onPointDidVisit
        aStar.onFindedPath = onFindedPath
        aStar.start()
    }
}
