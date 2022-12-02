//
//  ACOConfiguration.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/27.
//

import Foundation

struct ACOConfigurations: ACOConfigurationType, GenerationLimitationConfigurable, PlacementsConfigurable, SelectionConfigurable {
    
    // Population
    var ANT_COUNT: Int = 80
    
    // Pheromone
    var PHEROMONE_Q_AMOUNT: Double = 1.0 // Q
    var EVAPORATE_RATE: Double = 0.3  // ρ rho
     
    // Priority
    var PHEROMONE_PRIORITY: Double = 1.0 // α alpha
    var DISTANCE_PRIORITY: Double = 0.8 // β beta
    
    // Placements
    var PLACEMENT_COUNT: Int = 15
    var USE_PREVIOUS: Bool = true
    var USE_PENTAGON: Bool = false
    
    // Genertaion
    var MAX_GENERATION: Int = 500
    
    // Selection
    var SELECTION: Selection = .rouletteWheel(pickSize: 1)
}
