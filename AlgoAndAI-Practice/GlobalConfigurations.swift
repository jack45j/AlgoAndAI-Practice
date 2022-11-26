//
//  GlobalConfigurations.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/27.
//

import Foundation

final class GlobalConfigurations {
    static let shared = GlobalConfigurations()
    
    var placements: [CGPoint] {
        get {
            return (try? UserDefaults.standard.get(objectType: [CGPoint].self, forKey: "Controller.Placements")) ?? []
        }
        set {
            try? UserDefaults.standard.set(object: newValue, forKey: "Controller.Placements")
        }
    }
}
