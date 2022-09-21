//
//  ACOViewController.swift
//  TSP-Practice
//
//  Created by 林翌埕-20001107 on 2022/9/19.
//

import Foundation
import UIKit

fileprivate typealias PheromoneRate = Float

struct Solution: Equatable {
    var placements: [Placement]
    var totalDistance: Float {
        var distance: Float = 0.0
        for idx in 0..<placements.count {
            if idx + 1 >= placements.count {
                distance += placements[idx].distance(to: placements[0])
            } else {
                distance += placements[idx].distance(to: placements[idx + 1])
            }
        }
        return distance
    }
}

class ACOViewController: UIViewController, PlacementGeneratable {
    
    // MARK: Population
    var PLACEMENT_COUNT: Int = 25
    lazy var placements: [Placement] = generatePlacement(PLACEMENT_COUNT)
    let ANT_COUNT: Int = 30
    let MAX_GENERATION: Int = 500
    
    // MARK: Pheromone
    let PHEROMONE_DROP_AMOUNT: Float = 0.005
    let EVAPORATE_RATE: Float = 0.2
    
    // MARK: Priority
    let PHEROMONE_PRIORITY = 1.0
    let DISTANCE_PRIORITY = 1.5
    
    // MARK: Threshold
    let IS_THRESHOLD_TO_STOP = true
    let THRESHOLD_GEN = 100
    
    var currentContinuouslyGen = 0
    
    // MARK: Variables
    private var routes: [Set<Placement>: PheromoneRate] = [:]
    var currentGen: Int = 0
    var currentBestSolution: Solution?
    
    var operation: OperationQueue? = OperationQueue()
    
    @IBOutlet weak var routeView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .white
        
        if let cachedPoints = try? UserDefaults.standard.get(objectType: [CGPoint].self, forKey: "Controller.Placements") {
            let cachedPlacements = cachedPoints.map { Placement(x: $0.x.toFloat, y: $0.y.toFloat) }
            
            let vc = UIAlertController(title: "Use Cached placements?", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Sure!", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.placements.forEach { $0.layer?.removeFromSuperlayer() }
                self.placements = cachedPlacements
                self.drawPlacements(self.placements)
                self.nextInteration()
            }
            
            let deniedAction = UIAlertAction(title: "Nope!", style: .cancel) { [weak self] _ in
                guard let self = self else { return }
                self.placements = self.generatePlacement(self.PLACEMENT_COUNT)
                try? UserDefaults.standard.set(object: self.placements.map { CGPoint(x: $0.x.toCGFloat, y: $0.y.toCGFloat) }, forKey: "Controller.Placements")
                
                self.nextInteration()
            }
            
            vc.addAction(okAction)
            vc.addAction(deniedAction)
            
            present(vc, animated: true)
        } else {
            try? UserDefaults.standard.set(object: self.placements.map { CGPoint(x: $0.x.toCGFloat, y: $0.y.toCGFloat) }, forKey: "Controller.Placements")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        operation?.cancelAllOperations()
        operation = nil
    }
    
    private func nextInteration() {
        print("[ACO] start Interation(\(currentGen))")
        currentGen += 1
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
                
                routes[Set([currentPlacement, nextPlacement])] = getPheromone(between: (currentPlacement, nextPlacement)) + PHEROMONE_DROP_AMOUNT
                
                currentPlacement = nextPlacement
                guard let idx = remainingPlacements.firstIndex(of: currentPlacement) else { fatalError() }
                _ = remainingPlacements.remove(at: idx)
            }
            solutions.append(solution)
            
            guard let startPlace = self.placements.first else { return }
            routes[Set([currentPlacement, startPlace])] = getPheromone(between: (currentPlacement, startPlace)) + PHEROMONE_DROP_AMOUNT
        }
        
        operation?.qualityOfService = .default
        for idx in 1...max(ANT_COUNT, PLACEMENT_COUNT) {
//            print("[ACO] start Ant(\(idx))")
            operation?.addBarrierBlock(nextAnt)
        }
        
        operation?.addBarrierBlock {
            if let currentBestSolution = self.currentBestSolution {
                let best = ([currentBestSolution] + solutions).sorted(by: { $0.totalDistance < $1.totalDistance }).first
                self.currentBestSolution = best
                if self.currentBestSolution == best {
                    self.currentContinuouslyGen += 1
                }
            } else {
                self.currentBestSolution = solutions.sorted(by: { $0.totalDistance < $1.totalDistance }).first
            }
        }
        
        guard currentGen <= MAX_GENERATION || !(IS_THRESHOLD_TO_STOP && currentContinuouslyGen >= THRESHOLD_GEN) else {
            operation?.cancelAllOperations()
            operation = nil
            return
        }
        
        guard operation != nil else { return }
        operation?.addBarrierBlock(updatePheromone)
        operation?.addBarrierBlock(nextInteration)
        
    }
    
    private func selectNextPlacement(from place: Placement, remaining: [Placement]) -> Placement {
        let distanceList = remaining.map { pow(1.0 / $0.distance(to: place), Float(DISTANCE_PRIORITY))  }
        
        let pheromoneList = remaining.map { pow(self.getPheromone(between: (place, $0)), Float(PHEROMONE_PRIORITY)) }
        
        let fitnessList = zip(distanceList, pheromoneList).map { $0.0 * $0.1 }
        
        return remaining[Selection.rouletteWheelSelectIndex(from: fitnessList, tournamemtSize: 1)]
    }
    
    
    
    private func getPheromone(between places: (place1: Placement, place2: Placement)) -> PheromoneRate {
        return routes[Set([places.place1, places.place2])] ?? 1.0
    }
    
    private func updatePheromone() {
        print("[ACO] start updatePheromone")
        for route in routes.keys {
            guard let _ = routes[route] else { fatalError() }
            routes[route]! *= 1.0 - EVAPORATE_RATE
        }
        drawRoutes()
    }
    
    private func drawRoutes() {
        let summaryPheromone = routes.reduce(0.0, { $0 + $1.value })
        
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
                DispatchQueue.main.async {
                    _ = [place1, place2].drawTourPath(isEnclosed: false, lineDash: [3,5], opacity: pheromone / summaryPheromone * Float(self.PLACEMENT_COUNT - 1), from: self.routeView)
                    self.routeView.layer.display()
                }
            }
        }
    }
}
