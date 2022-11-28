//
//  Configurable.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/26.
//

import Foundation

protocol ConfigurableType {
    associatedtype T: Configurable
    var config: T! { get set }
}

protocol Configurable {}
protocol GenerationLimitationConfigurable: Configurable {
    var MAX_GENERATION: Int { get set }
}

protocol PlacementsConfigurable: Configurable {
    var PLACEMENT_COUNT: Int { get set }
    var USE_PREVIOUS: Bool { get set }
    var USE_PENTAGON: Bool { get set }
}

protocol SelectionConfigurable: Configurable {
    var SELECTION: Selection { get set }
}

protocol ACOConfigurationType: Configurable {
    // Population
    var ANT_COUNT: Int { get set }
    
    // Pheromone
    var PHEROMONE_Q_AMOUNT: Double { get set }
    var EVAPORATE_RATE: Double { get set }
    
    // Priority
    var PHEROMONE_PRIORITY: Double { get set }
    var DISTANCE_PRIORITY: Double { get set }
}

protocol GAConfigurationType: Configurable {
    // Population
    var POPULATION_SIZE: Int { get set }
    
    // Mutation
    var MUTATE_RATE: Double { get set }
    
    //Elite
    var ELITE_PERCENT_TO_PRESERVE: Double { get set }
    
    // cross over
    var CROSSOVER_RATE: Double { get set }
}
