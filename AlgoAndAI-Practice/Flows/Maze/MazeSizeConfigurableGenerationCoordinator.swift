//
//  MazeSizeConfigurableGenerationCoordinator.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/2.
//

import Foundation

enum MazeGenerationMethod {
    case dfs
    case prim
}

class MazeSizeConfigurableGenerationCoordinator: BaseCoordinator, MazeSizeConfigurableGenerationCoordinatorOutput {
    
    private let router: Router
    private let factory: MazeSizeConfigurableGenerationModuleFactory
    private let method: MazeGenerationMethod
    
    var finishFlow: (() -> Void)?
    
    init(method: MazeGenerationMethod, factory: MazeSizeConfigurableGenerationModuleFactory, router: Router) {
        self.method = method
        self.factory = factory
        self.router = router
    }
    
    override func start() {
        switch method {
        case .dfs:
            runDfsFlow()
        case .prim:
            runPrimFlow()
        }
    }
    
    private func runDfsFlow() {
        let config = MazeSizeGenerationConfigurations()
        
        let configModule = factory.makeSettingModule(config: config)
        configModule.onConfirm = { [unowned self] configurations in
            guard let config = configurations as? MazeSizeGenerationConfigurations else { fatalError() }
            let dfsModule = factory.makeDfsGenerationModule(config: config)
            self.router.push(dfsModule)
        }
        
        configModule.onFinish = { [unowned self] in
            self.finishFlow?()
        }
        
        router.push(configModule)
    }
    
    private func runPrimFlow() {
        let config = MazeSizeGenerationConfigurations()
        
        let configModule = factory.makeSettingModule(config: config)
        configModule.onConfirm = { [unowned self] configurations in
            guard let config = configurations as? MazeSizeGenerationConfigurations else { fatalError() }
            let dfsModule = factory.makePrimGenerationModule(config: config)
            self.router.push(dfsModule)
        }
        
        configModule.onFinish = { [unowned self] in
            self.finishFlow?()
        }
        
        router.push(configModule)
    }
}
