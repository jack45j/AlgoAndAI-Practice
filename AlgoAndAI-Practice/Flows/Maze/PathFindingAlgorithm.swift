//
//  PathFindingAlgorithm.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/18.
//

import Foundation

class DfsPathFinding: PathFindingOutput {
    var startPoint: Coordinate
    var destinationPoint: Coordinate
    var maze: [[MazeUnit]]
    
    var currentVertex: Vertex
    
    var paths: Vertex
    
    var visitedList: [Coordinate] = []
    var frontierList: [Vertex] = []
    
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
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] t in
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

protocol PathFindingOutput {
    var onPointDidVisit: ((Coordinate) -> Void)? { get set }
    var onFindedPath: (([Coordinate]) -> Void)? { get set }
}

import UIKit

class PathFindingAlgorithms: PathFindingOutput {
    
    var onPointDidVisit: ((Coordinate) -> Void)?
    var onFindedPath: (([Coordinate]) -> Void)?
    
    
    var maze: [[MazeUnit]]
    var startPoint: Coordinate
    var destinationPoint: Coordinate
    
    lazy var dfs = DfsPathFinding(mazeData: maze, startPoint: startPoint, destinationPoint: destinationPoint)
    
    init(maze: [[MazeUnit]], startPoint: Coordinate, destinationPoint: Coordinate) {
        self.maze = maze
        self.startPoint = startPoint
        self.destinationPoint = destinationPoint
    }
    
    func start() {
        startPathFinding()
    }
    
    private func startPathFinding() {
        dfs.onPointDidVisit = onPointDidVisit
        dfs.onFindedPath = onFindedPath
        dfs.start()
    }
}
