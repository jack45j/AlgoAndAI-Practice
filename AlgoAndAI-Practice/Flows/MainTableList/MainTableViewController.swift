//
//  MainTableViewController.swift
//  AlgoAndAI-Practice
//
//  Created by Benson Lin on 2022/9/19.
//

import UIKit
import Reusable

class MainTableViewController: UITableViewController, StoryboardBased, MainTableViewOutput {
    
    var onSelectFlow: ((FlowsModel) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return FlowsModel.sectionsTitle[section]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return FlowsModel.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FlowsModel.sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = FlowsModel.getFlowData(from: indexPath).title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectFlow?(FlowsModel.getFlowData(from: indexPath))
    }
}
