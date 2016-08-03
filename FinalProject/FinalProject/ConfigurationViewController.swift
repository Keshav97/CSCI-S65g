//
//  ConfigurationViewController.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

class ConfigurationViewController: UITableViewController {

    var designNames: [String] = ["Glider"]
    var gridContentCoordinates: [[[Int]]] = [[[8, 11], [9, 9], [9, 11], [10, 10], [10, 11]]]
    var comments: [String] = ["Standard (infinite) glider"]
    
    static var _sharedTable = ConfigurationViewController()
    static var sharedTable: ConfigurationViewController { get { return _sharedTable } }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observer to reload table data
        let sel = #selector(ConfigurationViewController.reloadTableView(_:))
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: sel, name: "TableViewReloadData", object: nil)
    }
    
    @IBAction func addEntry(sender: UIBarButtonItem) {
        ConfigurationViewController.sharedTable.designNames.append("Add new name...")
        ConfigurationViewController.sharedTable.gridContentCoordinates.append([])
        ConfigurationViewController.sharedTable.comments.append("")
        let rowItem = ConfigurationViewController.sharedTable.designNames.count - 1
        let itemPath = NSIndexPath(forRow:rowItem, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([itemPath], withRowAnimation: .Automatic)
        self.tableView.reloadData()
    }
    
    func reloadTableView(notification:NSNotification) {
        self.tableView.reloadData()
        self.tableView.setNeedsDisplay()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConfigurationViewController.sharedTable.designNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("Default")
            else {
                preconditionFailure("missing Default reuse identifier")
        }
        let row = indexPath.row
        guard let nameLabel = cell.textLabel else {
            preconditionFailure("Something is wrong.")
        }
        nameLabel.text = ConfigurationViewController.sharedTable.designNames[row]
        cell.tag = row
        return cell
    }
    
    override func tableView(tableView: UITableView,
                            commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                                               forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            ConfigurationViewController.sharedTable.designNames.removeAtIndex(indexPath.row)
            ConfigurationViewController.sharedTable.gridContentCoordinates.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        StandardEngine.sharedInstance.checkChanges = false
        let editingRow = (sender as! UITableViewCell).tag
        let editingString = ConfigurationViewController.sharedTable.designNames[editingRow]
        let editingComment = ConfigurationViewController.sharedTable.comments[editingRow]
        guard let editingVC = segue.destinationViewController as? ConfigurationEditorViewController
            else {
                preconditionFailure("Something went wrong")
        }
        editingVC.name = editingString
        editingVC.comment = editingComment
        editingVC.commit = {
            ConfigurationViewController.sharedTable.designNames[editingRow] = $0
            let indexPath = NSIndexPath(forRow: editingRow, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        editingVC.anotherCommit = {
            ConfigurationViewController.sharedTable.gridContentCoordinates[editingRow] = $0
        }
        editingVC.commitForComment = {
            ConfigurationViewController.sharedTable.comments[editingRow] = $0
        }
        
        // Set size of grid according to coordinates of pattern
        let size = ConfigurationViewController.sharedTable.gridContentCoordinates[editingRow].flatMap{$0}.maxElement()
        if let finalSize = size {
            StandardEngine.sharedInstance.rows = (finalSize % 10 != 0) ? (finalSize / 10 + 1) * 10 : finalSize
            StandardEngine.sharedInstance.cols = (finalSize % 10 != 0) ? (finalSize / 10 + 1) * 10 : finalSize
        }
        
        let set: [(Int, Int)] = ConfigurationViewController.sharedTable.gridContentCoordinates[editingRow].map { return ($0[0], $0[1]) }
        GridView().points = set
        
        if let delegate = StandardEngine.sharedInstance.delegate {
            delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
        }
        
        // Post required notifications
        NSNotificationCenter.defaultCenter().postNotificationName("ModifyRowAndColumnText", object: nil, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("TurnOffSwitch", object: nil, userInfo: nil)
        
    }
}
