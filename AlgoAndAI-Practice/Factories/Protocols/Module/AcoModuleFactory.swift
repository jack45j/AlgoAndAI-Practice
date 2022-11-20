//
//  AcoModuleFactory.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/20.
//

import Foundation

protocol AcoModuleFactory {
    func makeSettingModule()
    func makeAcoPageModule() -> AcoViewController
}
