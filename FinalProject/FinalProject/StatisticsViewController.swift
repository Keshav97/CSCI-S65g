//
//  StatisticsViewController.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    
    @IBOutlet weak var bornCells: UITextField!
    @IBOutlet weak var livingCells: UITextField!
    @IBOutlet weak var diedCells: UITextField!
    @IBOutlet weak var emptyCells: UITextField!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sel = #selector(StatisticsViewController.watchForNotifications(_:))
        let centre = NSNotificationCenter.defaultCenter()
        centre.addObserver(self, selector: sel, name: "gridModifyNotification", object: nil)
        
        calculateStatistics()
        
        // default values for the count of cells in different states
        bornCells.text = String(numBorn)
        livingCells.text = String(numLiving)
        diedCells.text = String(numDied)
        emptyCells.text = String(numEmpty)
        
    }
    
    func watchForNotifications(notification: NSNotification) {
        
        // Setting the count to 0
        numLiving = 0
        numBorn = 0
        numDied = 0
        numEmpty = 0
        
        calculateStatistics()
        
        bornCells.text = String(numBorn)
        livingCells.text = String(numLiving)
        diedCells.text = String(numDied)
        emptyCells.text = String(numEmpty)
    }
    
    func calculateStatistics() {
        let grid = StandardEngine.sharedInstance.grid
        let cols = grid.cols
        let rows = grid.rows
        
        for row in 0..<rows{
            for col in 0..<cols{
                switch grid[row, col] {
                case .Born: numBorn += 1
                case .Alive: numLiving += 1
                case .Died: numDied += 1
                case .Empty: numEmpty += 1
                }
            }
        }
    }
}
