//
//  Brain.swift
//  Assignment3
//
//  Created by Keshav Aggarwal on 11/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import Foundation

class Step {
    
    //    // Size of the matrix
    //    let rowSize = 10
    //    let columnSize = 10
    
    // Shifts to find row and column of neighbouring cells
    let shifts = [-1, 0, 1]
    
    
    // Accepts the 'before' grid/matrix and calculates and returns the 'after' grid/matrix
    func step2(before: [[CellState]], rowSize: Int, columnSize: Int) -> [[CellState]] {
        
        // Defining the 'after' cell grid
        var after: [[CellState]] = []
        
        // Initialising the 'after' grid/matrix
        for row in 0..<rowSize {
            after.append([])
            for _ in 0..<columnSize {
                after[row].append(.Empty)
            }
        }
        
        //
        for row in 0..<rowSize {
            for column in 0..<columnSize {
                let cellNeighbours = neighbours((row, column), rowSize: rowSize, columnSize: columnSize)
                let numberOfNeighboursAlive = countNeighboursAlive2(before, cellNeighbours: cellNeighbours)
                switch numberOfNeighboursAlive {
                // Cell state unchanged
                case 2:
                    switch before[row][column] {
                    case .Born, .Living:
                        after[row][column] = .Living
                    case .Died, .Empty:
                        after[row][column] = .Empty
                    }
                // Cell reproduction
                case 3:
                    switch before[row][column] {
                    case .Born, .Living:
                        after[row][column] = .Living
                    case .Died, .Empty:
                        after[row][column] = .Born
                    }
                // Cell death: overcrowding/undercrowding
                default:
                    switch before[row][column] {
                    case .Born, .Living:
                        after[row][column] = .Died
                    case .Died, .Empty:
                        after[row][column] = .Empty
                    }
                }
            }
        }
        return after
    }
    
    // Counts number of alive neighbours for a given cell
    func countNeighboursAlive2(cellGrid: [[CellState]], cellNeighbours: [(Int, Int)]) -> Int {
        var numberOfNeigbours = 0
        for cell in cellNeighbours {
            let row = cell.0
            let column = cell.1
            // Add count if neighbouring cell is alive
            if cellGrid[row][column] == .Born || cellGrid[row][column] == .Living {
                numberOfNeigbours += 1
            }
        }
        return numberOfNeigbours
    }
    
    // Return array of neighbours to a given cell
    func neighbours(cellCoordinates: (Int, Int), rowSize: Int, columnSize: Int) -> [(Int, Int)]{
        var neighbouringCells: [(Int, Int)] = []
        for yShift in shifts {
            for xShift in shifts {
                // Ignoring the cell itself
                if !(xShift == 0 && yShift == 0) {
                    
                    // Handling wrapping for cells along the edges
                    var neighbouringColumn = (cellCoordinates.1 + xShift) % columnSize
                    if neighbouringColumn == -1 {
                        neighbouringColumn += columnSize
                    }
                    
                    // Handling wrapping for cells along the edges
                    var neighbouringRow = (cellCoordinates.0 + yShift) % rowSize
                    if neighbouringRow == -1 {
                        neighbouringRow += rowSize
                    }
                    
                    // Appending neighbouring cells to array
                    neighbouringCells.append((neighbouringRow, neighbouringColumn))
                }
            }
        }
        return neighbouringCells
    }
    
    
}