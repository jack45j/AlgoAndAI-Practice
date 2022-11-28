//
//  AcoModuleFactoryImp.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/20.
//

import Foundation

final class AcoModuleFactoryImp: AcoModuleFactory {
    func makeSettingModule(config: Configurable) -> ConfigurationViewController {
        return ConfigurationViewController.instantiate(config: config)
    }
    
    func makeAcoPageModule(config: ACOConfigurations) -> AcoViewController {
        return AcoViewController.instantiate(config: config)
    }
}
