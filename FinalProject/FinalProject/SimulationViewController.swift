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
    @IBAction func pauseContinueClicked(sender: UIButton) {
        
        StandardEngine.sharedInstance.isPaused = !StandardEngine.sharedInstance.isPaused
        if StandardEngine.sharedInstance.isPaused{
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
            pauseContinue.enabled = true
            NSNotificationCenter.defaultCenter().postNotificationName("switchTimedRefresh", object: nil, userInfo: nil)
        } else {
            StandardEngine.sharedInstance.refreshInterval = NSTimeInterval(StandardEngine.sharedInstance.refreshRate)
            if let delegate = StandardEngine.sharedInstance.delegate {
                delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
            }
            pauseContinue.enabled = false
            NSNotificationCenter.defaultCenter().postNotificationName("switchTimedRefresh", object: nil, userInfo: nil)
        }
        
    }
    
    @IBAction func saveClicked(sender: UIBarButtonItem) {
        
        //stop the grid from changing while still in the save view
        StandardEngine.sharedInstance.refreshTimer?.invalidate()
        
        let alert = UIAlertController(title: "Save", message: "Please enter a name to save the current grid", preferredStyle: UIAlertControllerStyle.Alert)
        
        //set up the function to remove the observer
        func removeTextFieldObserver() {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: alert.textFields![0])
        }
        
        //add cancel button action
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
            removeTextFieldObserver()
            if !StandardEngine.sharedInstance.isPaused {
                StandardEngine.sharedInstance.refreshInterval = NSTimeInterval(StandardEngine.sharedInstance.refreshRate)
            }
            if let delegate = StandardEngine.sharedInstance.delegate {
                delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
            }
            
        }))
        
        //set up save button actino to use later
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
            if let text = self.inputTextField!.text {
                ConfigurationViewController.sharedTable.names.append(text)
                ConfigurationViewController.sharedTable.comments.append("")
                
                if let point = GridView().points {
                    var medium:[[Int]] = []
                    _ = point.map { medium.append([$0.0, $0.1]) }
                    ConfigurationViewController.sharedTable.gridContent.append(medium)
                }
                
                let itemRow = ConfigurationViewController.sharedTable.names.count - 1
                let itemPath = NSIndexPath(forRow:itemRow, inSection: 0)
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
        
        //disable the save button initially unless the user enters any text
        saveAction.enabled = false
        
        AddAlertSaveAction = saveAction
        
        //add save button
        alert.addAction(saveAction)
        
        //add a text field for user to enter name for the row
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter name:"
            self.inputTextField = textField
            //add observer
            let sel = #selector(self.handleTextFieldTextDidChangeNotification(_:))
            NSNotificationCenter.defaultCenter().addObserver(self, selector: sel, name: UITextFieldTextDidChangeNotification, object: textField)
        })
        
        //pop up the alert view
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //set up the handler to enable the save button when the user enters any text for the name
    func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        let textField = notification.object as! UITextField
        
        // Enforce a minimum length of >= 1 for secure text alerts.
        if let text = textField.text{
            AddAlertSaveAction!.enabled = text.characters.count >= 1
        }
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
}

