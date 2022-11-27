//
//  ACOConfiguration.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/27.
//

import Foundation

struct ACOConfiguration: ACOConfigurationType, GenerationLimitationConfigurable, PlacementsConfigurable {
    // Population
    var ANT_COUNT: Int = 30
    
    // Pheromone
    var PHEROMONE_Q_AMOUNT: Double = 1.0 // Q
    var EVAPORATE_RATE: Double = 0.3  // ρ rho
     
    // Priority
    var PHEROMONE_PRIORITY: Double = 1.0 // α alpha
    var DISTANCE_PRIORITY: Double = 0.8 // β beta
    
    // placements
    var PLACEMENT_COUNT: Int = 15
    var USE_PREVIOUS: Bool = true
    
    // genertaion
    var MAX_GENERATION: Int = 500
}
