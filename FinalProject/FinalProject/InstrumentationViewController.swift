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
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var refreshRateLabel: UILabel!
    @IBOutlet weak var refreshSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshSwitch.setOn(false, animated: true)
        
        refreshRateLabel.text = "Refresh Rate: " + String(format: "%.2f", refreshRateController.value) + "Hz"
        
        //set up observer so that when the row and col get changed the numbers in the textfields will get updated
        let s = #selector(IntrumentationViewController.watchForNotifications(_:))
        let c = NSNotificationCenter.defaultCenter()
        c.addObserver(self, selector: s, name: "updateRowAndColText", object: nil)
        
        //set up observer which will switch the timed refresh
        let sel = #selector(IntrumentationViewController.switchTimedRefresh(_:))
        c.addObserver(self, selector: sel, name: "switchTimedRefresh", object: nil)
        
        //set up observer which will turn off the timed refresh when user segues out to the editter grid view
        let selc = #selector(IntrumentationViewController.turnOffTimedRefresh(_:))
        c.addObserver(self, selector: selc, name: "turnOffTimedRefresh", object: nil)

        rowStepper.value = Double(StandardEngine.sharedInstance.rows)
        columnStepper.value = Double(StandardEngine.sharedInstance.cols)
        
        numRowsText.text =  String(Int(StandardEngine.sharedInstance.rows))
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        
        numRowsText.text = String(Int(rowStepper.value))
        numColumnsText.text = String(Int(columnStepper.value))
        
        if let delegate = StandardEngine.sharedInstance.delegate {
            delegate.engineDidUpdate(StandardEngine.sharedInstance.grid)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("gridModifyNotification", object: nil, userInfo: nil)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        StandardEngine.sharedInstance.refreshInterval = NSTimeInterval(sender.value)
        refreshRateLabel.text = "Refresh Rate: " + String(format: "%.2f", sender.value) + "Hz"
        refreshSwitch.setOn(true, animated: true)
        StandardEngine.sharedInstance.refreshRate = sender.value
        StandardEngine.sharedInstance.isPaused = false
    }
    
    @IBAction func modifyRows(sender: UIStepper) {
        StandardEngine.sharedInstance.rows = Int(sender.value)
        numRowsText.text = String(Int(StandardEngine.sharedInstance.rows))
        
        // Redrawing grid with updated number of rows
        StandardEngine.sharedInstance.grid = Grid(StandardEngine.sharedInstance.rows, StandardEngine.sharedInstance.cols)
        
        //post notification to update the grid in the embed view
        NSNotificationCenter.defaultCenter().postNotificationName("updateGridInEmbedView", object: nil, userInfo: nil)
    }
    
    @IBAction func modifyColumns(sender: UIStepper) {
        StandardEngine.sharedInstance.cols = Int(sender.value)
        numColumnsText.text = String(Int(StandardEngine.sharedInstance.cols))
        
        // Redrawing grid with updated number of columns
        StandardEngine.sharedInstance.grid = Grid(StandardEngine.sharedInstance.rows, StandardEngine.sharedInstance.cols)
        
        //post notification to update the grid in the embed view
        NSNotificationCenter.defaultCenter().postNotificationName("updateGridInEmbedView", object: nil, userInfo: nil)
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
        
        //download and parse the JSON file and then update the table view
        ConfigurationViewController.sharedTable.names = []
        ConfigurationViewController.sharedTable.gridContent = []
        
        //if the user enters an invalid url, pop up an alert view
        if let url = urlField.text {
            guard let requestURL: NSURL = NSURL(string: url) else {
                let alertController = UIAlertController(title: "URL Error", message:
                    "Please enter a valid url!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default,handler: nil))
                
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
                                ConfigurationViewController.sharedTable.names.append(collection["title"]! as! String)
                                let arr = collection["contents"].map{return $0 as! [[Int]]}
                                ConfigurationViewController.sharedTable.gridContent.append(arr!)
                            }
                            ConfigurationViewController.sharedTable.comments = ConfigurationViewController.sharedTable.names.map{ _ in return "" }
                        } catch {
                            print("Error with Json: \(error)")
                            ConfigurationViewController.sharedTable.names = []
                            ConfigurationViewController.sharedTable.gridContent = []
                            ConfigurationViewController.sharedTable.comments = []
                            NSNotificationCenter.defaultCenter().postNotificationName("TableViewReloadData", object: nil, userInfo: nil)
                        }
                        
                        //put the table reload process into the main thread to reload it right away
                        let op = NSBlockOperation {
                            NSNotificationCenter.defaultCenter().postNotificationName("TableViewReloadData", object: nil, userInfo: nil)
                        }
                        NSOperationQueue.mainQueue().addOperation(op)
                        
                    }
                    else{
                        //put the pop up window in the main thread for HTTP errors and then pop it up
                        let op = NSBlockOperation {
                            let alertController = UIAlertController(title: "Error", message:
                                "HTTP Error \(safeStatusCode): \(NSHTTPURLResponse.localizedStringForStatusCode(safeStatusCode))           Please enter a valid url", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                            ConfigurationViewController.sharedTable.names = []
                            ConfigurationViewController.sharedTable.gridContent = []
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
                        alertController.addAction(UIAlertAction(title: "OK", style: .Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        //clear the embed table view so that the app will not crash
                        ConfigurationViewController.sharedTable.names = []
                        ConfigurationViewController.sharedTable.gridContent = []
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
                //if user enters a number smaller than 0, pop up an alert
                let alertControllerRow = UIAlertController(title: "Row Error", message:
                    "Please enter a number greater than 0 !", preferredStyle: UIAlertControllerStyle.Alert)
                alertControllerRow.addAction(UIAlertAction(title: "OK", style: .Default,handler: {(alert: UIAlertAction!) in
                    //let the row text field show the current number of row
                    self.numRowsText.text = String(StandardEngine.sharedInstance.rows)
                }))
                
                self.presentViewController(alertControllerRow, animated: true, completion: nil)
            }
        } else {
            //if user enters a double, pop up an alert
            let alertControllerRow = UIAlertController(title: "Row Error", message:
                "Please enter an interger !", preferredStyle: UIAlertControllerStyle.Alert)
            alertControllerRow.addAction(UIAlertAction(title: "OK", style: .Default,handler: {(alert: UIAlertAction!) in
                //let the row text field show the current number of row
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
                //if user enters a number smaller than 0, pop up an alert
                let alertControllerCol = UIAlertController(title: "Column Error", message:
                    "Please enter a number greater than 0 !", preferredStyle: UIAlertControllerStyle.Alert)
                alertControllerCol.addAction(UIAlertAction(title: "OK", style: .Default,handler: {(alert: UIAlertAction!) in
                    //let the col text field show the current number of col
                    self.numColumnsText.text = String(StandardEngine.sharedInstance.cols)
                }))
                
                self.presentViewController(alertControllerCol, animated: true, completion: nil)
            }
        }else {
            //if user enters a double, pop up an alert
            let alertControllerCol = UIAlertController(title: "Column Error", message:
                "Please enter an interger !", preferredStyle: UIAlertControllerStyle.Alert)
            alertControllerCol.addAction(UIAlertAction(title: "OK", style: .Default,handler: {(alert: UIAlertAction!) in
                //let the col text field show the current number of col
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
    
    func switchTimedRefresh(notification:NSNotification){
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
    
    func turnOffTimedRefresh(notification:NSNotification){
        if refreshSwitch.on{
            StandardEngine.sharedInstance.refreshTimer?.invalidate()
            refreshSwitch.setOn(false, animated: true)
            StandardEngine.sharedInstance.isPaused = true
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
}

