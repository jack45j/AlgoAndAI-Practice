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
    
    @IBOutlet weak var withoutPreviousWarningLabel: UILabel!
    var onChangePlacementsCount: ((Int) -> Void)?
    var onChangeShouldUsePreviousTo: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        usePreviousCheckBox.animationDuration = 0.1
        placementsSliderValueDidChnage(slider: placementsSlider, event: .init())
        usePreviousCheckBox.delegate = self
        
        placementsSlider.addTarget(self, action: #selector(placementsSliderValueDidChnage(slider:event:)), for: .valueChanged)
    }
    
    func setDefaultStatus(isUsePrevious: Bool, placementsCount: Int) {
        usePreviousCheckBox.setOn(isUsePrevious)
        placementsSliderValueLabel.text = "\(placementsCount)"
        updateSliderStatus(to: !isUsePrevious)
        validatePlacements(GlobalConfigurations.shared.placements)
        
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
    
    fileprivate func validatePlacements(_ placements: [CGPoint]) {
        if placements.isEmpty || placements.count > Int(placementsSlider.maximumValue) {
            usePreviousCheckBox.setOn(false)
            GlobalConfigurations.shared.placements = []
            onChangeShouldUsePreviousTo?(false)
        }
        withoutPreviousWarningLabel.isHidden = !placements.isEmpty
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
        let placements = GlobalConfigurations.shared.placements
        
        onChangeShouldUsePreviousTo?(checkBox.on)
        validatePlacements(placements)
        
        if usePreviousCheckBox.on {
            placementsSliderValueLabel.text = "\(placements.count)"
            placementsSlider.setValue(Float(placements.count), animated: true)
        }
        onChangePlacementsCount?(placements.count)
        updateSliderStatus(to: !usePreviousCheckBox.on)
    }
}
