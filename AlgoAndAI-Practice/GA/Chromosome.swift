//
//  Chromosome.swift
//  AlgoAndAI-Practice
//
//  Created by Benson Lin on 2022/9/18.
//

import Foundation

struct Chromosome: SolutionType {
    var isElite = false
    var placements: [Placement]
    
    mutating func swapMutate(_ idx1: Int? = nil, _ idx2: Int? = nil) {
        let idx1 = idx1 ?? Int.random(in: 0..<placements.count)
        let idx2 = idx2 ?? Int.random(in: 0..<placements.count)
        if idx1 == idx2 {
            swapMutate()
            return
        }
        
        placements.swapAt(idx1, idx2)
    }
    
    mutating func inversionMutate(_ idxL: Int? = nil, _ idxR: Int? = nil) {
        var idxL = idxL ?? Int.random(in: 0 ..< Int(Double(placements.count)/2.rounded(.down)) )
        var idxR = idxR ?? Int.random(in: placements.count/2..<placements.count)
        
        while idxL < idxR {
            placements.swapAt(idxL, idxR)
            idxL += 1
            idxR -= 1
        }
    }
    
    mutating func scrambleMuate(_ idxL: Int? = nil, _ idxR: Int? = nil) {
        let idxL = idxL ?? Int.random(in: 0 ..< Int(Double(placements.count)/2.rounded(.down)) )
        let idxR = idxR ?? Int.random(in: placements.count/2..<placements.count)
        
        let tempGene = placements[idxR]
        for idx in stride(from: idxR, to: idxL, by: -1) {
            placements[idx] = placements[idx - 1]
        }
        
        placements[idxL] = tempGene
    }
}

extension Array where Self.Element == Chromosome {
    func getElite(_ rate: Float) -> Self {
        guard Float(self.count) * rate >= 1 else { return [] }
        let eliteCount = Int(Float(self.count) * rate)
        
        guard self.count > eliteCount else { return [] }
        
        var elites = Array(self.sorted(by: { $0.totalDistance < $1.totalDistance })[0...eliteCount - 1])
        
        for idx in 0..<elites.count {
            elites[idx].isElite = true
        }
        
        return elites
    }
}
