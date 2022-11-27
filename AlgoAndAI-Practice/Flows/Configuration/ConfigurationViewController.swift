//
//  ConfigurationViewController.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/26.
//

import UIKit
import Reusable
import Foundation

protocol ConfigurationViewControllerOutput {
    var onConfirm: ((Configurable) -> Void)? { get set }
    var onFinish: (() -> Void)? { get set }
}

fileprivate enum Configurations {
    case generation
    case placements
    case aco
    
    var sectionTitle: String {
        switch self {
        case .generation:   return "Generation Limit Configuration"
        case .placements:   return "Placement Generate Configurations"
        case .aco:          return "Ant Colony Optimization Configurations"
        }
    }
}

class ConfigurationViewController: UIViewController, StoryboardBased, ConfigurationViewControllerOutput {
    
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var config: Configurable?
    fileprivate var dataSource: [Configurations] = []
    
    var onConfirm: ((Configurable) -> Void)?
    var onFinish: (() -> Void)?
    
    class func instantiate(config: Configurable) -> ConfigurationViewController {
        let viewController = ConfigurationViewController.instantiate()
        viewController.config = config
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        normalizeConfigurations()
        tableView.delegate = self
        tableView.dataSource = self
        registerCells()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.navigationController == nil {
            onFinish?()
        }
    }
    
    private func registerCells() {
        tableView.register(cellType: PlacementConfigTableViewCell.self)
        tableView.register(cellType: GenerationLimitationTableViewCell.self)
        tableView.register(cellType: ACOConfigurationTableViewCell.self)
    }
    
    private func normalizeConfigurations() {
        if let _ = config as? GenerationLimitationConfigurable {
            dataSource.append(.generation)
        }
        
        if let _ = config as? PlacementsConfigurable {
            dataSource.append(.placements)
        }
        
        if let _ = config as? ACOConfigurationType {
            dataSource.append(.aco)
        }
    }
    
    @IBAction func didTouchApplyButton(_ sender: Any) {
        guard let config = config else { return }
        onConfirm?(config)
    }
}

extension ConfigurationViewController: UITableViewDelegate {
    
}

extension ConfigurationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].sectionTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataSource[indexPath.section]
        switch type {
        case .generation:
            guard config as? GenerationLimitationConfigurable != nil else { fatalError() }
            let generationLimitationCell: GenerationLimitationTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            if let config = self.config as? GenerationLimitationConfigurable {
                generationLimitationCell.setDefaultState(config.MAX_GENERATION)
            }
            return generationLimitationCell
        case .placements:
            guard config as? PlacementsConfigurable != nil else { fatalError() }
            let placementConfigCell: PlacementConfigTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            placementConfigCell.onChangePlacementsCount = { [unowned self] placementsCount in
                if var config = self.config as? PlacementsConfigurable {
                    config.PLACEMENT_COUNT = placementsCount
                    self.config = config
                }
            }
            
            placementConfigCell.onChangeShouldUsePreviousTo = { [unowned self] isUse in
                if var config = self.config as? PlacementsConfigurable {
                    config.USE_PREVIOUS = isUse
                    self.config = config
                }
            }
            
            if let config = self.config as? PlacementsConfigurable {
                placementConfigCell.setDefaultStatus(isUsePrevious: config.USE_PREVIOUS, placementsCount: config.PLACEMENT_COUNT)
            }
            
            return placementConfigCell
        case .aco:
            let acoConfigCell: ACOConfigurationTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            if let config = self.config as? ACOConfigurationType {
                acoConfigCell.setDefaultState(colony: config.ANT_COUNT,
                                              tau: config.EVAPORATE_RATE,
                                              alpha: config.PHEROMONE_PRIORITY,
                                              beta: config.DISTANCE_PRIORITY)
            }
            return acoConfigCell
        }
    }
}
