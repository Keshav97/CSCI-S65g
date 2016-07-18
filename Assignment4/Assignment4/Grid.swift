//
//  Grid.swift
//  Assignment4
//
//  Created by Keshav Aggarwal on 17/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import Foundation



// Defining the 4 possibles states of a cell
enum CellState: String {
    case Living = "Living"
    case Empty = "Empty"
    case Born = "Born"
    case Died = "Died"
    
    // Function that returns the raw value of the state of the cell. Note: It doesn't need the Switch statement
    func description() -> String {
        return self.rawValue
    }
    
    // Function that returns array of all possibles cell states
    static func allValues() -> [CellState] {
        return [.Living, .Empty, .Born, .Died]
    }
    
    // Function that returns the appropriate cell state when a cell is clicked
    static func toggle(value: CellState) -> CellState {
        switch value {
        case .Empty, .Died:
            return .Living
        case .Living, .Born:
            return .Empty
        }
    }
}

// Shifts to find row and column of neighbouring cells
let shifts = [-1, 0, 1]

protocol GridProtocol {
    var rows: Int { get }
    var cols: Int { get }
    init(rows: Int, cols: Int)
    func neighbours(row: Int, col: Int) -> [(Int, Int)]
    subscript(row: Int, col: Int) -> CellState? { get set }
}


class Grid: GridProtocol {
    
    var rows: Int
    var cols: Int
    var grid = [[CellState]]()
    
    required init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        // Initialising the grid matrix
        grid = [[CellState]](count: rows, repeatedValue: [CellState](count: cols, repeatedValue: .Empty))
    }
    
    // Return array of neighbours to a given cell
    func neighbours(row: Int, col: Int) -> [(Int, Int)] {
        var neighbouringCells: [(Int, Int)] = []
        for yShift in shifts {
            for xShift in shifts {
                // Ignoring the cell itself
                if !(xShift == 0 && yShift == 0) {
                    
                    // Handling wrapping for cells along the edges
                    var neighbouringColumn = (col + xShift) % cols
                    if neighbouringColumn == -1 {
                        neighbouringColumn += cols
                    }
                    
                    // Handling wrapping for cells along the edges
                    var neighbouringRow = (row + yShift) % rows
                    if neighbouringRow == -1 {
                        neighbouringRow += rows
                    }
                    
                    // Appending neighbouring cells to array
                    neighbouringCells.append((neighbouringRow, neighbouringColumn))
                }
            }
        }
        return neighbouringCells
    }
    
    subscript(row: Int, col: Int) -> CellState? {
        
        get {
            if row < rows && col < cols {
                return grid[row][col]
            }
            return nil
        }
        
        set {
            if let cellValue = newValue {
                if row >= 0 || row < rows || col >= 0 || col < cols {
                    grid[row][col] = cellValue
                }
            }
        }
    }
}