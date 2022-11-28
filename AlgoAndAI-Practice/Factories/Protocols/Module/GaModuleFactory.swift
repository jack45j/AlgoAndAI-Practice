//
//  GaModuleFactory.swift
//  AlgoAndAI-Practice
//
//  Created by 林翌埕-20001107 on 2022/11/28.
//

import Foundation

protocol GaModuleFactory {
    func makeSettingModule(config: Configurable) -> ConfigurationViewController
    func makeGaPageModule(config: GAConfigurations) -> GAViewController
}
