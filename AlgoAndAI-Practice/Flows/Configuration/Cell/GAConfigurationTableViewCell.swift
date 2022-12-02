//
//  GAConfigurationTableViewCell.swift
//  AlgoAndAI-Practice
//
//  Created by 林翌埕-20001107 on 2022/11/28.
//

import UIKit
import Reusable

class GAConfigurationTableViewCell: UITableViewCell, NibReusable {
    @IBOutlet weak var populationSlider: UISlider!
    @IBOutlet weak var mutateRateSlider: UISlider!
    @IBOutlet weak var crossOverRateSlider: UISlider!
    @IBOutlet weak var elitePreserveRateSlider: UISlider!
    
    @IBOutlet weak var populationSliderValueLabel: UILabel!
    @IBOutlet weak var mutateRateSliderValueLabel: UILabel!
    @IBOutlet weak var crossOverRateSliderValueLabel: UILabel!
    @IBOutlet weak var elitePreserveRateSliderValueLabel: UILabel!
    
    var onPopulationSizeDidChange: ((Int) -> Void)?
    var onMutateRateValueDidChange: ((Float) -> Void)?
    var onCrossOverRateValueDidChange: ((Float) -> Void)?
    var onElitePreserveRateValueDidChange: ((Float) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        populationSlider.addTarget(self, action: #selector(populationSliderValueDidChange(slider:event:)), for: .valueChanged)
        mutateRateSlider.addTarget(self, action: #selector(mutateRateSliderValueDidChange(slider:event:)), for: .valueChanged)
        crossOverRateSlider.addTarget(self, action: #selector(crossOverRateSliderValueDidChange(slider:event:)), for: .valueChanged)
        elitePreserveRateSlider.addTarget(self, action: #selector(elitePreserveRateSliderValueDidChange(slider:event:)), for: .valueChanged)
    }
    
    @objc func populationSliderValueDidChange(slider: UISlider, event: UIEvent) {
        let roundedValue = (slider.value / 10).rounded(.toNearestOrEven) * 10
        populationSliderValueLabel.text = "\(Int(roundedValue))"
        
        if event.allTouches?.first?.phase == .ended {
            populationSlider.setValue(roundedValue, animated: true)
            onPopulationSizeDidChange?(Int(roundedValue))
        }
    }
    
    @objc func mutateRateSliderValueDidChange(slider: UISlider, event: UIEvent) {
        let roundedValue = (slider.value * 100).rounded(.toNearestOrEven) / 100.0
        mutateRateSliderValueLabel.text = "\(roundedValue)"
        
        if event.allTouches?.first?.phase == .ended {
            mutateRateSlider.setValue(roundedValue, animated: true)
            onMutateRateValueDidChange?(roundedValue)
        }
    }
    
    @objc func crossOverRateSliderValueDidChange(slider: UISlider, event: UIEvent) {
        let roundedValue = (slider.value * 100).rounded(.toNearestOrEven) / 100.0
        crossOverRateSliderValueLabel.text = "\(roundedValue)"
        
        if event.allTouches?.first?.phase == .ended {
            crossOverRateSlider.setValue(roundedValue, animated: true)
            onCrossOverRateValueDidChange?(roundedValue)
        }
    }
    
    @objc func elitePreserveRateSliderValueDidChange(slider: UISlider, event: UIEvent) {
        let roundedValue = (slider.value * 100).rounded(.toNearestOrEven) / 100.0
        elitePreserveRateSliderValueLabel.text = "\(roundedValue)"
        
        if event.allTouches?.first?.phase == .ended {
            elitePreserveRateSlider.setValue(roundedValue, animated: true)
            onElitePreserveRateValueDidChange?(roundedValue)
        }
    }

    func setDefaultState(population: Int, mutate: Double, crossOver: Double, elitePreserve: Double) {
        populationSlider.setValue(Float(population), animated: true)
        mutateRateSlider.setValue(Float(mutate), animated: true)
        crossOverRateSlider.setValue(Float(crossOver), animated: true)
        elitePreserveRateSlider.setValue(Float(elitePreserve), animated: true)
        
        populationSliderValueLabel.text = "\(population)"
        mutateRateSliderValueLabel.text = "\(mutate)"
        crossOverRateSliderValueLabel.text = "\(crossOver)"
        elitePreserveRateSliderValueLabel.text = "\(elitePreserve)"
    }
}
