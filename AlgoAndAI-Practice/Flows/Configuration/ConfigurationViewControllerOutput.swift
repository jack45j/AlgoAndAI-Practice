//
//  ConfigurationViewControllerOutput.swift
//  AlgoAndAI-Practice
//
//  Created by Benson Lin on 2022/11/28.
//

import Foundation

protocol ConfigurationViewControllerOutput {
    var onConfirm: ((Configurable) -> Void)? { get set }
    var onFinish: (() -> Void)? { get set }
}
