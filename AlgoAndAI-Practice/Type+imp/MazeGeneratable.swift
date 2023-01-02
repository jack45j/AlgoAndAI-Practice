//
//  MazeGeneratable.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/2.
//

import UIKit
import Foundation

protocol MazeGeneratable {
    var maze: [[MazeUnit]] { get set }
}

extension MazeGeneratable {
    func shortEdge() -> Int {
        min(maze.count, maze[0].count)
    }
    
    func longEdge() -> Int {
        max(maze.count, maze[0].count)
    }
}

extension MazeGeneratable where Self: UIViewController {
    func generateAndDrawInitializeMaze(in view: UIView, maze: inout [[MazeUnit]]) {
        let width = shortEdge()
        let height = longEdge()
        let maxWidth = min(view.bounds.width - 60, view.bounds.height - 60) / CGFloat(min(width, height))
        let maxHeight = max(view.bounds.width - 60, view.bounds.height - 60) / CGFloat(max(width, height))
        let unitSize = min(maxWidth, maxHeight)
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
        for x in 0..<width {
            for y in 0..<height {
                let isBorder = x == 0 || x == width - 1 || y == 0 || y == height - 1
                let originPoint = CGPoint(x: center.x + CGFloat((width / 2) - width + x) * unitSize,
                                          y: center.y + CGFloat((height / 2) - height + y) * unitSize)
                let unitView = UIView(frame: .init(origin: originPoint, size: .init(width: unitSize, height: unitSize)))
                unitView.backgroundColor = .lightGray
                view.addSubview(unitView)
                maze[x][y].isMazeBorder = isBorder
                maze[x][y].view = unitView
                maze[x][y].coordinate = .init(x: x, y: y)
                
                maze[x][y].walls.keys.forEach {
                    maze[x][y].walls[$0] = unitView.addBorder(toSide: $0, withColor: UIColor.black.cgColor)
                }
            }
        }
    }
    
    func find(x: Int, y: Int, of dir: Direction) -> MazeUnit? {
        switch dir {
        case .north:
            guard y - 1 >= 0 else { return nil }
            return maze[x][y-1]
        case .south:
            guard y + 1 < longEdge() else { return nil }
            return maze[x][y+1]
        case .west:
            guard x - 1 >= 0 else { return nil }
            return maze[x-1][y]
        case .east:
            guard x + 1 < shortEdge() else { return nil }
            return maze[x+1][y]
            
        default: return nil
        }
    }
    
    func breakWall(in maze: inout [[MazeUnit]], between units: (first: MazeUnit, second: MazeUnit)) {
        if units.first.x == units.second.x {
            // Same column
            if units.first.y < units.second.y {
                breakWall(&maze, x: units.first.x, y: units.first.y, direction: .south)
            } else {
                breakWall(&maze, x: units.first.x, y: units.first.y, direction: .north)
            }
        } else if units.first.y == units.second.y {
            // Same Row
            if units.first.x < units.second.x {
                breakWall(&maze, x: units.first.x, y: units.first.y, direction: .east)
            } else {
                breakWall(&maze, x: units.first.x, y: units.first.y, direction: .west)
            }
        } else {
            fatalError()
        }
    }
    
    func breakWall(_ maze: inout [[MazeUnit]], x: Int, y: Int, direction: Direction) {
        maze[x][y].walls[direction]?.removeFromSuperlayer()
        maze[x][y].walls.removeValue(forKey: direction)
        
        switch direction {
        case .north:
            guard y - 1 >= 0 else { return }
//            if !maze[x][y-1].isMazeBorder {
                maze[x][y-1].walls[.south]?.removeFromSuperlayer()
                maze[x][y-1].walls.removeValue(forKey: .south)
//            }
        case .south:
            guard y + 1 < longEdge() else { return }
//            if !maze[x][y+1].isMazeBorder {
                maze[x][y+1].walls[.north]?.removeFromSuperlayer()
                maze[x][y+1].walls.removeValue(forKey: .north)
//            }
        case .west:
            guard x - 1 >= 0 else { return }
//            if !maze[x-1][y].isMazeBorder {
                maze[x-1][y].walls[.east]?.removeFromSuperlayer()
                maze[x-1][y].walls.removeValue(forKey: .east)
//            }
        case .east:
            guard x + 1 < shortEdge() else { return }
//            if !maze[x+1][y].isMazeBorder {
                maze[x+1][y].walls[.west]?.removeFromSuperlayer()
                maze[x+1][y].walls.removeValue(forKey: .west)
//            }
            
        default: return
        }
    }
}
