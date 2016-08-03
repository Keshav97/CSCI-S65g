//
//  ConfigurationViewController.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

class ConfigurationViewController: UITableViewController {

    var names:[String] = ["Hi","Glider", "Static Life Collection", "My Favorite Pattern"]
    var gridContent: [[[Int]]] = [[[3, 5], [3, 6], [3, 7], [3, 8], [3, 9], [3, 10], [3, 11], [3, 12], [3, 13], [3, 14], [3, 15], [4, 10], [5, 10], [6, 10], [7, 10], [8, 10], [9, 5], [9, 6], [9, 7], [9, 8], [9, 9], [9, 10], [9, 11], [9, 12], [9, 13], [9, 14], [9, 15], [14, 5], [14, 6], [14, 8], [14, 9], [14, 10], [14, 11], [14, 12], [14, 13], [14, 14], [14, 15]], [[8, 11], [9, 9], [9, 11], [10, 10], [10, 11]], [[0, 12], [0, 17], [0, 18], [1, 11], [1, 13], [1, 16], [1, 19], [2, 2], [2, 3], [2, 7], [2, 8], [2, 12], [2, 14], [2, 17], [2, 19], [3, 2], [3, 3], [3, 7], [3, 9], [3, 13], [3, 18], [4, 8], [4, 9], [6, 3], [7, 2], [7, 4], [7, 7], [7, 8], [7, 13], [7, 14], [8, 3], [8, 7], [8, 14], [9, 9], [9, 13], [10, 8], [10, 9], [10, 12], [11, 3], [11, 12], [11, 13], [11, 16], [11, 17], [12, 2], [12, 4], [12, 16], [13, 3], [13, 4], [13, 8], [13, 17], [13, 18], [13, 19], [14, 7], [14, 9], [14, 13], [14, 19], [15, 7], [15, 9], [15, 12], [15, 14], [16, 3], [16, 4], [16, 8], [16, 13], [16, 15], [17, 4], [17, 14], [17, 15], [18, 3], [19, 3], [19, 4]], [[2, 6], [2, 12], [3, 6], [3, 12], [4, 6], [4, 7], [4, 11], [4, 12], [6, 2], [6, 3], [6, 4], [6, 7], [6, 8], [6, 10], [6, 11], [6, 14], [6, 15], [6, 16], [7, 4], [7, 6], [7, 8], [7, 10], [7, 12], [7, 14], [8, 6], [8, 7], [8, 11], [8, 12], [10, 6], [10, 7], [10, 11], [10, 12], [11, 4], [11, 6], [11, 8], [11, 10], [11, 12], [11, 14], [12, 2], [12, 3], [12, 4], [12, 7], [12, 8], [12, 10], [12, 11], [12, 14], [12, 15], [12, 16], [14, 6], [14, 7], [14, 11], [14, 12], [15, 6], [15, 12], [16, 6], [16, 12]]]
    var comments: [String] = ["This grid is just to say hi", "This is a glider", "These patterns are always stable", "This pattern looks like a blinking sun"]
    
    
    static var _sharedTable = ConfigurationViewController()
    static var sharedTable: ConfigurationViewController { get { return _sharedTable } }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up observer to reload the data of the table view
        let s = #selector(ConfigurationViewController.dataReload(_:))
        let c = NSNotificationCenter.defaultCenter()
        c.addObserver(self, selector: s, name: "TableViewReloadData", object: nil)
    }
    
    func dataReload(notification:NSNotification) {
        self.tableView.reloadData()
        self.tableView.setNeedsDisplay()
    }
    
    @IBAction func addEntry(sender: UIBarButtonItem) {
        ConfigurationViewController.sharedTable.names.append("Add new name...")
        ConfigurationViewController.sharedTable.gridContent.append([])
        ConfigurationViewController.sharedTable.comments.append("")
        
        let itemRow = ConfigurationViewController.sharedTable.names.count - 1
        let itemPath = NSIndexPath(forRow:itemRow, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([itemPath], withRowAnimation: .Automatic)
        
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConfigurationViewController.sharedTable.names.count
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
        nameLabel.text = ConfigurationViewController.sharedTable.names[row]
        cell.tag = row
        return cell
    }
    
    override func tableView(tableView: UITableView,
                            commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                                               forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            ConfigurationViewController.sharedTable.names.removeAtIndex(indexPath.row)
            ConfigurationViewController.sharedTable.gridContent.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath],
                                             withRowAnimation: .Automatic)
        }
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        StandardEngine.sharedInstance.changesDetect = false
        let editingRow = (sender as! UITableViewCell).tag
        let editingString = ConfigurationViewController.sharedTable.names[editingRow]
        let editingComment = ConfigurationViewController.sharedTable.comments[editingRow]
        guard let editingVC = segue.destinationViewController as? ConfigurationEditorViewController
            else {
                preconditionFailure("Something went wrong")
        }
        editingVC.name = editingString
        editingVC.comment = editingComment
        editingVC.commit = {
            ConfigurationViewController.sharedTable.names[editingRow] = $0
            let indexPath = NSIndexPath(forRow: editingRow, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath],
                                                  withRowAnimation: .Automatic)
        }
        editingVC.anotherCommit = {
            ConfigurationViewController.sharedTable.gridContent[editingRow] = $0
        }
        editingVC.commitForComment = {
            ConfigurationViewController.sharedTable.comments[editingRow] = $0
        }
        
        //set up the size of the grid according to the content of the row selected
        let max = ConfigurationViewController.sharedTable.gridContent[editingRow].flatMap{$0}.maxElement()
        if let safeMax = max {
            StandardEngine.sharedInstance.rows = (safeMax % 10 != 0) ? (safeMax / 10 + 1) * 10 : safeMax
            StandardEngine.sharedInstance.cols = (safeMax % 10 != 0) ? (safeMax / 10 + 1) * 10 : safeMax
        }
        
        //set the cells on
        let medium:[(Int, Int)] = ConfigurationViewController.sharedTable.gridContent[editingRow].map{return ($0[0], $0[1])}
        GridView().points = medium
        
        //update grid in simulation tab
        if let delegate = StandardEngine.sharedInstance.delegate {
            delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
        }
        
        //update the text fields of row and col in the instrumentation tab
        NSNotificationCenter.defaultCenter().postNotificationName("updateRowAndColText", object: nil, userInfo: nil)
        
        NSNotificationCenter.defaultCenter().postNotificationName("turnOffTimedRefresh", object: nil, userInfo: nil)
        
    }
    

    
}
