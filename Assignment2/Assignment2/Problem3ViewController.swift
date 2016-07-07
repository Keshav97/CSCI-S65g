//
//  Problem3ViewController.swift
//  Assignment2
//
//  Created by Keshav Aggarwal on 29/06/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//
//  Description: This view controller deals with the Problem 3 of the Assignment. It contains 2 2D Matrices i.e 'before' and 'after', which represent the state of the cells initially and then in the subsequent frame respectively. This view controller makes use of Engine.swift from where it gets the value of the 'after' matrix.
//

import UIKit

class Problem3ViewController: UIViewController {

    // UI Element
    @IBOutlet weak var displayText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting navigation title
        self.navigationItem.title = "Problem 3";
    }
    
    // UI Element
    @IBAction func runClicked(sender: AnyObject) {
        // Defining the 'before' cell grid
        var before: [[Bool]] = []
        
        // Initialising the 'before' grid/matrix
        for row in 0..<rowSize {
            before.append([])
            for _ in 0..<columnSize {
                // Set current cell to alive/dead using random
                before[row].append(arc4random_uniform(3) == 1)
            }
        }
        
        // Displaying number of alive cells in 'before' grid
        let aliveBefore = countLivingCells(before)
        displayText.text = "The number of cells alive before is \(aliveBefore)."
        
        let after = step(before)
        
        // Displaying number of alive cells in 'after' grid
        let aliveAfter = countLivingCells(after)
        displayText.text = displayText.text + "\nThe number of cells alive after is \(aliveAfter)."
    }
    
    // Counts number of cells alive in a grid
    func countLivingCells(cellGrid: [[Bool]]) -> Int {
        var cellsAlive = 0
        for row in 0..<rowSize {
            for column in 0..<columnSize {
                if(cellGrid[row][column] == true) {
                    cellsAlive += 1
                }
            }
        }
        return cellsAlive
    }

}
