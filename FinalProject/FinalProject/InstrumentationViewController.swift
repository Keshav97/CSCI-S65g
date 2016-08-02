//
//  FirstViewController.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

class IntrumentationViewController: UIViewController {

    @IBOutlet weak var numRowsText: UITextField!
    @IBOutlet weak var numColumnsText: UITextField!
    @IBOutlet weak var rowStepper: UIStepper!
    @IBOutlet weak var columnStepper: UIStepper!
    @IBOutlet weak var refreshRateController: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numRowsText.text =  String(Int(StandardEngine.sharedInstance.rows))
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        
        numRowsText.text = String(Int(rowStepper.value))
        numColumnsText.text = String(Int(columnStepper.value))
        
        if let delegate = StandardEngine.sharedInstance.delegate {
            delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
        }
        NSNotificationCenter.defaultCenter().postNotificationName("gridModifyNotification", object: nil, userInfo: nil)
        StandardEngine.sharedInstance.refreshInterval = NSTimeInterval(refreshRateController.value)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        StandardEngine.sharedInstance.refreshInterval = NSTimeInterval(sender.value)
    }
    
    @IBAction func modifyRows(sender: UIStepper) {
        StandardEngine.sharedInstance.rows = Int(sender.value)
        numRowsText.text = String(Int(StandardEngine.sharedInstance.rows))
        
        // Redrawing grid with updated number of rows
        StandardEngine.sharedInstance.grid = Grid(StandardEngine.sharedInstance.rows, StandardEngine.sharedInstance.cols)
    }
    
    @IBAction func modifyColumns(sender: UIStepper) {
        StandardEngine.sharedInstance.cols = Int(sender.value)
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        
        // Redrawing grid with updated number of columns
        StandardEngine.sharedInstance.grid = Grid(StandardEngine.sharedInstance.rows, StandardEngine.sharedInstance.cols)
    }
    
    @IBAction func refreshRateSwitch(sender: UISwitch) {
        if sender.on {
            StandardEngine.sharedInstance.refreshInterval = NSTimeInterval(refreshRateController.value)
        }
        else {
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
        }
    }
}

