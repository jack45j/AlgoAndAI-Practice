//
//  MazeSizeConfigTableViewCell.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/12/2.
//

import Reusable
import UIKit

class MazeSizeConfigTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var edge1Slider: UISlider!
    @IBOutlet weak var edge2Slider: UISlider!
    
    @IBOutlet weak var edge1SliderValueLabel: UILabel!
    @IBOutlet weak var edge2SliderValueLabel: UILabel!
    
    var onChangeEdge1Size: ((Int) -> Void)?
    var onChangeEdge2Size: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        edge1Slider.addTarget(self, action: #selector(edge1SliderValueDidChange(slider:event:)), for: .valueChanged)
        edge2Slider.addTarget(self, action: #selector(edge2SliderValueDidChange(slider:event:)), for: .valueChanged)
    }
    
    @objc func edge1SliderValueDidChange(slider: UISlider, event: UIEvent) {
        let roundedValue = slider.value.rounded(.up)
        edge1SliderValueLabel.text = "\(Int(roundedValue))"
        
        if event.allTouches?.first?.phase == .ended {
            edge1Slider.setValue(roundedValue, animated: true)
            onChangeEdge1Size?(Int(roundedValue))
        }
    }
    
    @objc func edge2SliderValueDidChange(slider: UISlider, event: UIEvent) {
        let roundedValue = slider.value.rounded(.up)
        edge2SliderValueLabel.text = "\(Int(roundedValue))"
        
        if event.allTouches?.first?.phase == .ended {
            edge2Slider.setValue(roundedValue, animated: true)
            onChangeEdge2Size?(Int(roundedValue))
        }
    }
    
    func setDefaultState(edge1: Int, edge2: Int) {
        edge1Slider.setValue(Float(edge1), animated: true)
        edge2Slider.setValue(Float(edge2), animated: true)
        edge1SliderValueLabel.text = "\(edge1)"
        edge2SliderValueLabel.text = "\(edge2)"
    }
}
