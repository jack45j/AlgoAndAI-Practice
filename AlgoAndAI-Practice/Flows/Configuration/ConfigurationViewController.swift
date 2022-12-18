//
//  ConfigurationViewController.swift
//  AlgoAndAI-Practice
//
//  Created by Yi-Cheng Lin on 2022/11/26.
//

import UIKit
import Reusable
import Foundation

fileprivate enum Configurations {
    case generation
    case placements
    case aco
    case ga
    case mazeSize
    
    var sectionTitle: String {
        switch self {
        case .generation:   return "Generation Limit Configuration"
        case .placements:   return "Placement Generate Configurations"
        case .aco:          return "Ant Colony Optimization Configurations"
        case .ga:           return "Genetic Algorithm Configurations"
        case .mazeSize:     return "Maze Size Configurations"
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
        tableView.register(cellType: GAConfigurationTableViewCell.self)
        tableView.register(cellType: MazeSizeConfigTableViewCell.self)
    }
    
    private func normalizeConfigurations() {
        if let _ = config as? MazeSizeConfigurable {
            dataSource.append(.mazeSize)
        }
        
        if let _ = config as? GenerationLimitationConfigurable {
            dataSource.append(.generation)
        }
        
        if let _ = config as? PlacementsConfigurable {
            dataSource.append(.placements)
        }
        
        if let _ = config as? ACOConfigurationType {
            dataSource.append(.aco)
        }
        
        if let _ = config as? GAConfigurationType {
            dataSource.append(.ga)
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
            
            generationLimitationCell.onLimitationChangeTo = { [unowned self] limitation in
                if var config = self.config as? GenerationLimitationConfigurable {
                    config.MAX_GENERATION = limitation
                    self.config = config
                }
            }
            
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
            
            placementConfigCell.onChangeShouldUsePentagonTo = { [unowned self] isUse in
                if var config = self.config as? PlacementsConfigurable {
                    config.USE_PENTAGON = isUse
                    self.config = config
                }
            }
            
            if let config = self.config as? PlacementsConfigurable {
                placementConfigCell.setDefaultStatus(default: config)
            }
            
            return placementConfigCell
        case .aco:
            let acoConfigCell: ACOConfigurationTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            acoConfigCell.onColonySizeDidChange = { [unowned self] size in
                if var config = self.config as? ACOConfigurationType {
                    config.ANT_COUNT = size
                    self.config = config
                }
            }
            
            acoConfigCell.onTauValueDidChange = { [unowned self] tau in
                if var config = self.config as? ACOConfigurationType {
                    config.EVAPORATE_RATE = Double(tau)
                    self.config = config
                }
            }
            
            acoConfigCell.onAlphaValueDidChange = { [unowned self] alpha in
                if var config = self.config as? ACOConfigurationType {
                    config.PHEROMONE_PRIORITY = Double(alpha)
                    self.config = config
                }
            }
            
            acoConfigCell.onBetaValueDidChange = { [unowned self] beta in
                if var config = self.config as? ACOConfigurationType {
                    config.DISTANCE_PRIORITY = Double(beta)
                    self.config = config
                }
            }
            
            if let config = self.config as? ACOConfigurationType {
                acoConfigCell.setDefaultState(colony: config.ANT_COUNT,
                                              tau: config.EVAPORATE_RATE,
                                              alpha: config.PHEROMONE_PRIORITY,
                                              beta: config.DISTANCE_PRIORITY)
            }
            return acoConfigCell
        case .ga:
            let gaConfigCell: GAConfigurationTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            gaConfigCell.onPopulationSizeDidChange = { [unowned self] size in
                if var config = self.config as? GAConfigurationType {
                    config.POPULATION_SIZE = size
                    self.config = config
                }
            }
            
            gaConfigCell.onMutateRateValueDidChange = { [unowned self] rate in
                if var config = self.config as? GAConfigurationType {
                    config.MUTATE_RATE = Double(rate)
                    self.config = config
                }
            }
            
            gaConfigCell.onCrossOverRateValueDidChange = { [unowned self] rate in
                if var config = self.config as? GAConfigurationType {
                    config.CROSSOVER_RATE = Double(rate)
                    self.config = config
                }
            }
            
            gaConfigCell.onElitePreserveRateValueDidChange = { [unowned self] rate in
                if var config = self.config as? GAConfigurationType {
                    config.ELITE_PERCENT_TO_PRESERVE = Double(rate)
                    self.config = config
                }
            }
            
            if let config = self.config as? GAConfigurationType {
                gaConfigCell.setDefaultState(population: config.POPULATION_SIZE,
                                             mutate: config.MUTATE_RATE,
                                             crossOver: config.CROSSOVER_RATE,
                                             elitePreserve: config.ELITE_PERCENT_TO_PRESERVE)
            }
            
            return gaConfigCell
        case .mazeSize:
            let mazeSizeConfigCell: MazeSizeConfigTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            mazeSizeConfigCell.onChangeEdge1Size = { [unowned self] edge1 in
                if var config = self.config as? MazeSizeConfigurable {
                    config.edge1 = edge1
                    self.config = config
                }
            }
            
            mazeSizeConfigCell.onChangeEdge2Size = { [unowned self] edge2 in
                if var config = self.config as? MazeSizeConfigurable {
                    config.edge2 = edge2
                    self.config = config
                }
            }
            
            mazeSizeConfigCell.onChangeRandomStartAndDest = { [unowned self] isRandom in
                if var config = self.config as? MazeSizeConfigurable {
                    config.isRandomStartAndDestination = isRandom
                    self.config = config
                }
            }
            
            if let config = self.config as? MazeSizeConfigurable {
                mazeSizeConfigCell.setDefaultState(edge1: config.edge1, edge2: config.edge2, isRandomStartAndDest: config.isRandomStartAndDestination)
            }
            
            return mazeSizeConfigCell
        }
    }
}
