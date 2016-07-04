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
    
    @IBAction func runClicked(sender: AnyObject) {
        
        // Defining the 'before' cell grid
        var before: [[Bool]] = []
        
        // Initialising the 'before' grid/matrix
        for row in 0..<rowSize {
            before.append([])
            for _ in 0..<columnSize {
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
    
/*-------------------------------PROBLEM 2-------------------------------
     
     @IBAction func runClicked(sender: AnyObject) {
     
        // Defining the 'before' and 'after' cell grids
        var before: [[Bool]] = []
        var after: [[Bool]] = []
     
        // Initialising the 'before' and 'after' grids/ matrices
        for row in 0..<rowSize {
            before.append([])
            after.append([])
            for _ in 0..<columnSize {
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
     
        for row in 0..<rowSize {
            for column in 0..<columnSize {
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
        for row in 0..<rowSize {
            for column in 0..<columnSize {
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
                    var neighbouringColumn = (column + xShift) % columnSize
                    if neighbouringColumn == -1 {
                        neighbouringColumn += columnSize
                    }
                    
                    // Handling wrapping for cells along the edges
                    var neighbouringRow = (row + yShift) % rowSize
                    if neighbouringRow == -1 {
                        neighbouringRow += rowSize
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
