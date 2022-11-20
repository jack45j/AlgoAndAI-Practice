//
//  MainTableModuleFactoryImp.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/20.
//

import Foundation

final class MainTableModuleFactoryImp: MainTableModuleFactory {
    func makeAcoModule() -> AcoViewController {
        return AcoViewController()
    }
}
