//
//  ConfigurationTableViewController.swift
//  Sample
//
//  Created by Stas Kochkin on 18/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine


class ConfigurationVC: DataTableViewController {    
    override func setupSections() {
        addAppConfigurationSection()
        addUserTargetingSection()
        addLocationTargetingSection()
        addAppTargetingSection()
        addAdResttrictionsSection()
        addSdkRestrictionsSection()
    }
    
    @IBAction func clouseTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAndCloseTouched(_ sender: UIButton) {
        SdkContext.shared.synchronise()
        dismiss(animated: true, completion: nil)
    }
    
    private func addAppConfigurationSection() {
        let _ = addSection { section in
            section.title = "App configuration"
            section.state = .expanded
            
            let _ = section
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Test mode", value:SdkContext.shared.configuration.testMode)
                    cell.binding = { SdkContext.shared.configuration.testMode = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Logging", value:SdkContext.shared.appConfiguration.logging)
                    cell.binding = { SdkContext.shared.appConfiguration.logging = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Logs on callbacks", value:SdkContext.shared.appConfiguration.callbackLog)
                    cell.binding = { SdkContext.shared.appConfiguration.callbackLog = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Location", value:SdkContext.shared.appConfiguration.location)
                    cell.binding = { SdkContext.shared.appConfiguration.location = $0.value! }
                    row.cell = cell
            }
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Toasts", value:SdkContext.shared.appConfiguration.toast)
                    cell.binding = { SdkContext.shared.appConfiguration.toast = $0.value! }
                    row.cell = cell
            }
        }
    }
}
