//
//  FirstViewController.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

// ADding comments to test git

import UIKit

class IntrumentationViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var numRowsText: UITextField!
    @IBOutlet weak var numColumnsText: UITextField!
    @IBOutlet weak var rowStepper: UIStepper!
    @IBOutlet weak var columnStepper: UIStepper!
    @IBOutlet weak var refreshRateController: UISlider!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var refreshRateLabel: UILabel!
    @IBOutlet weak var refreshSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshSwitch.setOn(false, animated: true)
        
        refreshRateLabel.text = "Refresh Rate: " + String(format: "%.2f", refreshRateController.value) + "Hz"
        
        rowStepper.value = Double(StandardEngine.sharedInstance.rows)
        columnStepper.value = Double(StandardEngine.sharedInstance.cols)
        
        numRowsText.text =  String(Int(StandardEngine.sharedInstance.rows))
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        
        numRowsText.text = String(Int(rowStepper.value))
        numColumnsText.text = String(Int(columnStepper.value))
        
        // Observer to update row and column textfields
        let sel = #selector(IntrumentationViewController.watchForNotifications(_:))
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: sel, name: "ModifyRowAndColumnText", object: nil)
        
        // Observer to make changes when switch is flipped
        let sel2 = #selector(IntrumentationViewController.makeSwitchChanges(_:))
        center.addObserver(self, selector: sel2, name: "MakeSwitchChanges", object: nil)
        
        // Observer to turn off switch
        let sel3 = #selector(IntrumentationViewController.turnOffSwitch(_:))
        center.addObserver(self, selector: sel3, name: "TurnOffSwitch", object: nil)


        if let delegate = StandardEngine.sharedInstance.delegate {
            delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("gridModifyNotification", object: nil, userInfo: nil)
    }
    
    // IBActions
    @IBAction func sliderValueChanged(sender: UISlider) {
        StandardEngine.sharedInstance.refreshInterval = NSTimeInterval(sender.value)
        refreshRateLabel.text = "Refresh Rate: " + String(format: "%.2f", sender.value) + "Hz"
        StandardEngine.sharedInstance.refreshRate = sender.value
        refreshSwitch.setOn(true, animated: true)
        StandardEngine.sharedInstance.isPaused = false
    }
    
    @IBAction func modifyRows(sender: UIStepper) {
        StandardEngine.sharedInstance.rows = Int(sender.value)
        numRowsText.text = String(Int(StandardEngine.sharedInstance.rows))
        StandardEngine.sharedInstance.grid = Grid(StandardEngine.sharedInstance.rows, StandardEngine.sharedInstance.cols)
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateEmbeddedGrid", object: nil, userInfo: nil)
    }
    
    @IBAction func modifyColumns(sender: UIStepper) {
        StandardEngine.sharedInstance.cols = Int(sender.value)
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        StandardEngine.sharedInstance.grid = Grid(StandardEngine.sharedInstance.rows, StandardEngine.sharedInstance.cols)
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateEmbeddedGrid", object: nil, userInfo: nil)
    }
    
    @IBAction func refreshRateSwitch(sender: UISwitch) {
        if sender.on {
            StandardEngine.sharedInstance.refreshInterval = NSTimeInterval(refreshRateController.value)
            StandardEngine.sharedInstance.refreshRate = refreshRateController.value
            StandardEngine.sharedInstance.isPaused = false
        }
        else {
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
            StandardEngine.sharedInstance.isPaused = true
        }
    }
    
    @IBAction func reloadClicked(sender: UIButton) {
        
        // Parse the JSON file and update TV
        ConfigurationViewController.sharedTable.designNames = []
        ConfigurationViewController.sharedTable.gridContentCoordinates = []
        
        // Handles invalid URL
        if let url = urlField.text {
            guard let requestURL: NSURL = NSURL(string: url) else {
                let alertController = UIAlertController(title: "URL Alert", message:
                    "Please enter a valid url.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .Destructive, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(urlRequest) {
                (data, response, error) -> Void in
                let httpResponse = response as? NSHTTPURLResponse
                let statusCode = httpResponse?.statusCode
                if let safeStatusCode = statusCode {
                    if (safeStatusCode == 200) {
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as? [AnyObject]
                            for i in 0...json!.count - 1 {
                                let pattern = json![i]
                                let collection = pattern as! Dictionary<String, AnyObject>
                                ConfigurationViewController.sharedTable.designNames.append(collection["title"]! as! String)
                                let arr = collection["contents"].map{return $0 as! [[Int]]}
                                ConfigurationViewController.sharedTable.gridContentCoordinates.append(arr!)
                            }
                            ConfigurationViewController.sharedTable.comments = ConfigurationViewController.sharedTable.designNames.map{ _ in return "" }
                        } catch {
                            print("Error with JSON: \(error)")
                            ConfigurationViewController.sharedTable.designNames = []
                            ConfigurationViewController.sharedTable.gridContentCoordinates = []
                            ConfigurationViewController.sharedTable.comments = []
                            NSNotificationCenter.defaultCenter().postNotificationName("TableViewReloadData", object: nil, userInfo: nil)
                        }
                        
                        // Shift to main thread
                        let op = NSBlockOperation {
                            NSNotificationCenter.defaultCenter().postNotificationName("TableViewReloadData", object: nil, userInfo: nil)
                        }
                        NSOperationQueue.mainQueue().addOperation(op)
                        
                    } else {
                        // Handles HTTP errors
                        let op = NSBlockOperation {
                            let alertController = UIAlertController(title: "Error", message:
                                "HTTP Error \(safeStatusCode): \(NSHTTPURLResponse.localizedStringForStatusCode(safeStatusCode))           Please enter a valid url", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                            ConfigurationViewController.sharedTable.designNames = []
                            ConfigurationViewController.sharedTable.gridContentCoordinates = []
                            ConfigurationViewController.sharedTable.comments = []
                            NSNotificationCenter.defaultCenter().postNotificationName("TableViewReloadData", object: nil, userInfo: nil)
                        }
                        NSOperationQueue.mainQueue().addOperation(op)
                    }
                } else {
                    //put the pop up window in the main thread for url errors and then pop it up
                    let op = NSBlockOperation {
                        let alertController = UIAlertController(title: "Error", message:
                            "Please check your url or your Internet connection", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        //clear the embed table view so that the app will not crash
                        ConfigurationViewController.sharedTable.designNames = []
                        ConfigurationViewController.sharedTable.gridContentCoordinates = []
                        ConfigurationViewController.sharedTable.comments = []
                        NSNotificationCenter.defaultCenter().postNotificationName("TableViewReloadData", object: nil, userInfo: nil)
                    }
                    NSOperationQueue.mainQueue().addOperation(op)
                }
            }
            task.resume()
        }
    }
    
    @IBAction func rowEnter(sender: UITextField) {
        if let changeToRow = Int(sender.text!){
            if changeToRow > 0 {
                StandardEngine.sharedInstance.rows = changeToRow
                rowStepper.value = Double(changeToRow)
            }
            else {
                // Handles case when rows entered is less than or equal to 0
                let alertControllerRow = UIAlertController(title: "Row Error", message:
                    "Number of rows cannot be less than 1", preferredStyle: UIAlertControllerStyle.Alert)
                alertControllerRow.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: {(alert: UIAlertAction!) in
                    self.numRowsText.text = String(StandardEngine.sharedInstance.rows)
                }))
                
                self.presentViewController(alertControllerRow, animated: true, completion: nil)
            }
        } else {
            // Handles case when rows entered is not a whole number
            let alertControllerRow = UIAlertController(title: "Row Error", message:
                "Number of rows can only be Whole Numbers", preferredStyle: UIAlertControllerStyle.Alert)
            alertControllerRow.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: {(alert: UIAlertAction!) in
                self.numRowsText.text = String(StandardEngine.sharedInstance.rows)
            }))
            
            self.presentViewController(alertControllerRow, animated: true, completion: nil)
        }

    }
    
    
    @IBAction func colEnter(sender: UITextField) {
        if let changeToCol = Int(sender.text!){
            if changeToCol > 0 {
                StandardEngine.sharedInstance.cols = changeToCol
                columnStepper.value = Double(changeToCol)
            }
            else {
                // Handles case when columns entered is less than or equal to 0
                let alertControllerCol = UIAlertController(title: "Column Error", message:
                    "Number of columns cannot be less than 1", preferredStyle: UIAlertControllerStyle.Alert)
                alertControllerCol.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: {(alert: UIAlertAction!) in
                    self.numColumnsText.text = String(StandardEngine.sharedInstance.cols)
                }))
                
                self.presentViewController(alertControllerCol, animated: true, completion: nil)
            }
        }else {
            // Handles case when rows entered is not a whole number
            let alertControllerCol = UIAlertController(title: "Column Error", message:
                "Number of columns can only be Whole Numbers", preferredStyle: UIAlertControllerStyle.Alert)
            alertControllerCol.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: {(alert: UIAlertAction!) in
                self.numColumnsText.text = String(StandardEngine.sharedInstance.cols)
            }))
            
            self.presentViewController(alertControllerCol, animated: true, completion: nil)
        }
    }
    
    func watchForNotifications(notification:NSNotification){
        rowStepper.value = Double(StandardEngine.sharedInstance.rows)
        columnStepper.value = Double(StandardEngine.sharedInstance.cols)
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        numRowsText.text = String(Int(StandardEngine.sharedInstance.rows))
    }
    
    func makeSwitchChanges(notification:NSNotification){
        if refreshSwitch.on{
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
            refreshSwitch.setOn(false, animated: true)
            StandardEngine.sharedInstance.isPaused = true
        }
        else{
            refreshSwitch.setOn(true, animated: true)
            StandardEngine.sharedInstance.isPaused = false
        }
    }
    
    func turnOffSwitch(notification:NSNotification){
        if refreshSwitch.on{
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
            refreshSwitch.setOn(false, animated: true)
            StandardEngine.sharedInstance.isPaused = true
        }
    }
    
    // Hides keyboard when touched outside the keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
}

