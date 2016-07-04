//
//  Engine.swift
//  Assignment2
//
//  Created by Keshav Aggarwal on 02/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

/*
 * NOTES: Jp Comments
 *  Typically, when you create a new class, good coding style is to have comments at the top of the class to explain how
 *  it's used, where it's used, etc...
 *
 * You'll want to set up the properties, methods, etc... for the classes (which you'll continue to learn about in this
 * class).
 */

import Foundation

// NIT: Jp Comment -- This makes the assumption that the grid will be a uniform square. By making that assumption, that could 
//                    cause problems with row/column confusion but are being hidden, because you have identical sizes for both
//                    axises.
// Size of the matrix
let size = 10

// Shifts to find row and column of neighbouring cells
let shifts = [-1, 0, 1]

// NIT: Jp Comment -- Good coding style is to make sure that any public method is commented to let a user know how to use it, clarify the parameters, results, etc...
func step2(before: [[Bool]]) -> [[Bool]] {
    
    // Defining the 'after' cell grid
    var after: [[Bool]] = []
    
    // Initialising the 'after' grid/matrix
    for row in 0..<size {
        after.append([])
        for _ in 0..<size {
            after[row].append(false)
        }
    }
    
    //
    for row in 0..<size {
        for column in 0..<size {
            let cellNeighbours = neighbours((row, column))
            let numberOfNeighboursAlive = countNeighboursAlive(before, cellNeighbours: cellNeighbours)
            // NIT: Jp Comment -- I'd turn this into a state function or something like that that would take a grid, a row/column tuple (the same thing that the neighbors array creates), and returns the state from there (ie; Dead, Starvation, OverPopulation, Alive, Reproduced), as that may turn out to be important in subsequent project assginments.
            switch numberOfNeighboursAlive {
            // Cell state unchanged
            case 2:
                after[row][column] = before[row][column]
            // Cell reproduction
            case 3:
                after[row][column] = true
            // Cell death: overcrowding/undercrowding
            default:
                break
            }
        }
    }
    return after
}

// Counts number of alive neighbours for a given cell
func countNeighboursAlive(cellGrid: [[Bool]], cellNeighbours: [(Int, Int)]) -> Int {
    var numberOfNeigbours = 0
    for cell in cellNeighbours {
        let row = cell.0
        let column = cell.1
        // Add count if neighbouring cell is alive
        if cellGrid[row][column] {
            numberOfNeigbours += 1
        }
    }
    return numberOfNeigbours
}

// Return array of neighbours to a given cell
// NIT: Jp Comment -- I'd use a defined tuple for these, so that you can use the Swift strong type checking. ie; (row: Int, column: Int) and then that could be typeAlias-ed to be the CellCoordinates. You could then use CellCoordinates in the subsequent arguments, etc...
func neighbours(cellCoordinates: (Int, Int)) -> [(Int, Int)]{
    var neighbouringCells: [(Int, Int)] = []
    for yShift in shifts {
        for xShift in shifts {
            // Ignoring the cell itself
            if !(xShift == 0 && yShift == 0) {
                
                // Handling wrapping for cells along the edges
                var neighbouringColumn = (cellCoordinates.1 + xShift) % size
                // NIT: Jp Comment -- Really happy to see this. This is an easy mistake to make.
                if neighbouringColumn == -1 {
                    neighbouringColumn += size
                }
                
                // Handling wrapping for cells along the edges
                var neighbouringRow = (cellCoordinates.0 + yShift) % size
                if neighbouringRow == -1 {
                    neighbouringRow += size
                }
                
                // Appending neighbouring cells to array
                neighbouringCells.append((neighbouringRow, neighbouringColumn))
            }
        }
    }
    return neighbouringCells
}


/*
-------------------------------PROBLEM 3-------------------------------
 
// Size of the matrix
let size = 10
 
// Shifts to find row and column of neighbouring cells
let shifts = [-1, 0, 1]
 
func step(before: [[Bool]]) -> [[Bool]] {
 
    // Defining the 'after' cell grid
    var after: [[Bool]] = []
 
    // Initialising the 'after' grid/matrix
    for row in 0..<size {
        after.append([])
        for _ in 0..<size {
            after[row].append(false)
        }
    }
 
    for row in 0..<size {
        for column in 0..<size {
            let numberOfNeighbours = countNeighboursAlive(before, row: row, column: column)
            switch numberOfNeighbours {
            // Cell state unchanged
            case 2:
                after[row][column] = before[row][column]
            // Cell reproduction
            case 3:
                after[row][column] = true
            // Cell death: overcrowding/undercrowding
            default:
                break
            }
        }
    }
    return after
}
 
// Counts number of alive neighbours for a given cell
func countNeighboursAlive(cellGrid: [[Bool]], row: Int, column: Int) -> Int {
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
