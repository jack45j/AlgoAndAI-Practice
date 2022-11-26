//
//  AcoCoordinator.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/20.
//

import Foundation

final class AcoCoordinator: BaseCoordinator, AcoCoordinatorOutput {
    
    var finishFlow: (() -> Void)?
    
    private let router: Router
    private let factory: AcoModuleFactory
    
    init(factory: AcoModuleFactory, router: Router) {
        self.factory = factory
        self.router = router
    }
    
    override func start() {
        showAcoFlow()
    }
    
    private func showAcoFlow() {
        let config = ACOConfiguration()
        
        let configModule = factory.makeSettingModule(config: config)
        configModule.onConfirm = { [unowned self] configurations in
            guard let config = configurations as? ACOConfiguration else { fatalError() }
            let acoModule = factory.makeAcoPageModule(config: config)
            self.router.push(acoModule)
        }
        
        configModule.onFinish = { [unowned self] in
            self.finishFlow?()
        }
        
        router.push(configModule)
    }
}
