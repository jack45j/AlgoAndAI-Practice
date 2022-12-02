//
//  GACoordinator.swift
//  AlgoAndAI-Practice
//
//  Created by 林翌埕-20001107 on 2022/11/28.
//

import Foundation

class GACoordinator: BaseCoordinator, GACoordinatorOutput {
    var finishFlow: (() -> Void)?
    
    private let router: Router
    private let factory: GaModuleFactory
    
    init(factory: GaModuleFactory, router: Router) {
        self.factory = factory
        self.router = router
    }
    
    override func start() {
        showGaFlow()
    }
    
    private func showGaFlow() {
        let config = GAConfigurations()
        
        let configModule = factory.makeSettingModule(config: config)
        configModule.onConfirm = { [unowned self] configurations in
            guard let config = configurations as? GAConfigurations else { fatalError() }
            let gaModule = factory.makeGaPageModule(config: config)
            self.router.push(gaModule)
        }
        
        configModule.onFinish = { [unowned self] in
            self.finishFlow?()
        }
        
        router.push(configModule)
    }
}
