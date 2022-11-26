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
        
        let acoModule = factory.makeAcoPageModule(config: config)
        acoModule.onFinish = { [unowned self] in
            self.finishFlow?()
        }
        router.push(acoModule)
    }
}