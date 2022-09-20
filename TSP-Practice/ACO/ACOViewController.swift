//
//  ACOViewController.swift
//  TSP-Practice
//
//  Created by 林翌埕-20001107 on 2022/9/19.
//

import Foundation
import UIKit

class ACOViewController: UIViewController, PlacementGeneratable {
    
    var PLACEMENT_COUNT: Int = 15
    lazy var placements: [Placement] = generatePlacement(PLACEMENT_COUNT)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .white
        
        if let cachedPoints = try? UserDefaults.standard.get(objectType: [CGPoint].self, forKey: "Controller.Placements") {
            let cachedPlacements = cachedPoints.map { Placement(x: $0.x.toFloat, y: $0.y.toFloat) }
            
            let vc = UIAlertController(title: "Use Cached placements?", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Sure!", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.placements.forEach { $0.layer?.removeFromSuperlayer() }
                self.placements = cachedPlacements
                self.drawPlacements(self.placements)
                self.startAlgo()
            }
            
            let deniedAction = UIAlertAction(title: "Nope!", style: .cancel) { [weak self] _ in
                guard let self = self else { return }
                self.placements = self.generatePlacement(self.PLACEMENT_COUNT)
                try? UserDefaults.standard.set(object: self.placements.map { CGPoint(x: $0.x.toCGFloat, y: $0.y.toCGFloat) }, forKey: "Controller.Placements")
                
                self.startAlgo()
            }
            
            vc.addAction(okAction)
            vc.addAction(deniedAction)
            
            present(vc, animated: true)
        } else {
            try? UserDefaults.standard.set(object: self.placements.map { CGPoint(x: $0.x.toCGFloat, y: $0.y.toCGFloat) }, forKey: "Controller.Placements")
        }
    }
    
    private func startAlgo() {
        DispatchQueue.main.async {
            _ = self.placements.drawTourPath(isEnclosed: false, lineDash: [2, 5], from: self.view)
        }
    }
}
