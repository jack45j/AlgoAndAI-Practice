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
        
        mainTableListController.onSelectFlow = { [unowned self] flow in
            switch flow {
            case .tspAco:       self.runAcoFlow()
            case .tspGene:      self.runGaFlow()
            case .mazeDfs:      self.runDfsFlow()
            case .mazePrim:     self.runPrimFlow()
            }
        }
        
        router.setRootModule(mainTableListController)
    }
    
    private func runAcoFlow() {
        let acoCoordinator = coordinatorFactory.makeAcoCoordinator(router: router)
        acoCoordinator.finishFlow = { [weak self, weak acoCoordinator] in
            self?.removeDependency(acoCoordinator)
        }
        
        addDependency(acoCoordinator)
        acoCoordinator.start()
    }
    
    private func runGaFlow() {
        let gaCoordinator = coordinatorFactory.makeGaCoordinator(router: router)
        gaCoordinator.finishFlow = { [weak self, weak gaCoordinator] in
            self?.removeDependency(gaCoordinator)
        }
        
        addDependency(gaCoordinator)
        gaCoordinator.start()
    }
    
    private func runDfsFlow() {
        let mazeCoordinator = coordinatorFactory.makeMazeGenerationCoordinator(method: .dfs, router: router)
        mazeCoordinator.finishFlow = { [weak self, weak mazeCoordinator] in
            self?.removeDependency(mazeCoordinator)
        }
        
        addDependency(mazeCoordinator)
        mazeCoordinator.start()
    }
    
    private func runPrimFlow() {
        let mazeCoordinator = coordinatorFactory.makeMazeGenerationCoordinator(method: .prim, router: router)
        mazeCoordinator.finishFlow = { [weak self, weak mazeCoordinator] in
            self?.removeDependency(mazeCoordinator)
        }
        
        addDependency(mazeCoordinator)
        mazeCoordinator.start()
    }
}
