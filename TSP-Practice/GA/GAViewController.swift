//
//  GAViewController.swift
//  TSP-Practice
//
//  Created by Benson Lin on 2022/9/18.
//

import UIKit

fileprivate typealias Population = [Chromosome]

enum GeneticSelectionType {
    case rouletteWheel
    case tournament
}

class GAViewController: UIViewController, PlacementGeneratable {
    
    // MARK: Population
    var PLACEMENT_COUNT = 125
    var POPULATION_SIZE = 50
    let MAX_GENERATION: Int = 500
    
    private var population: Population = []
    lazy var placements: [Placement] = generatePlacement(PLACEMENT_COUNT)
    var currentGen: Int = 0
    
    // MARK: Selection
    let TOURNAMENT_PICK_SIZE = 5
    let ELITE_PERCENT_TO_PRESERVE: Float = 0.05
    
    // MARK: Mutation
    let MUTATE_RATE: Float = 0.01
    let IS_MUTATE_PRESSURE = true
    
    lazy var offsetMutateRate = MUTATE_RATE
    
    
    // MARK: Threshold
    let IS_THRESHOLD_TO_STOP = true
    let THRESHOLD_GEN = 100
    
    var currentContinuouslyGen = 0
    
    // MARK: Variables
    var currentBestChromosome: Chromosome?
    var operation: OperationQueue? = OperationQueue()
    
    // MARK: IBOutlet
    @IBOutlet weak var routeView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = .white
        
        if let cachedPoints = try? UserDefaults.standard.get(objectType: [CGPoint].self, forKey: "Controller.Placements") {
            let cachedPlacements = cachedPoints.map { Placement(x: $0.x.toFloat, y: $0.y.toFloat) }
            
            let vc = UIAlertController(title: "Use Cached placements?", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Sure!", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.PLACEMENT_COUNT = cachedPlacements.count
                self.placements.forEach { $0.layer?.removeFromSuperlayer() }
                self.placements = cachedPlacements
                self.drawPlacements(self.placements)
                self.startAlgo()
            }
            
            let deniedAction = UIAlertAction(title: "Nope!", style: .cancel) { [weak self] _ in
                guard let self = self else { return }
                self.placements = self.generatePlacement(self.PLACEMENT_COUNT)
                try? UserDefaults.standard.set(object: self.placements.map { CGPoint(x: $0.x.toCGFloat, y: $0.y.toCGFloat) }, forKey: "Controller.Placements")
                
                self.startAlgo()
            }
            
            vc.addAction(okAction)
            vc.addAction(deniedAction)
            
            present(vc, animated: true)
        } else {
            try? UserDefaults.standard.set(object: self.placements.map { CGPoint(x: $0.x.toCGFloat, y: $0.y.toCGFloat) }, forKey: "Controller.Placements")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        operation?.cancelAllOperations()
        operation = nil
    }
    
    private func startAlgo() {
        
        func nextGen() {
            currentGen += 1
            print("[CreateGen\(currentGen)]")
            self.population = self.createNextGeneration(prevPopulation: self.population)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let currentBestRoute = self.currentBestChromosome?.placements {
                    self.routeView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                    _ = currentBestRoute.drawTourPath(from: self.routeView)
                    self.view.bringSubviewToFront(self.routeView)
                    self.view.setNeedsDisplay()
                    self.view.layer.display()
                }
            }
            
            if self.currentContinuouslyGen >= self.THRESHOLD_GEN && self.IS_THRESHOLD_TO_STOP || currentGen >= MAX_GENERATION {
                self.operation?.cancelAllOperations()
                self.operation = nil
                DispatchQueue.main.async {
                    let vc = UIAlertController(title: "Reached Max Generation.", message: nil, preferredStyle: .alert)
                    self.present(vc, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        vc.dismiss(animated: true)
                    }

                    if let currentBestRoute = self.currentBestChromosome?.placements {
                        self.routeView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                        _ = currentBestRoute.drawTourPath(isFinal: true, from: self.routeView)
                        self.view.setNeedsDisplay()
                        self.view.layer.display()
                    }
                }
            }
            
            if operation != nil {
                operation?.addBarrierBlock {
                    nextGen()
                }
            }
        }
        
        
        let initBlock = BlockOperation { [weak self] in
            guard let self = self else { return }
            self.population = self.initializePopulation()
            nextGen()
        }
        
        let operationBlock = BlockOperation(block: nextGen)
        operationBlock.qualityOfService = .default
        operationBlock.addDependency(initBlock)
        
