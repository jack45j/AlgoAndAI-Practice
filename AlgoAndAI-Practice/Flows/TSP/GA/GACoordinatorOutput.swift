//
//  GACoordinatorOutput.swift
//  AlgoAndAI-Practice
//
//  Created by 林翌埕-20001107 on 2022/11/28.
//

import Foundation

protocol GACoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}
