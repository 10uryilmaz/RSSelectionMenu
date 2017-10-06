//
//  RSSelectionMenuDataSource.swift
//  RSSelectionMenu
//
//  Created by Rushi on 29/09/17.
//  Copyright © 2017 Rushi Sangani. All rights reserved.
//

import UIKit

/// UITableViewCellConfiguration
typealias UITableViewCellConfiguration = ((_ cell: UITableViewCell, _ dataObject: AnyObject, _ indexPath: IndexPath) -> ())

/// DataSource
typealias DataSource = [AnyObject]

/// RSSelectionMenuDataSource
class RSSelectionMenuDataSource: NSObject {

    // MARK: - Properties
    
    /// cell type of tableview - default is "basic = UITableViewCellStyle.default"
    fileprivate var cellType: CellType = .basic
    
    /// cell identifier for tableview - default is "basic"
    fileprivate var cellIdentifier: String = CellType.basic.rawValue
    
    /// data source for tableview
    fileprivate var dataSource: DataSource = []
    
    /// filtered data source for tableView
    fileprivate var filteredDataSource: FilteredDataSource = []
    
    /// cell configuration - (cell, dataObject, indexPath)
    fileprivate var cellConfiguration: UITableViewCellConfiguration?
    
    // MARK: - Initialize
    
    init(dataSource: DataSource, forCellType type: CellType, configuration: @escaping UITableViewCellConfiguration) {
        
        self.dataSource = dataSource
        self.filteredDataSource = dataSource
        self.cellType = type
        self.cellConfiguration = configuration
    }
    
    convenience init(dataSource: DataSource, configuration: @escaping UITableViewCellConfiguration) {
        self.init(dataSource: dataSource, forCellType: CellType.basic, configuration: configuration)
    }
}

// MARK: - Public
extension RSSelectionMenuDataSource {
    
    /// set cell type and identifier
    func setCellType(type: CellType, withReuseIdentifier: String) {
        self.cellType = type
        self.cellIdentifier = withReuseIdentifier
    }
    
    /// returns the object present in dataSourceArray at specified indexPath
    func objectAt(indexPath: IndexPath) -> AnyObject {
        return self.filteredDataSource[indexPath.row]
    }
    
    /// to update data source for tableview
    func update(dataSource: FilteredDataSource, inTableView tableView: RSSelectionTableView) {
        
        if dataSource.count == 0 { filteredDataSource = self.dataSource }
        else { filteredDataSource = dataSource }
        
        tableView.reloadData()
    }
}

// MARK: - Private
extension RSSelectionMenuDataSource {
    
    /// returns UITableViewCellStyle based on defined cellType
    fileprivate func tableViewCellStyle() -> UITableViewCellStyle {
        
        switch self.cellType {
        case .basic:
            return UITableViewCellStyle.default
        case .rightDetail:
            return UITableViewCellStyle.value1
        case .subTitle:
            return UITableViewCellStyle.subtitle
        default:
            return UITableViewCellStyle.default
        }
    }
    
    /// checks if data source is empty
    fileprivate func isDataSourceEmpty() -> Bool {
        return (self.filteredDataSource.count == 0)
    }
    
    /// update cell status
    fileprivate func updateStatus(status: Bool, for cell: UITableViewCell) {
        cell.setSelected(status)
    }
}

// MARK: - UITableViewDataSource
extension RSSelectionMenuDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create new reusable cell
        let cellStyle = self.tableViewCellStyle()
        var cell: UITableViewCell?
        
        if cellType == .custom {
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        }
        else {
            cell = UITableViewCell(style: cellStyle, reuseIdentifier: self.cellIdentifier)
        }
        
        // cell configuration
        if let config = cellConfiguration {
            
            let dataObject = self.objectAt(indexPath: indexPath)
            config(cell!, dataObject, indexPath)
            
            // selection
            let delegate = tableView.delegate as! RSSelectionMenuDelegate
            updateStatus(status: delegate.showSelected(object: dataObject), for: cell!)
        }
        
        return cell!
    }
}
