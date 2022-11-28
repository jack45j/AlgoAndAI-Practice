//
//  ACOConfigurationTableViewCell.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/27.
//

import UIKit
import Reusable

class ACOConfigurationTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var antColonySlider: UISlider!
    @IBOutlet weak var tauValueSlider: UISlider!
    @IBOutlet weak var alphaValueSlider: UISlider!
    @IBOutlet weak var betaValueSlider: UISlider!
    
    @IBOutlet weak var antColonySliderValueLabel: UILabel!
    @IBOutlet weak var tauValueSliderValueLabel: UILabel!
    @IBOutlet weak var alphaValueSliderValueLabel: UILabel!
    @IBOutlet weak var betaValueSliderValueLabel: UILabel!
    
    var onColonySizeDidChange: ((Int) -> Void)?
    var onTauValueDidChange: ((Float) -> Void)?
    var onAlphaValueDidChange: ((Float) -> Void)?
    var onBetaValueDidChange: ((Float) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        antColonySlider.addTarget(self, action: #selector(antColonySliderValueDidChange(slider:event:)), for: .valueChanged)
        tauValueSlider.addTarget(self, action: #selector(tauValueSliderSliderValueDidChange(slider:event:)), for: .valueChanged)
        alphaValueSlider.addTarget(self, action: #selector(alphaValueSliderSliderValueDidChange(slider:event:)), for: .valueChanged)
        betaValueSlider.addTarget(self, action: #selector(betaValueSliderSliderValueDidChange(slider:event:)), for: .valueChanged)
    }
    
    @objc func antColonySliderValueDidChange(slider: UISlider, event: UIEvent) {
        let roundedValue = (slider.value / 10).rounded(.toNearestOrEven) * 10
        antColonySliderValueLabel.text = "\(Int(roundedValue))"
        
        if event.allTouches?.first?.phase == .ended {
            antColonySlider.setValue(roundedValue, animated: true)
            onColonySizeDidChange?(Int(roundedValue))
        }
    }
    
    @objc func tauValueSliderSliderValueDidChange(slider: UISlider, event: UIEvent) {
        let roundedValue = (slider.value * 10).rounded(.up) / 10.0
        tauValueSliderValueLabel.text = "\(roundedValue)"
        
        if event.allTouches?.first?.phase == .ended {
            tauValueSlider.setValue(roundedValue, animated: true)
            onTauValueDidChange?(roundedValue)
        }
    }
    
    @objc func alphaValueSliderSliderValueDidChange(slider: UISlider, event: UIEvent) {
        let roundedValue = slider.value.rounded(.up)
        alphaValueSliderValueLabel.text = "\(roundedValue)"
        
        if event.allTouches?.first?.phase == .ended {
            alphaValueSlider.setValue(roundedValue, animated: true)
            onAlphaValueDidChange?(roundedValue)
        }
    }
    
    @objc func betaValueSliderSliderValueDidChange(slider: UISlider, event: UIEvent) {
        let roundedValue = slider.value.rounded(.up)
        betaValueSliderValueLabel.text = "\(roundedValue)"
        
        if event.allTouches?.first?.phase == .ended {
            betaValueSlider.setValue(roundedValue, animated: true)
            onBetaValueDidChange?(roundedValue)
        }
    }

    func setDefaultState(colony: Int, tau: Double, alpha: Double, beta: Double) {
        antColonySlider.setValue(Float(colony), animated: true)
        tauValueSlider.setValue(Float(tau), animated: true)
        alphaValueSlider.setValue(Float(alpha), animated: true)
        betaValueSlider.setValue(Float(beta), animated: true)
        
        antColonySliderValueLabel.text = "\(colony)"
        tauValueSliderValueLabel.text = "\(tau)"
        alphaValueSliderValueLabel.text = "\(alpha)"
        betaValueSliderValueLabel.text = "\(beta)"
    }
}
