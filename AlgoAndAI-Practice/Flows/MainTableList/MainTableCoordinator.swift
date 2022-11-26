//
//  MainTableCoordinator.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/20.
//

import Foundation

final class MainTableCoordinator: BaseCoordinator {

    private let coordinatorFactory: MainTableCoordinatorFactory
    private let factory: MainTableModuleFactory
    private let router: Router
    
    init(coordinatorFactory: MainTableCoordinatorFactory, factory: MainTableModuleFactory, router: Router) {
        self.coordinatorFactory = coordinatorFactory
        self.factory = factory
        self.router = router
    }
    
    override func start() {
        showList()
    }
    
    private func showList() {
        let mainTableListController = MainTableViewController.instantiate()
        
        mainTableListController.onSelectFlow = { [weak self] flow in
            switch flow {
            case .aco:      self?.runAcoFlow()
            case .gene:     return
            }
        }
        
        router.setRootModule(mainTableListController)
    }
    
    private func runAcoFlow() {
        let acoCoordinator = coordinatorFactory.makeAcoCoordinator(router: router)
        acoCoordinator.finishFlow = { [unowned self, weak acoCoordinator] in
            self.removeDependency(acoCoordinator)
        }
        
        addDependency(acoCoordinator)
        
        acoCoordinator.start()
    }
}
