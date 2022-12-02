//
//  MazeSizeConfigurableGenerationCoordinatorOutput.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/2.
//

import Foundation

protocol MazeSizeConfigurableGenerationCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}
