//
//  MazeSizeConfigurableGenerationModuleFactoryImp.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/2.
//

import Foundation

final class MazeSizeConfigurableGenerationModuleFactoryImp: MazeSizeConfigurableGenerationModuleFactory {
    func makeDfsGenerationModule(config: MazeSizeGenerationConfigurations) -> DfsMazeGenerationViewController {
        let viewController = DfsMazeGenerationViewController.instantiate(config: config)
        return viewController
    }
    
    func makeSettingModule(config: Configurable) -> ConfigurationViewController {
        let viewController = ConfigurationViewController.instantiate(config: config)
        return viewController
    }
}
