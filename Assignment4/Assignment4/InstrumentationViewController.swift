//
//  FirstViewController.swift
//  Assignment4
//
//  Created by Keshav Aggarwal on 15/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController {

    @IBOutlet weak var numRowsText: UITextField!
    @IBOutlet weak var numColumnsText: UITextField!
    @IBOutlet weak var rowStepper: UIStepper!
    @IBOutlet weak var columnStepper: UIStepper!
    
    var engine: EngineProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        engine = StandardEngine.sharedInstance
//        engine.delegate = self
//        numRowsText.text = String(rowStepper.value)
//        numColumnsText.text = String(columnStepper.value)
        
    }

    
    @IBAction func modifyRows(sender: UIStepper) {
        
    }
    
    @IBAction func modifyColumns(sender: UIStepper) {
    }
}

