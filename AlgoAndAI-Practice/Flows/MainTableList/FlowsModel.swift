//
//  FlowsModel.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/20.
//

import Foundation

enum FlowsModel: CaseIterable {
    case aco
    case gene
    
    var title: String {
        switch self {
        case .aco:
            return "Ant Colony Opt"
        case .gene:
            return "Genetic Algo"
        }
    }
    
    static var sections: [[Self]] {
        return [
            [.aco, .gene]
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
