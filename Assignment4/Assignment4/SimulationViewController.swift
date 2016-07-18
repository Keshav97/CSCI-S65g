//
//  SecondViewController.swift
//  Assignment4
//
//  Created by Keshav Aggarwal on 15/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, EngineDelegateProtocol {

    @IBOutlet weak var grid: GridView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StandardEngine.sharedInstance.delegate = self
        
    }

    func engineDidUpdate(withGrid: GridProtocol) {
        grid.setNeedsDisplay()
    }

    @IBAction func stepClicked(sender: UIButton) {
        StandardEngine.sharedInstance.grid = StandardEngine.sharedInstance.step()
    }
}

