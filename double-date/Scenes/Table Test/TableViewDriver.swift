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
    private var headerModels: [TableHeaderConfigurator] = []
    private var headerViews: [UIView] = []
    
    // MARK: - Init
    init(tableView: UITableView,
         cellClasses: [AnyClass],
         headerViews: [UIView] = [],
         headerModels: [TableHeaderConfigurator] = []) {
        self.tableView = tableView
        self.cellClasses = cellClasses
        self.headerViews = headerViews
        self.headerModels = headerModels
        super.init()
        setup()
    }
    
    private func setup() {
        tableView.dataSource = self
        tableView.delegate = self
        cellClasses.forEach { tableView.register($0.self, forCellReuseIdentifier: String(describing: $0)) }
        NotificationCenter.default.addObserver(self, selector: #selector(onActionEvent(notif:)), name: CellAction.notificationName, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Cell Action Observer
    @objc fileprivate func onActionEvent(notif: Notification) {
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
    
    func updateHeader(in section: Int, item: TableHeaderConfigurator) {
        headerModels[section] = item
        tableView.reloadSections([section], animationStyle: .none)
    }
    
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
        headerModels[section].configure(view: headerViews[section])
        return headerViews[section]
    }
    
}
