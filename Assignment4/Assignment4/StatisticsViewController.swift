//
//  StatisticsViewController.swift
//  Assignment4
//
//  Created by Keshav Aggarwal on 15/07/16.
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
        
        bornCells.text = String(numBorn)
        livingCells.text = String(numLiving)
        diedCells.text = String(numDied)
        emptyCells.text = String(numEmpty)

    }
    
    func watchForNotifications(notification: NSNotification) {
        
        let grid = notification.userInfo!["value"] as! GridProtocol
        let cols = grid.cols
        let rows = grid.rows
        
        for row in 0..<rows{
            for col in 0..<cols{
                switch grid[row, col] {
                case .Born?: numBorn += 1
                case .Living?: numLiving += 1
                case .Died?: numDied += 1
                case .Empty?: numEmpty += 1
                default: break
                }
            }
        }
        
        bornCells.text = String(numBorn)
        livingCells.text = String(numLiving)
        diedCells.text = String(numDied)
        emptyCells.text = String(numEmpty)
        
        // Setting the count to 0
        numLiving = 0
        numBorn = 0
        numDied = 0
        numEmpty = 0
    }
}