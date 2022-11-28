//
//  PlacementConfigTableViewCell.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/26.
//

import UIKit
import Reusable
import BEMCheckBox

// TODO: flow optimization
class PlacementConfigTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var placementsSlider: UISlider!
    @IBOutlet weak var placementsSliderValueLabel: UILabel!
    
    @IBOutlet weak var usePreviousCheckBox: BEMCheckBox!
    @IBOutlet weak var usePentagonCheckBox: BEMCheckBox!
    
    @IBOutlet weak var withoutPreviousWarningLabel: UILabel!
    var onChangePlacementsCount: ((Int) -> Void)?
    var onChangeShouldUsePreviousTo: ((Bool) -> Void)?
    var onChangeShouldUsePentagonTo: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        usePreviousCheckBox.animationDuration = 0.1
        usePentagonCheckBox.animationDuration = 0.1
        placementsSliderValueDidChnage(slider: placementsSlider, event: .init())
        usePreviousCheckBox.delegate = self
        usePentagonCheckBox.delegate = self
        
        placementsSlider.addTarget(self, action: #selector(placementsSliderValueDidChnage(slider:event:)), for: .valueChanged)
    }
    
    func setDefaultStatus(default config: PlacementsConfigurable) {
        if GlobalConfigurations.shared.placements.isEmpty || GlobalConfigurations.shared.placements.count > Int(placementsSlider.maximumValue) {
            usePreviousCheckBox.setOn(false)
            onChangeShouldUsePreviousTo?(false)
            placementsSlider.setValue(Float(config.PLACEMENT_COUNT), animated: false)
            updateSliderStatus(to: true)
        } else {
            let gPlacements = GlobalConfigurations.shared.placements.count
            usePreviousCheckBox.setOn(config.USE_PREVIOUS)
            placementsSlider.setValue(Float(config.USE_PREVIOUS ? gPlacements : config.PLACEMENT_COUNT), animated: false)
            placementsSliderValueLabel.text = "\(Int(placementsSlider.value))"
            updateSliderStatus(to: !config.USE_PREVIOUS)
        }
        
        if usePreviousCheckBox.on {
            placementsSlider.setValue(Float(GlobalConfigurations.shared.placements.count), animated: true)
            placementsSliderValueLabel.text = "\(GlobalConfigurations.shared.placements.count)"
        }
    }
    
    fileprivate func updateSliderStatus(to isEnable: Bool) {
        placementsSlider.alpha = isEnable ? 1.0 : 0.5
        placementsSlider.isEnabled = isEnable
        placementsSlider.layoutIfNeeded()
    }
    
    @objc func placementsSliderValueDidChnage(slider: UISlider, event: UIEvent) {
        let value = slider.value.rounded(.up)
        placementsSliderValueLabel.text = value.formatted(.number)
        if event.allTouches?.first?.phase == .ended {
            slider.setValue(value, animated: true)
            onChangePlacementsCount?(Int(value))
        }
    }
}

extension PlacementConfigTableViewCell: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        print("[BS] BEMCheckBox: \(checkBox.on)")
        if checkBox == usePreviousCheckBox {
            let gPlacements = GlobalConfigurations.shared.placements.count
            onChangeShouldUsePreviousTo?(checkBox.on)
            if checkBox.on {
                placementsSliderValueLabel.text = "\(gPlacements)"
                placementsSlider.setValue(Float(gPlacements), animated: true)
                updateSliderStatus(to: false)
                
                usePentagonCheckBox.setOn(false, animated: true)
                onChangeShouldUsePentagonTo?(false)
            } else {
                updateSliderStatus(to: true)
            }
        }
        
        if checkBox == usePentagonCheckBox {
            onChangeShouldUsePentagonTo?(checkBox.on)
            if checkBox.on {
                usePreviousCheckBox.setOn(false)
                onChangeShouldUsePreviousTo?(false)
                
                updateSliderStatus(to: false)
            } else {
                
                
                updateSliderStatus(to: true)
            }
        }
    }
}
