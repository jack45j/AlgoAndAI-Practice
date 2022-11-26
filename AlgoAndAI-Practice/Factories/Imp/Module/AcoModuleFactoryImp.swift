//
//  AcoModuleFactoryImp.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/20.
//

import Foundation

final class AcoModuleFactoryImp: AcoModuleFactory {
    func makeSettingModule() {
        
    }
    
    func makeAcoPageModule(config: ACOConfiguration) -> AcoViewController {
        return AcoViewController.instantiate(config: config)
    }
}