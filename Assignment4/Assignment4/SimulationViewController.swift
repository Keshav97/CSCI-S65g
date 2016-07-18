//
//  SecondViewController.swift
//  Assignment4
//
//  Created by Keshav Aggarwal on 15/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, EngineDelegateProtocol {

    var instance: EngineProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instance = StandardEngine.sharedInstance
        instance.delegate = self
        
    }

    func engineDidUpdate(withGrid: GridProtocol) {
        
    }

    @IBAction func stepClicked(sender: UIButton) {
        
    }
}

