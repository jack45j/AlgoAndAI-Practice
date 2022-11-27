//
//  GenerationLimitationTableViewCell.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/27.
//

import UIKit
import Reusable

class GenerationLimitationTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var generationLimitationSlider: UISlider!
    @IBOutlet weak var generationLimitationSliderValueLabel: UILabel!
    
    var onLimitationChangeTo: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        generationLimitationSlider.addTarget(self, action: #selector(generationLimitationSliderValueDidChange(slider:event:)), for: .valueChanged)
    }
    
    func setDefaultState(_ limitation: Int) {
        generationLimitationSlider.setValue(Float(limitation), animated: true)
        generationLimitationSliderValueLabel.text = "\(limitation)"
    }
    
    @objc func generationLimitationSliderValueDidChange(slider: UISlider, event: UIEvent) {
        let rounded = (slider.value / 100).rounded(.toNearestOrEven) * 100
        generationLimitationSliderValueLabel.text = "\(Int(rounded))"
        if event.allTouches?.first?.phase == .ended {
            slider.setValue(rounded, animated: true)
        }
    }
}
