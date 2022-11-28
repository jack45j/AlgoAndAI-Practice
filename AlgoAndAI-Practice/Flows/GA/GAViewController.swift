//
//  GAViewController.swift
//  AlgoAndAI-Practice
//
//  Created by Benson Lin on 2022/9/18.
//

import UIKit
import Reusable

fileprivate typealias Population = [Chromosome]

class GAViewController: UIViewController, StoryboardBased, ConfigurableType, PlacementGeneratable, GAViewControllerOutput {
    
    var onFinish: (() -> Void)?
    
    class func instantiate(config: GAConfigurations) -> GAViewController {
        let viewController = GAViewController()
        viewController.config = config
        return viewController
    }
    
    private var population: Population = []
    lazy var placements: [Placement] = []
    var currentGen: Int = 0
    
    typealias T = GAConfigurations
    var config: T!
    
    // MARK: Variables
    var currentBestChromosome: Chromosome?
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
        print("[GA] start Generation(\(currentGen))")
        
        // Gen Init population
        if population.isEmpty {
            population = initializePopulation()
            currentBestChromosome = population.sorted(by: { $0.totalDistance < $1.totalDistance }).first
        }
        
        population = createNextGeneration(prevPopulation: population)
        
        // Update best solution
        let newBest = population.sorted(by: { $0.totalDistance < $1.totalDistance }).first
        if let nextGenBestDistance = newBest?.totalDistance,
           let currentBestDistance = currentBestChromosome?.totalDistance,
           nextGenBestDistance <= currentBestDistance {
            currentBestChromosome = newBest
        }
        
        if let currentBestChromosome = currentBestChromosome {
            DispatchQueue.main.async {
                self.routeView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                _ = currentBestChromosome.placements.drawTourPath(from: self.routeView)
                self.view.bringSubviewToFront(self.routeView)
                self.view.setNeedsDisplay()
                self.view.layer.display()
            }
        }
        
        // Draw
        guard currentGen <= config.MAX_GENERATION else {
            self.operation?.cancelAllOperations()
            self.operation = nil
            DispatchQueue.main.async {
                let vc = UIAlertController(title: "Reached Max Generation. \(self.currentBestChromosome?.totalDistance ?? 0.0)", message: nil, preferredStyle: .alert)
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
            return
        }
        
        // Start next generation
        guard operation != nil else { return }
        operation?.qualityOfService = .default
        operation?.addBarrierBlock(nextInteration)
    }
    
    private func initializePopulation() -> Population {
        var population: Population = []
        for _ in 0...config.POPULATION_SIZE {
            population.append(Chromosome(placements: placements.shuffled()))
        }
        
        return population
    }
    
    private func createNextGeneration(prevPopulation: Population) -> Population {
        
        // 1. Preserve elites from previous population
        var nextGen: Population = [] + prevPopulation.getElite(Float(config.ELITE_PERCENT_TO_PRESERVE))
        
        while nextGen.count < config.POPULATION_SIZE {
            // 2. Pick 2 chromosomes to crossover
            var chromosome1 = select(config.SELECTION, from: prevPopulation)
            let populationWithoutChromosome1: Population = prevPopulation.filter { $0.id != chromosome1.id }
            var chromosome2 = select(config.SELECTION, from: populationWithoutChromosome1)
            
            // 3. CrossOver
            if Double.random(in: 0...1) <= config.CROSSOVER_RATE {
                var newChromosome = crossOver(chromosome1, chromosome2)
                
                // 4. Mutate
                mutateIfNeeded(&newChromosome, mutateRate: Float(config.MUTATE_RATE), isRandomMutation: true)
                nextGen.append(newChromosome)
            } else {
                mutateIfNeeded(&chromosome1, mutateRate: Float(config.MUTATE_RATE), isRandomMutation: true)
                mutateIfNeeded(&chromosome2, mutateRate: Float(config.MUTATE_RATE), isRandomMutation: true)
                
                mutateIfNeeded(&chromosome1, mutateRate: Float(config.MUTATE_RATE), isRandomMutation: true)
                mutateIfNeeded(&chromosome2, mutateRate: Float(config.MUTATE_RATE), isRandomMutation: true)
                
                // 4. Mutate
                nextGen.append(chromosome1)
                nextGen.append(chromosome2)
            }
        }
        
        // reset elite status
        for idx in 0 ..< nextGen.count {
            nextGen[idx].isElite = false
        }
        
        return nextGen
    }
    
    
    
    private func select(_ type: Selection, from population: Population) -> Chromosome {
        switch type {
        case .rouletteWheel(let size):
            guard let index = Selections.rouletteWheelSelect(from: population.filter { $0.isElite == false }.map { 1.0 / $0.totalDistance }, tournamemtSize: size)?.index else { fatalError()}
            return population[index]
            //        case .tournament:
            //            return tournamentSelect(from: population, tournamemtSize: tournamemtSize)
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
        let crossOverPointLeft = Int.random(in: 0...Int(Double(config.PLACEMENT_COUNT)/2.rounded(.down)))
        let crossOverPointRight = crossOverPointLeft + Int.random(in: 0...config.PLACEMENT_COUNT - (crossOverPointLeft + 1))
        
//        let crossOverPointRight = Int.random(in: Int(Double(config.PLACEMENT_COUNT)/2.rounded(.down))...config.PLACEMENT_COUNT-1)
        
        let tempPlacementsGene: [Placement] = Array(lChromosome.placements[crossOverPointLeft...crossOverPointRight])
        
        let diffPlacementsGene: [Placement] = rChromosome.placements.filter { !tempPlacementsGene.contains($0) }
        
        return Chromosome(placements: diffPlacementsGene + tempPlacementsGene)
    }
    
    func mutateIfNeeded(_ chromosome: inout Chromosome, mutateRate: Float, isRandomMutation: Bool = true) {
        
        let dice = Float.random(in: 0...1)
        
        guard dice <= Float(config.MUTATE_RATE) else {
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
