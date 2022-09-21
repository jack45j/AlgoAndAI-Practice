//
//  RouletteWheelSelection.swift
//  TSP-Practice
//
//  Created by 林翌埕-20001107 on 2022/9/21.
//

import Foundation

struct Selection {
    static func rouletteWheelSelectIndex(from options: [Float], tournamemtSize: Int) -> Int {
        guard options.count > tournamemtSize else {
            if let best = options.enumerated().map({ (index: $0.offset, value: $0.element) }).sorted(by: { $0.value < $1.value }).first?.index {
                return best
            } else {
                fatalError()
            }
        }
        
        let summary = options.reduce(0, +)
        guard summary > 0.0 else { return Int.random(in: 0..<options.count)}
        let percentageList = options.map {
            return $0 / summary
        }
        
        var tournamemtIndexes: [Int] = []
        for idx in 1...tournamemtSize {
            let randomNumber = Float.random(in: 0 ... 1.0)
            
            for idx in 0..<percentageList.count {
                if percentageList[0...idx].reduce(0.0, { $0 + $1 }) >= randomNumber {
                    tournamemtIndexes.append(idx)
                    break
                } else {
                    continue
                }
            }
        }
        guard let best = tournamemtIndexes.enumerated().map({ (index: $1, value: options[$0]) }).sorted(by: { $0.value < $1.value }).first else { fatalError() }
        return best.index
    }
}
