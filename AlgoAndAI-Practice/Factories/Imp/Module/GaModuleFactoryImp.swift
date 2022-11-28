//
//  GaModuleFactoryImp.swift
//  AlgoAndAI-Practice
//
//  Created by 林翌埕-20001107 on 2022/11/28.
//

import Foundation

final class GaModuleFactoryImp: GaModuleFactory {
    func makeSettingModule(config: Configurable) -> ConfigurationViewController {
        return ConfigurationViewController.instantiate(config: config)
    }
    
    func makeGaPageModule(config: GAConfigurations) -> GAViewController {
        return GAViewController.instantiate(config: config)
    }
}
