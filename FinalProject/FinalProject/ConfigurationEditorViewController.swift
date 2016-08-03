//
//  ConfigurationEditorViewController.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

class ConfigurationEditorViewController: UIViewController {

    // Set up variables
    var name:String?
    var comment:String?
    var commit: (String -> Void)?
    var anotherCommit: ([[Int]] -> Void)?
    var commitForComment: (String -> Void)?
    var savedCells: [[Int]] = []

    // IBOutlets
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var gridEditor: GridView!
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = name
        commentField.text = comment
        
        // Observer to update embedded grid
        let sel = #selector(ConfigurationEditorViewController.watchForNotifications(_:))
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: sel, name: "UpdateEmbeddedGrid", object: nil)
    }
    
    // IBActions
    @IBAction func cancelClicked(sender: UIBarButtonItem) {
        
        if StandardEngine.sharedInstance.checkChanges {
            
            let alert = UIAlertController(title: "Changes not Saved", message: "Are you sure you want to quit without saving?", preferredStyle: UIAlertControllerStyle.Alert)
            //add cancel button action
            alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "Quit", style: .Destructive, handler: {(action) -> Void in self.navigationController!.popViewControllerAnimated(true)}))
            
            let op = NSBlockOperation {
                self.presentViewController(alert, animated: true, completion: nil)
            }
            NSOperationQueue.mainQueue().addOperation(op)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
        StandardEngine.sharedInstance.checkChanges = false
    }
    
    
    @IBAction func commentFieldClicked(sender: UITextField) {
        StandardEngine.sharedInstance.checkChanges = true
    }

    @IBAction func saveClicked(sender: UIBarButtonItem) {
        let filteredArray = StandardEngine.sharedInstance.grid.cells.filter{$0.state.isLiving()}.map{return $0.position}
        
        for cell in filteredArray {
            savedCells.append([cell.row, cell.col])
        }
        
        guard let newText = nameField.text, commit = commit
            else { return }
        commit(newText)
        
        guard let anothercommit = anotherCommit
            else { return }
        anothercommit(savedCells)
        navigationController!.popViewControllerAnimated(true)
        
        guard let comment = commentField.text, commitForComment = commitForComment
            else { return }
        commitForComment(comment)
    }
    
    func watchForNotifications(notification:NSNotification){
        gridEditor.setNeedsDisplay()
    }
    
    // Hides keyboard when touched anywhere else on the screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
}
