//
//  GAConfigurations.swift
//  AlgoAndAI-Practice
//
//  Created by 林翌埕-20001107 on 2022/11/28.
//

import Foundation

struct GAConfigurations: GAConfigurationType, PlacementsConfigurable, GenerationLimitationConfigurable, SelectionConfigurable {
    
    var POPULATION_SIZE: Int = 50
    var CROSSOVER_RATE: Double = 0.7
    var MUTATE_RATE: Double = 0.01
    var ELITE_PERCENT_TO_PRESERVE: Double = 0.1
    
    var PLACEMENT_COUNT: Int = 15
    var USE_PREVIOUS: Bool = true
    var USE_PENTAGON: Bool = false
    
    var MAX_GENERATION: Int = 1000
    
    var SELECTION: Selection = .rouletteWheel(pickSize: 4)
}
