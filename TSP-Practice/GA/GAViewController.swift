//
//  GAViewController.swift
//  TSP-Practice
//
//  Created by Benson Lin on 2022/9/18.
//

import UIKit

enum GeneticSelectionType {
    case rouletteWheel
    case tournament
}

class GAViewController: UIViewController, PlacementGeneratable {
    
    var PLACEMENT_COUNT = 15
    var POPULATION_SIZE = 40
    let TOURNAMENT_PICK_SIZE = 15
    let MUTATE_RATE: Float = 0.005
    let ELITE_PERCENT_TO_PRESERVE: Float = 0.05
    let MAX_GENERATION: Int = 150
    lazy var offsetMutateRate = MUTATE_RATE
    
    let IS_MUTATE_PRESSURE = true
    let IS_THRESHOLD_TO_STOP = true
    let THRESHOLD_GEN = 100
    var currentContinuouslyGen = 0
    
    lazy var placements: [Placement] = generatePlacement(PLACEMENT_COUNT)
    var population: Population = []
    var currentBestChromosome: Chromosome?
    var routeLayers: [CALayer] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = .white
        
        if let cachedPoints = try? UserDefaults.standard.get(objectType: [CGPoint].self, forKey: "GAController.Placements") {
            let cachedPlacements = cachedPoints.map { Placement(x: $0.x.toFloat, y: $0.y.toFloat) }
            
            let vc = UIAlertController(title: "Use Cached placements?", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Sure!", style: .default) { _ in
                self.placements.forEach { $0.layer?.removeFromSuperlayer() }
                self.placements = cachedPlacements
                self.drawPlacements(self.placements)
                self.startAlgo()
            }
            
            let deniedAction = UIAlertAction(title: "Nope!", style: .cancel) { _ in
                self.placements = self.generatePlacement(self.PLACEMENT_COUNT)
                try? UserDefaults.standard.set(object: self.placements.map { CGPoint(x: $0.x.toCGFloat, y: $0.y.toCGFloat) }, forKey: "GAController.Placements")
                
                self.startAlgo()
            }
            
            vc.addAction(okAction)
            vc.addAction(deniedAction)
            
            present(vc, animated: true)
        } else {
            try? UserDefaults.standard.set(object: self.placements.map { CGPoint(x: $0.x.toCGFloat, y: $0.y.toCGFloat) }, forKey: "GAController.Placements")
        }
    }
    
    private func startAlgo() {
        population = initializePopulation()
        
        DispatchQueue.global(qos: .default).async {
            for idx in 1...self.MAX_GENERATION {
                print("[CreateGen\(idx)]")
                self.population = self.createNextGeneration(prevPopulation: self.population)
                
                DispatchQueue.main.async {
                    if let currentBestRoute = self.currentBestChromosome?.placements {
                        self.routeLayers.forEach { $0.removeFromSuperlayer() }
                        self.routeLayers = currentBestRoute.drawTourPath(from: self.view)
                        self.view.setNeedsDisplay()
                        self.view.layer.display()
                    }
                }
                
                if self.currentContinuouslyGen >= self.THRESHOLD_GEN && self.IS_THRESHOLD_TO_STOP {
                    break
                }
            }
            
            DispatchQueue.main.async {
                let vc = UIAlertController(title: "Reached Max Generation.", message: nil, preferredStyle: .alert)
                self.present(vc, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    vc.dismiss(animated: true)
                }
                
                if let currentBestRoute = self.currentBestChromosome?.placements {
                    self.routeLayers.forEach { $0.removeFromSuperlayer() }
                    self.routeLayers = currentBestRoute.drawTourPath(isFinal: true, from: self.view)
                    self.view.setNeedsDisplay()
                    self.view.layer.display()
                }
            }
        }
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
            
            let chromosome1 = select(.rouletteWheel, from: prevPopulation, tournamemtSize: TOURNAMENT_PICK_SIZE)
            let chromosome2 = select(.rouletteWheel, from: prevPopulation, tournamemtSize: TOURNAMENT_PICK_SIZE)
            
            var newChromosome = crossOver(chromosome1, chromosome2)
            
            mutateIfNeeded(&newChromosome, mutateRate: MUTATE_RATE)
            
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
    
    func select(_ type: GeneticSelectionType, from population: Population, tournamemtSize: Int) -> Chromosome {
        switch type {
        case .rouletteWheel:
            return rouletteWheelSelect(from: population, tournamemtSize: tournamemtSize)
        case .tournament:
            return tournamentSelect(from: population, tournamemtSize: tournamemtSize)
        }
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
            chromosome.inversionMutate()
        }
    }
    
    private func rouletteWheelSelect(from population: Population, tournamemtSize: Int) -> Chromosome {
        let notElite = population.filter { $0.isElite == false }
        let summaryDistance = notElite.reduce(0.0, { $0 + $1.totalDistance })
        let percentageList = notElite.map {
            var percent = 100 * $0.totalDistance / summaryDistance
            percent = 100.0 / Float(POPULATION_SIZE) + ((100.0 / Float(POPULATION_SIZE)) - percent)
            return (percent: percent, distance: $0.totalDistance)
        }
        
        var tournamemtChromosomes: Population = []
        for _ in 1...tournamemtSize {
            let randomNumber = Float.random(in: 0...100)
            
            for idx in 0..<percentageList.count {
                if percentageList[0...idx].reduce(0.0, { $0 + $1.percent }) >= randomNumber {
                    tournamemtChromosomes.append(population[idx])
                    break
                } else {
                    continue
                }
            }
        }
        
        guard let best = tournamemtChromosomes.sorted(by: { $0.totalDistance < $1.totalDistance }).first else { fatalError() }
        return best
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
}

extension UserDefaults {

    /// Set Codable object into UserDefaults
    ///
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    /// - Throws: UserDefaults Error
    internal func set<T: Codable>(object: T, forKey: String) throws {

        let jsonData = try JSONEncoder().encode(object)

        set(jsonData, forKey: forKey)
    }

    /// Get Codable object into UserDefaults
    ///
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    /// - Throws: UserDefaults Error
    internal func get<T: Codable>(objectType: T.Type, forKey: String) throws -> T? {

        guard let result = value(forKey: forKey) as? Data else {
            return nil
        }

        return try JSONDecoder().decode(objectType, from: result)
    }
}
