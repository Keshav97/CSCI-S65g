//
//  ConfigurationEditorViewController.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

class ConfigurationEditorViewController: UIViewController {

    var name:String?
    var comment:String?
    var commit: (String -> Void)?
    var anotherCommit: ([[Int]] -> Void)?
    var commitForComment: (String -> Void)?
    var savedCells: [[Int]] = []

    @IBOutlet weak var commentField: UITextField!
    
    @IBOutlet weak var gridEditor: GridView!
    
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = name
        commentField.text = comment
        
        //set up the observer which updates the grid in the embed view when gets called
        let s = #selector(ConfigurationEditorViewController.watchForNotifications(_:))
        let c = NSNotificationCenter.defaultCenter()
        c.addObserver(self, selector: s, name: "updateGridInEmbedView", object: nil)
    }
    
    @IBAction func cancelClicked(sender: UIBarButtonItem) {
        
        //if the user changes the grid and hits cancel button, an alert will pop up to confirm the action
        if StandardEngine.sharedInstance.changesDetect{
            
            let alert = UIAlertController(title: "Quit Without Saving", message: "Are you sure you want to quit without saving?", preferredStyle: UIAlertControllerStyle.Alert)
            //add cancel button action
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            alert.addAction(UIAlertAction(title: "Quit", style: UIAlertActionStyle.Default, handler: {(action) -> Void in self.navigationController!.popViewControllerAnimated(true)}))
            
            let op = NSBlockOperation {
                self.presentViewController(alert, animated: true, completion: nil)
            }
            NSOperationQueue.mainQueue().addOperation(op)
        }else{
            navigationController!.popViewControllerAnimated(true)
        }
        //clear the changes detecter
        StandardEngine.sharedInstance.changesDetect = false
    }
    
    
    @IBAction func commentFieldClicked(sender: UITextField) {
        StandardEngine.sharedInstance.changesDetect = true
    }

    @IBAction func saveClicked(sender: UIBarButtonItem) {
        let filteredArray = StandardEngine.sharedInstance.grid.cells.filter{$0.state.isLiving()}.map{return $0.position}
        
        for i in filteredArray{
            savedCells.append([i.row, i.col])
        }
        
        guard let newText = nameField.text, commit = commit
            else { return }
        commit(newText)
        guard let anothercommit = anotherCommit else { return }
        anothercommit(savedCells)
        
        navigationController!.popViewControllerAnimated(true)
        
        //save the comment if there is any
        guard let comment = commentField.text, commitForComment = commitForComment
            else { return }
        commitForComment(comment)
    }
    
    func watchForNotifications(notification:NSNotification){
        gridEditor.setNeedsDisplay()
    }
}