        operation?.addOperations([initBlock, operationBlock], waitUntilFinished: false)
    }
    
    private func initializePopulation() -> Population {
        var population: Population = []
        for _ in 1...POPULATION_SIZE {
            population.append(Chromosome(placements: placements.shuffled()))
        }
        
        currentBestChromosome = population.sorted(by: { $0.totalDistance < $1.totalDistance }).first
        
        return population
    }
    
    private func createNextGeneration(prevPopulation: Population) -> Population {
        
        // 1. Preserve elites from previous population
        var nextGen: Population = [] + prevPopulation.getElite(ELITE_PERCENT_TO_PRESERVE)
        
        for _ in 1...POPULATION_SIZE - nextGen.count {

            let chromosome1 = select(.tournament, from: prevPopulation, tournamemtSize: TOURNAMENT_PICK_SIZE)
            let chromosome2 = select(.tournament, from: prevPopulation, tournamemtSize: TOURNAMENT_PICK_SIZE)

            var newChromosome = crossOver(chromosome1, chromosome2)

            mutateIfNeeded(&newChromosome, mutateRate: MUTATE_RATE, isRandomMutation: true)

            nextGen.append(newChromosome)
        }

        for idx in 0 ..< nextGen.count {
            nextGen[idx].isElite = false
        }
        let nextGenBest = nextGen.sorted(by: { $0.totalDistance < $1.totalDistance }).first

        if currentBestChromosome?.placements.map({ $0.id }) == nextGenBest?.placements.map({ $0.id }) {
            currentContinuouslyGen += 1
        } else {
            currentContinuouslyGen = 0
        }

        currentBestChromosome = nextGenBest

        return nextGen
    }
    
   private func select(_ type: GeneticSelectionType, from population: Population, tournamemtSize: Int) -> Chromosome {
        switch type {
        case .rouletteWheel:
            return population[Selection.rouletteWheelSelectIndex(from: population.filter { $0.isElite == false }.map { 1.0 / $0.totalDistance }, tournamemtSize: tournamemtSize)]
        case .tournament:
            return tournamentSelect(from: population, tournamemtSize: tournamemtSize)
        }
    }
    
    private func tournamentSelect(from population: Population, tournamemtSize: Int) -> Chromosome {
        let notElite = population.filter { $0.isElite == false }
        var selection: [Int] = []
        
        while selection.count < tournamemtSize {
            let randomPick = Int.random(in: 0..<notElite.count)
            if !selection.contains(randomPick) {
                selection.append(randomPick)
            }
        }
        
        guard let best = selection.map({ notElite[$0] }).sorted(by: { $0.totalDistance < $1.totalDistance }).first else { fatalError() }
        return best
    }
    
    func crossOver(_ lChromosome: Chromosome, _ rChromosome: Chromosome) -> Chromosome {
        let crossOverPointLeft = Int.random(in: 0...Int(Double(PLACEMENT_COUNT)/2.rounded(.down)))
        let crossOverPointRight = Int.random(in: Int(Double(PLACEMENT_COUNT)/2.rounded(.down))...PLACEMENT_COUNT-1)
        
        let tempPlacementsGene: [Placement] = Array(lChromosome.placements[crossOverPointLeft...crossOverPointRight])
        
        let diffPlacementsGene: [Placement] = rChromosome.placements.filter { !tempPlacementsGene.contains($0) }
        
        return Chromosome(placements: Array(diffPlacementsGene[0..<crossOverPointLeft]) + tempPlacementsGene + Array(diffPlacementsGene[crossOverPointLeft..<diffPlacementsGene.count]))
    }
    
    func mutateIfNeeded(_ chromosome: inout Chromosome, mutateRate: Float, isRandomMutation: Bool = true) {
        
        let dice = Float.random(in: 0...1)
        
        let mutateRate = IS_MUTATE_PRESSURE ? offsetMutateRate : MUTATE_RATE
        
        guard dice <= mutateRate else {
            offsetMutateRate += (1.0 / Float(THRESHOLD_GEN)) * MUTATE_RATE
            return
        }
        
        if isRandomMutation {
            switch Int.random(in: 1...3) {
            case 1:
                chromosome.swapMutate()
            case 2:
                chromosome.inversionMutate()
            case 3:
                chromosome.scrambleMuate()
            default:
                chromosome.inversionMutate()
            }
        } else {
            chromosome.swapMutate()
        }
    }
}
