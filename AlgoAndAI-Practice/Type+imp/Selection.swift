//
//  RouletteWheelSelection.swift
//  AlgoAndAI-Practice
//
//  Created by Benson Lin on 2022/9/21.
//

import Foundation

typealias SolutionIndex<T: BinaryFloatingPoint> = (index: Int, option: T)

enum Selection {
    case rouletteWheel(pickSize: Int)
    
    func select<T: BinaryFloatingPoint>(from options: [T], tournamemtSize: Int) -> SolutionIndex<T>? {
        switch self {
        case .rouletteWheel(let size):    return Selections.rouletteWheelSelect(from: options, tournamemtSize: size)
        }
    }
}

struct Selections {
    static func rouletteWheelSelect<T: BinaryFloatingPoint>(from options: [T], tournamemtSize: Int) -> SolutionIndex<T>? {
        
        let options = options.enumerated().map { (index: $0.offset, option: $0.element) }
        
        guard options.count > tournamemtSize else {
            return options.sorted(by: { $0.option < $1.option }).first
        }
        
        let summary = options.reduce(0, { $0 + $1.option })
        guard summary > 0.0 else { return options.randomElement() }
        let percentageList = options.map {
            return $0.option / summary
        }
        
        var tournaments: [SolutionIndex<T>] = []
        for _ in 1...tournamemtSize {
            let randomNumber = Double.random(in: 0 ... 1.0)
            
            for idx in 0..<percentageList.count {
                if percentageList[0...idx].reduce(0.0, { $0 + Double($1) }) >= randomNumber {
                    tournaments.append(options[idx])
                    break
                } else {
                    continue
                }
            }
        }
        
        return tournaments.sorted(by: { $0.option > $1.option }).first
    }
}
