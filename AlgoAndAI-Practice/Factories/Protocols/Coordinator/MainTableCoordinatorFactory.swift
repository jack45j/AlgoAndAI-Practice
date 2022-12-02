//
//  MainTableCoordinatorFactory.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/20.
//

import Foundation

protocol MainTableCoordinatorFactory {
    func makeAcoCoordinator(router: Router) -> AcoCoordinator
    func makeGaCoordinator(router: Router) -> GACoordinator
    func makeMazeGenerationCoordinator(method: MazeSizeConfigurableGenerationCoordinator.MazeGenerationMethod, router: Router) -> MazeSizeConfigurableGenerationCoordinator
}

