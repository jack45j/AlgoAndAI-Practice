//
//  DfsMazeGenerationViewController.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/1.
//

import UIKit
import Foundation

protocol MazeGeneratable {
    var maze: [[MazeUnit]] { get set }
    var width: Int { get }
    var height: Int { get }
}

struct MazeUnit: Hashable {
    enum WallDirection: CaseIterable {
        case top
        case bottom
        case left
        case right
    }
    let id = UUID()
    var x: Int = 0
    var y: Int = 0
    var isVisited = false
    var isMazeBorder = false
    var view: UIView? = nil
    var walls: [WallDirection: CALayer] = {
        var result: [WallDirection: CALayer] = [:]
        WallDirection.allCases.forEach {
            result[$0] = .init()
        }
        return result
    }()
}

class DfsMazeGenerationViewController: UIViewController, MazeGeneratable {
    
    var width = 25
    var height = 50
    
    let startPoint: (x: Int, y: Int) = (0, 1)
    lazy var finishPoint: (x: Int, y: Int) = (width - 1, height - 2)
    
    lazy var maze: [[MazeUnit]] = {
        var units: [[MazeUnit]] = []
        var column: [MazeUnit] = []
        for _ in 1...width {
            for _ in 1...height {
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
//        maze = Array(repeating: Array(repeating: MazeUnit(), count: height), count: width)
        self.view.backgroundColor = .white
        let maxWidth = min(view.frame.width - 60, view.frame.height - 60) / CGFloat(min(width, height))
        let maxHeight = max(view.frame.width - 60, view.frame.height - 60) / CGFloat(max(width, height))
        let unitSize = min(maxWidth, maxHeight)
        let center = CGPoint(x: view.frame.midX, y: view.frame.midY)
        
        for x in 0..<width {
            for y in 0..<height {
                let isBorder = x == 0 || x == width - 1 || y == 0 || y == height - 1
                let originPoint = CGPoint(x: center.x + CGFloat((width / 2) - width + x) * unitSize,
                                          y: center.y + CGFloat((height / 2) - height + y) * unitSize)
                let unitView = UIView(frame: .init(origin: originPoint, size: .init(width: unitSize, height: unitSize)))
                unitView.backgroundColor = isBorder ? .brown : .lightGray
                self.view.addSubview(unitView)
                maze[x][y].isMazeBorder = isBorder
                maze[x][y].view = unitView
                maze[x][y].x = x
                maze[x][y].y = y
                
                maze[x][y].walls.keys.forEach {
                    maze[x][y].walls[$0] = unitView.addBorder(toSide: $0, withColor: UIColor.black.cgColor)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        maze[startPoint.x][startPoint.y].view?.backgroundColor = .white
        breakWall(&maze, x: startPoint.x, y: startPoint.y, direction: .left)
        maze[finishPoint.x][finishPoint.y].view?.backgroundColor = .white
        maze[finishPoint.x][finishPoint.y].isMazeBorder = false
        breakWall(&maze, x: finishPoint.x, y: finishPoint.y, direction: .right)
        
        mazeStack.append(maze[startPoint.x][startPoint.y])
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            guard !self.mazeStack.isEmpty else { t.invalidate(); return }
            
            guard let x = self.mazeStack.last?.x,
                  let y = self.mazeStack.last?.y else { t.invalidate(); return }
            
            var available: [MazeUnit: MazeUnit.WallDirection] = [:]
            if let top = self.find(x: x, y: y, of: .top),
                !top.isMazeBorder,
                !self.mazeStack.map({ $0.id }).contains(top.id),
                !top.isVisited {
                
                available[top] = .top
            }
            
            if let bottom = self.find(x: x, y: y, of: .bottom),
                !bottom.isMazeBorder,
                !self.mazeStack.map({ $0.id }).contains(bottom.id),
                !bottom.isVisited {
                
                available[bottom] = .bottom
            }
            
            if let left = self.find(x: x, y: y, of: .left),
                !left.isMazeBorder,
                !self.mazeStack.map({ $0.id }).contains(left.id),
                !left.isVisited {
                
                available[left] = .left
            }
            
            if let right = self.find(x: x, y: y, of: .right),
                !right.isMazeBorder,
                !self.mazeStack.map({ $0.id }).contains(right.id),
                !right.isVisited {
                
                available[right] = .right
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

extension MazeGeneratable where Self: UIViewController {
    func find(x: Int, y: Int, of dir: MazeUnit.WallDirection) -> MazeUnit? {
        switch dir {
        case .top:
            guard y - 1 >= 0 else { return nil }
            return maze[x][y-1]
        case .bottom:
            guard y + 1 < height else { return nil }
            return maze[x][y+1]
        case .left:
            guard x - 1 >= 0 else { return nil }
            return maze[x-1][y]
        case .right:
            guard x + 1 < width else { return nil }
            return maze[x+1][y]
        }
    }
    
    func breakWall(_ maze: inout [[MazeUnit]], x: Int, y: Int, direction: MazeUnit.WallDirection) {
        maze[x][y].walls[direction]?.removeFromSuperlayer()
        maze[x][y].walls.removeValue(forKey: direction)
        
        switch direction {
        case .top:
            guard y - 1 >= 0 else { return }
            if !maze[x][y-1].isMazeBorder {
                maze[x][y-1].walls[.bottom]?.removeFromSuperlayer()
                maze[x][y-1].walls.removeValue(forKey: .bottom)
            }
        case .bottom:
            guard y + 1 < height else { return }
            if !maze[x][y+1].isMazeBorder {
                maze[x][y+1].walls[.top]?.removeFromSuperlayer()
                maze[x][y+1].walls.removeValue(forKey: .top)
            }
        case .left:
            guard x - 1 >= 0 else { return }
            if !maze[x-1][y].isMazeBorder {
                maze[x-1][y].walls[.right]?.removeFromSuperlayer()
                maze[x-1][y].walls.removeValue(forKey: .right)
            }
        case .right:
            guard x + 1 < width else { return }
            if !maze[x+1][y].isMazeBorder {
                maze[x+1][y].walls[.left]?.removeFromSuperlayer()
                maze[x+1][y].walls.removeValue(forKey: .left)
            }
        }
    }
}

extension UIView {
    
    @discardableResult
    func addBorder(toSide side: MazeUnit.WallDirection, withColor color: CGColor, andThickness thickness: CGFloat = 1) -> CALayer {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .left:
            border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: thickness, height: bounds.height)
        case .right:
            border.frame = CGRect(x: bounds.maxX, y: bounds.minY, width: thickness, height: bounds.height)
        case .top:
            border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: bounds.minX, y: bounds.maxY, width: bounds.width, height: thickness)
        }
        
        layer.addSublayer(border)
        return border
    }
}
