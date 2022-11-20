//
//  AppCoordinator.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/20.
//

import UIKit
import Foundation

final class AppCoordinator: BaseCoordinator {
    
    private let facotry: AppCoordinatorFactory
    private let router: Router
    
    init(router: Router, facotry: AppCoordinatorFactory) {
        self.router = router
        self.facotry = facotry
    }
    
    override func start() {
        let coordinator = facotry.makeMainTableCoordinator(router: router)
        
        addDependency(coordinator)
        coordinator.start()
    }
}
