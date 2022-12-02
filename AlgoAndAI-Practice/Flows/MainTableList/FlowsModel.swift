//
//  FlowsModel.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/20.
//

import Foundation

enum FlowsModel: CaseIterable {
    case tspAco
    case tspGene
    
    case mazeDfs
    
    var title: String {
        switch self {
        case .tspAco:
            return "Ant Colony Opt"
        case .tspGene:
            return "Genetic Algo"
        case .mazeDfs:
            return "Recursive backtracker"
        }
    }
    
    static var sections: [[Self]] {
        return [
            [.tspAco, .tspGene],
            [.mazeDfs]
        ]
    }
    
    static var sectionsTitle: [String] {
        return [
            "Traveling Salesman Problem",
            "Maze"
        ]
    }
    
    static func getFlowData(from indexPath: IndexPath) -> Self {
        return Self.sections[indexPath.section][indexPath.row]
    }
}
