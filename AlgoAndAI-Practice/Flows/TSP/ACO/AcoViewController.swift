//
//  AcoViewController.swift
//  AlgoAndAI-Practice
//
//  Created by Benson Lin on 2022/9/19.
//

import Foundation
import Reusable
import UIKit

fileprivate typealias PheromoneRate = Double

final class AcoViewController: UIViewController, ConfigurableType, AcoViewControllerOutput, PlacementGeneratable {
    
    var onFinish: (() -> Void)?
    
    class func instantiate(config: ACOConfigurations) -> AcoViewController {
        let viewController = AcoViewController()
        viewController.config = config
        return viewController
    }
    
    typealias T = ACOConfigurations
    var config: T!
    
    var placements: [Placement] = []
    
    // MARK: Variables
    private var routes: [Set<Placement>: PheromoneRate] = [:]
    var currentGen: Int = 0
    var currentBestSolution: Solution?
    
    var operation: OperationQueue? = OperationQueue()
    
    lazy var routeView: UIView = {
        let view = UIView(frame: .zero)
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if config.USE_PENTAGON {
            self.placements = generagePentagon()
            self.drawPlacements(self.placements)
            self.nextInteration()
            return
        }
        
        if config.USE_PREVIOUS {
            guard let cachedPoints = try? UserDefaults.standard.get(objectType: [CGPoint].self, forKey: "Controller.Placements") else { fatalError() }
            let cachedPlacements = cachedPoints.map { Placement(x: $0.x.toFloat, y: $0.y.toFloat) }
            self.placements.forEach { $0.layer?.removeFromSuperlayer() }
            self.placements = cachedPlacements
            self.drawPlacements(self.placements)
            self.nextInteration()
        } else {
            let placements = generatePlacement(config.PLACEMENT_COUNT)
            self.placements = placements
            try? UserDefaults.standard.set(object: self.placements.map { CGPoint(x: $0.x.toCGFloat, y: $0.y.toCGFloat) }, forKey: "Controller.Placements")
            self.nextInteration()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        operation?.cancelAllOperations()
        operation = nil
        onFinish?()
    }
    
    private func nextInteration() {
        currentGen += 1
        print("[ACO] start Interation(\(currentGen))")
        var solutions: [Solution] = []
        
        func nextAnt() {
            var solution = Solution(placements: [])
            var remainingPlacements = placements
            var currentPlacement = remainingPlacements[0]
            remainingPlacements.removeFirst()
            
            solution.placements.append(currentPlacement)
            
            while !remainingPlacements.isEmpty {
                let nextPlacement = selectNextPlacement(from: currentPlacement, remaining: remainingPlacements)
                solution.placements.append(nextPlacement)
                
                currentPlacement = nextPlacement
                guard let idx = remainingPlacements.firstIndex(of: currentPlacement) else { fatalError() }
                _ = remainingPlacements.remove(at: idx)
            }
            solutions.append(solution)
        }
        
        operation?.qualityOfService = .default
        for _ in 1...max(config.ANT_COUNT, config.PLACEMENT_COUNT) {
            operation?.addBarrierBlock(nextAnt)
        }
        
        // Pick out the best
        operation?.addBarrierBlock {
            if let currentBestSolution = self.currentBestSolution {
                let best = ([currentBestSolution] + solutions).sorted(by: { $0.totalDistance < $1.totalDistance }).first
                self.currentBestSolution = best
            } else {
                self.currentBestSolution = solutions.sorted(by: { $0.totalDistance < $1.totalDistance }).first
            }
        }
        
        operation?.addBarrierBlock{
            self.updatePheromone(solutions: solutions)
        }
        
        // Draw
        guard currentGen <= config.MAX_GENERATION else {
            operation?.cancelAllOperations()
            operation = nil
            DispatchQueue.main.async {
                let vc = UIAlertController(title: "Reached Max Generation. \(self.currentBestSolution?.totalDistance ?? 0.0)", message: nil, preferredStyle: .alert)
                self.present(vc, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    vc.dismiss(animated: true)
                }

                if let currentBestRoute = self.currentBestSolution?.placements {
                    self.routeView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                    _ = currentBestRoute.drawTourPath(isFinal: true, from: self.routeView)
                    self.view.setNeedsDisplay()
                    self.view.layer.display()
                }
            }
            return
        }
        
        guard operation != nil else { return }
        operation?.addBarrierBlock(nextInteration)
        
    }
    
    private func selectNextPlacement(from place: Placement, remaining:  [Placement]) -> Placement {
        let distanceList = remaining.map { pow(1.0 / Double($0.distance(to: place)), Double(config.DISTANCE_PRIORITY)) }
        
        let pheromoneList = remaining.map { pow(self.getPheromone(between: (place, $0)), Double(config.PHEROMONE_PRIORITY)) }
        
        let fitnessList = zip(distanceList, pheromoneList).map { $0.0 * $0.1 }
        
        switch config.SELECTION {
        case .rouletteWheel(let pickSize):
            guard let index = Selections.rouletteWheelSelect(from: fitnessList, tournamemtSize: pickSize)?.index else { fatalError() }
            return remaining[index]
        }
    }
    
    
    
    private func getPheromone(between places: (place1: Placement, place2: Placement)) -> PheromoneRate {
        return routes[Set([places.place1, places.place2])] ?? config.PHEROMONE_Q_AMOUNT
    }
    
    private func updatePheromone(solutions: [Solution]) {
        for route in routes.keys {
            guard let _ = routes[route] else { fatalError() }
            routes[route]! *= 1.0 - config.EVAPORATE_RATE
        }
        
        for solution in solutions {
            var leftIdx = 0
            var rightIdx = 1
            
            while leftIdx < rightIdx {
                let placeA = solution.placements[leftIdx]
                let placeB = solution.placements[rightIdx]
                let route = Set([placeA, placeB])
                let solutiontau = Double(config.PLACEMENT_COUNT) * 2.0 * config.PHEROMONE_Q_AMOUNT / Double(solution.totalDistance)
                routes[route] = getPheromone(between: (place1: placeA, place2: placeB)) + solutiontau
                
                if leftIdx == 0 && rightIdx == solution.placements.count - 1 {
                    break
                }
                
                leftIdx += 1
                rightIdx += 1
                if rightIdx >= solution.placements.count {
                    rightIdx -= 1
                    leftIdx = 0
                }
            }
        }
        
        drawRoutes()
    }
    
    private func drawRoutes() {
        let totalPheromone = routes.values.reduce(0.0, +)
        
        DispatchQueue.main.async {
            self.routeView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            _ = self.currentBestSolution?.placements.drawTourPath(isFinal: true, opacity: 0.6, from: self.routeView)
        }
        for idx in 0..<self.placements.count {
            for idxR in idx+1 ..< self.placements.count {
                guard idx < idxR else { break }
                
                let place1 = self.placements[idx]
                let place2 = self.placements[idxR]
                let pheromone = self.getPheromone(between: (place1, place2))
                let opacity = pheromone / totalPheromone * Double(self.config.PLACEMENT_COUNT)
                
                DispatchQueue.main.async {
                    _ = [place1, place2].drawTourPath(isEnclosed: false, lineDash: [3,5], opacity: min(0.75, Float(opacity)), from: self.routeView)
                }
            }
        }
    }
}
