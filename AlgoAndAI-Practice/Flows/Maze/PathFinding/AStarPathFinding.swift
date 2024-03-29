//
//  AStarPathFinding.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/19.
//

import Foundation

class Vertex {
    var id: UUID = .init()
    var coordinate: Coordinate
    var isVisited: Bool = false
    var adjacent = [Vertex]()
    var depth: Int
    var parentNode: Vertex?
    
    init(coordinate: Coordinate, adjacent: [Vertex] = [Vertex](), depth: Int, parentNode: Vertex? = nil) {
        self.coordinate = coordinate
        self.adjacent = adjacent
        self.depth = depth
        self.parentNode = parentNode
    }
}

class AStarPathFinding: PathFindingOutput {
    var startPoint: Coordinate
    var destinationPoint: Coordinate
    var maze: [[any MazeUnitType]]
    
    var currentVertex: Vertex
    
    var visitedList: [Coordinate] = []
    var frontierList: [Vertex] = []
    
    var onPointDidVisit: ((Coordinate) -> Void)?
    var onFindedPath: (([Coordinate]) -> Void)?
    
    init(mazeData: [[any MazeUnitType]], startPoint: Coordinate, destinationPoint: Coordinate) {
        self.maze = mazeData
        self.startPoint = startPoint
        self.destinationPoint = destinationPoint
        self.currentVertex = .init(coordinate: startPoint, depth: 0)
    }
    
    func visit(_ vertex: Vertex) {
        frontierList.append(vertex)
        visitedList.append(vertex.coordinate)
        vertex.isVisited = true
    }
    
    private func estimatedCost(_ coordinate: Coordinate) -> Int {
        return abs(destinationPoint.x - coordinate.x) + abs(destinationPoint.y - coordinate.y)
    }
    
    func start() {
        // findingDirectionOrder
        let findingDirections: [Direction] = Direction.fourDirections
//        let findingDirections: [Direction] = Coordinate.findDirection(start: startPoint, dest: destinationPoint).fourDirections
        
        // start point
        visit(currentVertex)
        onPointDidVisit?(currentVertex.coordinate)
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [unowned self] t in
            self.frontierList = self.frontierList.sorted(by: { ($0.depth + self.estimatedCost($0.coordinate)) < ($1.depth + self.estimatedCost($1.coordinate)) })
            
            guard let frontier = self.frontierList.first else { fatalError() }
            
            self.currentVertex = frontier
            self.frontierList.removeFirst(1)
            
            for direction in findingDirections {
                guard let unit = self.maze.move(from: self.currentVertex.coordinate, to: direction) else { continue }
                let currentCoordinate = Coordinate(x: unit.x, y: unit.y)
                if !self.visitedList.contains(currentCoordinate) {
                    let vertex = Vertex(coordinate: currentCoordinate, depth: self.currentVertex.depth + 1)
                    vertex.parentNode = self.currentVertex
                    self.currentVertex.adjacent.append(vertex)
                    self.visit(vertex)
                    self.onPointDidVisit?(vertex.coordinate)
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
