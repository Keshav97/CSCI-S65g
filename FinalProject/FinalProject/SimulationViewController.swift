//
//  SecondViewController.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, EngineDelegate {

    private var inputTextField: UITextField?
    weak var AddAlertSaveAction: UIAlertAction?
    
    // IBOutlets
    @IBOutlet weak var pauseContinue: UIButton!
    @IBOutlet weak var grid: GridView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StandardEngine.sharedInstance.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        pauseContinue.enabled = StandardEngine.sharedInstance.isPaused
    }
    
    func engineDidUpdate(withGrid: GridProtocol) {
        grid.setNeedsDisplay()
    }
    
    // IBActions
    @IBAction func pauseContinueClicked(sender: UIButton) {
        
        StandardEngine.sharedInstance.isPaused = !StandardEngine.sharedInstance.isPaused
        if StandardEngine.sharedInstance.isPaused {
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
            pauseContinue.enabled = true
            NSNotificationCenter.defaultCenter().postNotificationName("MakeSwitchChanges", object: nil, userInfo: nil)
        } else {
            StandardEngine.sharedInstance.refreshInterval = NSTimeInterval(StandardEngine.sharedInstance.refreshRate)
            if let delegate = StandardEngine.sharedInstance.delegate {
                delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
            }
            pauseContinue.enabled = false
            NSNotificationCenter.defaultCenter().postNotificationName("MakeSwitchChanges", object: nil, userInfo: nil)
        }
    }
    
    @IBAction func saveClicked(sender: UIBarButtonItem) {
        
        StandardEngine.sharedInstance.refreshTimer?.invalidate()
        let alert = UIAlertController(title: "Save Preferences", message: "Please enter name to save grid", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Function to remove the observer
        func removeTextFieldObserver() {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: alert.textFields![0])
        }
        
        // Handles Cancel - close without saving
        alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: {(action) -> Void in
            removeTextFieldObserver()
            if !StandardEngine.sharedInstance.isPaused {
                StandardEngine.sharedInstance.refreshInterval = NSTimeInterval(StandardEngine.sharedInstance.refreshRate)
            }
            if let delegate = StandardEngine.sharedInstance.delegate {
                delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
            }
        }))
        
        let saveAction = UIAlertAction(title: "Save", style: .Destructive, handler: {(action) -> Void in
            if let text = self.inputTextField!.text {
                ConfigurationViewController.sharedTable.designNames.append(text)
                ConfigurationViewController.sharedTable.comments.append("")
                
                if let point = GridView().points {
                    var medium:[[Int]] = []
                    _ = point.map { medium.append([$0.0, $0.1]) }
                    ConfigurationViewController.sharedTable.gridContentCoordinates.append(medium)
                }
                
                let rowItem = ConfigurationViewController.sharedTable.designNames.count - 1
                let itemPath = NSIndexPath(forRow:rowItem, inSection: 0)
                ConfigurationViewController().tableView.insertRowsAtIndexPaths([itemPath], withRowAnimation: .Automatic)
                NSNotificationCenter.defaultCenter().postNotificationName("TableViewReloadData", object: nil, userInfo: nil)
            }
            removeTextFieldObserver()
            if !StandardEngine.sharedInstance.isPaused {
                StandardEngine.sharedInstance.refreshInterval = NSTimeInterval(StandardEngine.sharedInstance.refreshRate)
            }
            if let delegate = StandardEngine.sharedInstance.delegate {
                delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
            }
        })
        
        // Disables Save button unless name is entered
        saveAction.enabled = false
        AddAlertSaveAction = saveAction
        alert.addAction(saveAction)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter the name:"
            self.inputTextField = textField
            let sel = #selector(self.nameChange(_:))
            NSNotificationCenter.defaultCenter().addObserver(self, selector: sel, name: UITextFieldTextDidChangeNotification, object: textField)
        })
    
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func resetClicked(sender: UIBarButtonItem) {
    
        let rows = StandardEngine.sharedInstance.grid.rows
        let cols = StandardEngine.sharedInstance.grid.cols
        StandardEngine.sharedInstance.grid = Grid(rows, cols, cellInitializer: {_ in .Empty})
        if let delegate = StandardEngine.sharedInstance.delegate {
            delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
        }
        NSNotificationCenter.defaultCenter().postNotificationName("gridModifyNotification", object: nil, userInfo: nil)
        
    }
    
    @IBAction func stepClicked(sender: UIButton) {
        StandardEngine.sharedInstance.grid = StandardEngine.sharedInstance.step()
        NSNotificationCenter.defaultCenter().postNotificationName("gridModifyNotification", object: nil, userInfo: nil)
    }
    
    
    // Function that handles save button
    func nameChange(notification: NSNotification) {
        let textField = notification.object as! UITextField
        if let text = textField.text{
            AddAlertSaveAction!.enabled = text.characters.count >= 1
        }
    }
}

