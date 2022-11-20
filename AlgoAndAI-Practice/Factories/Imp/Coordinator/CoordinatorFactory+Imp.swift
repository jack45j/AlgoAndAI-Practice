//
//  CoordinatorFactory+Imp.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/20.
//

import UIKit
import Foundation

final class CoordinatorFactoryImp: AppCoordinatorFactory, MainTableCoordinatorFactory {
    
    func makeMainTableCoordinator(router: Router) -> MainTableCoordinator {
        return MainTableCoordinator(coordinatorFactory: CoordinatorFactoryImp(), factory: MainTableModuleFactoryImp(), router: router)
    }
    
    func makeAcoCoordinator(router: Router) -> AcoCoordinator {
        return AcoCoordinator(factory: AcoModuleFactoryImp(), router: router)
    }
    
    private func router(_ navController: UINavigationController?) -> Router {
        return RouterImp(rootController: navigationController(navController))
    }
    
    private func navigationController(_ navController: UINavigationController?) -> UINavigationController {
        if let navController = navController { return navController }
        else { return UINavigationController() }
    }
}

