//
//  TableDataSource.swift
//  double-date
//
//  Created by Robert Rozenvasser on 8/7/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit

open class TableViewDriver: NSObject {
    
    // MARK: - Public Properties
    var sections: [[CellConfigurator]] = []
    let actionsProxy = CellActionProxy()
    
    // MARK: - Private Properties
    private let tableView: UITableView
    private let cellClasses: [AnyClass]
    //private let headerFooterClasses: [AnyClass]
    private var headerModels: [CellConfigurator]
    private var footerModels: [CellConfigurator]
    
    private var headerClasses: [AnyClass] = []
    private var footerClasses: [AnyClass] = []
    
    // MARK: - Init
    init(tableView: UITableView,
         cellClasses: [AnyClass],
         headerClasses: [AnyClass] = [],
         footerClasses: [AnyClass] = [],
         headerModels: [CellConfigurator] = [],
         footerModels: [CellConfigurator] = []) {
        self.tableView = tableView
        self.cellClasses = cellClasses
        self.headerClasses = headerClasses
        self.footerClasses = footerClasses
        //self.headerFooterClasses = headerFooterClasses
        self.headerModels = headerModels
        self.footerModels = footerModels
        super.init()
        setup()
    }
    
    private func setup() {
        cellClasses.forEach { tableView.register($0.self, forCellReuseIdentifier: String(describing: $0)) }
        headerClasses.forEach {
            tableView.register($0.self, forHeaderFooterViewReuseIdentifier: String(describing: $0))
        }
        footerClasses.forEach {
            tableView.register($0.self, forHeaderFooterViewReuseIdentifier: String(describing: $0))
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onActionEvent(notif:)), name: CellAction.notificationName, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Cell Action Observer
    @objc fileprivate func onActionEvent(notif: Notification) {
        if let eventData = notif.userInfo?["data"] as? CellActionEventData {
            
            if let cell = eventData.cell as? UITableViewCell,
               let indexPath = self.tableView.indexPath(for: cell) {
                actionsProxy.invoke(action: eventData.action,
                                    cell: cell,
                                    configurator: self.sections[indexPath.section][indexPath.row])
                return
            }
        
            if let headerFooter = eventData.cell as? UITableViewHeaderFooterView {
                
                if let headerClassIndex = headerClasses
                    .index(where: { String(describing: $0) == headerFooter.reuseIdentifier }) {
                    actionsProxy.invoke(action: eventData.action,
                                        cell: headerFooter,
                                        configurator: self.headerModels[headerClassIndex])
                    return
                }
                
                if let footerClassIndex = footerClasses
                    .index(where: { String(describing: $0) == headerFooter.reuseIdentifier }) {
                    actionsProxy.invoke(action: eventData.action,
                                        cell: headerFooter,
                                        configurator: self.footerModels[footerClassIndex])
                    return
                }
            }
        }
        
        if let eventData = notif.userInfo?["data"] as? CellActionEventData,
            let cell = eventData.cell as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            actionsProxy.invoke(action: eventData.action,
                                cell: cell,
                                configurator: self.sections[indexPath.section][indexPath.row])
        }
        
    }

}

extension TableViewDriver {
    
    // MARK: - Public Interface
    func updateItem(at indexPath: IndexPath, item: CellConfigurator) {
        sections[indexPath.section][indexPath.row] = item
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func deleteItem(at indexPath: IndexPath) {
        sections[indexPath.section].remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .none)
    }
    
//    func updateHeader(in section: Int, item: TableHeaderConfigurator) {
////        headerModels[section] = item
////        tableView.reloadSections([section], animationStyle: .none)
//    }
    
}

extension TableViewDriver: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section][indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: type(of: item).reuseId)
            else { return UITableViewCell() }
        item.configure(cell: cell)
        return cell
    }
    
}

extension TableViewDriver: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellConfigurator = self.sections[indexPath.section][indexPath.row]
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        self.actionsProxy.invoke(action: .didSelect, cell: cell, configurator: cellConfigurator)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < headerModels.count else { return nil }
        let model = headerModels[section]
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: type(of: model).reuseId) else { return nil }
        model.configure(cell: header)
        return header
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section < footerModels.count else { return nil }
        let model = footerModels[section]
        guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: type(of: model).reuseId) else { return nil }
        model.configure(cell: footer)
        return footer
    }
    
}
