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

    override func awakeFromNib() {
        super.awakeFromNib()
        
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
