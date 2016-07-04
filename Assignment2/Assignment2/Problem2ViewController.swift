//
//  Problem2ViewController.swift
//  Assignment2
//
//  Created by Keshav Aggarwal on 29/06/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

class Problem2ViewController: UIViewController {

    @IBOutlet weak var displayText: UITextView!
    
    // NIT: Jp comment -- good use of comments
    // Shifts to find row and column of neighbouring cells
    let shifts = [-1, 0, 1]
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        // Setting navigation title
        self.navigationItem.title = "Problem 2";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // NIT: Jp Comment - Two things: 1) One useful thing is to add something like the mark (see below) comment to help arrange things in XCode. Add something like that in your code and look at it in xcode to navigate through the code. Secondly, we usually group the UI Methods together and put internal methods together. Again, these are style things.
    // MARK: - UI Elements
    @IBAction func runClicked(sender: AnyObject) {
        
        // Defining the 'before' cell grid
        var before: [[Bool]] = []
        
        // Initialising the 'before' grid/matrix
        for row in 0..<size {
            before.append([])
            for _ in 0..<size {
                // NIT: This could be simplified. before[row].append(arc4random_uniform(3) == 1)
                if arc4random_uniform(3) == 1 {
                    // Set current cell to alive
                    before[row].append(true)
                } else {
                    // Set current cell to dead
                    before[row].append(false)
                }
            }
        }
        
        // Displaying number of alive cells in 'before' grid
        let aliveBefore = countLivingCells(before)
        displayText.text = "The number of cells alive before is \(aliveBefore)."
        
        let after = step2(before)
        
        // Displaying number of alive cells in 'after' grid
        let aliveAfter = countLivingCells(after)
        displayText.text = displayText.text + "\nThe number of cells alive after is \(aliveAfter)."
    }
    
    // Counts number of cells alive in a grid
    func countLivingCells(cellGrid: [[Bool]]) -> Int {
        var cellsAlive = 0
        for row in 0..<size {
            for column in 0..<size {
                if(cellGrid[row][column] == true) {
                    cellsAlive += 1
                }
            }
        }
        return cellsAlive
    }
    
/*-------------------------------PROBLEM 2-------------------------------
     
     @IBAction func runClicked(sender: AnyObject) {
     
        // Defining the 'before' and 'after' cell grids
        var before: [[Bool]] = []
        var after: [[Bool]] = []
     
        // Initialising the 'before' and 'after' grids/ matrices
        for row in 0..<size {
            before.append([])
            after.append([])
            for _ in 0..<size {
                if arc4random_uniform(3) == 1 {
                    // set current cell to alive
                    before[row].append(true)
                } else {
                    // set current cell to dead
                    before[row].append(false)
                }
                after[row].append(false)
            }
        }
     
        // Displaying number of alive cells in 'before' grid
        let aliveBefore = countLivingCells(before)
        displayText.text = displayText.text + "\nThe number of cells alive before is \(aliveBefore)."
     
        for row in 0..<size {
            for column in 0..<size {
                let numberOfNeighbours = countNeighbours(before, row: row, column: column)
                switch numberOfNeighbours {
                case 2:
                    after[row][column] = before[row][column]
                case 3:
                    after[row][column] = true
                default:
                    break
                }
            }
        }
     
        // Displaying number of alive cells in 'after' grid
        let aliveAfter = countLivingCells(after)
        displayText.text = displayText.text + "\nThe number of cells alive after is \(aliveAfter)."
    }
     
     // Counts number of cells alive in a grid
     func countLivingCells(cellGrid: [[Bool]]) -> Int {
        var cellsAlive = 0
        for row in 0..<size {
            for column in 0..<size {
                if(cellGrid[row][column] == true) {
                    cellsAlive += 1
                }
            }
        }
        return cellsAlive
     }
     
     // Counts number of alive neighbours for a given cell
     func countNeighbours(cellGrid: [[Bool]], row: Int, column: Int) -> Int {
        var numberOfNeigbours = 0
        for yShift in shifts {
            for xShift in shifts {
                // Ignoring the cell itself
                if !(xShift == 0 && yShift == 0) {
                    
                    // Handling wrapping for cells along the edges
                    var neighbouringColumn = (column + xShift) % size
                    if neighbouringColumn == -1 {
                        neighbouringColumn += size
                    }
                    
                    // Handling wrapping for cells along the edges
                    var neighbouringRow = (row + yShift) % size
                    if neighbouringRow == -1 {
                        neighbouringRow += size
                    }
            
                    // Add count if neighbouring cell is alive
                    if cellGrid[neighbouringRow][neighbouringColumn] {
                        numberOfNeigbours += 1
                    }
                }
            }
        }
        return numberOfNeigbours
     }
*/
    
}
