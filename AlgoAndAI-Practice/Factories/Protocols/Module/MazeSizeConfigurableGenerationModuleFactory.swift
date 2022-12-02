//
//  MazeSizeConfigurableGenerationModuleFactory.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/2.
//

import Foundation

protocol MazeSizeConfigurableGenerationModuleFactory {
    func makeDfsGenerationModule(config: MazeSizeGenerationConfigurations) -> DfsMazeGenerationViewController
    func makeSettingModule(config: Configurable) -> ConfigurationViewController
}
