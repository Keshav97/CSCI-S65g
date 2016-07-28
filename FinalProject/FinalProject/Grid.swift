//
//  Grid.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
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
    
    func isAlive() -> Bool {
        switch self {
        case .Living, .Born: return true
        case .Died, .Empty: return false
        }
    }
}

// Variables storing number of cells in different states
var numBorn: Int = 0
var numLiving: Int = 0
var numDied: Int = 0
var numEmpty: Int = 0


typealias Position = (row: Int, col: Int)

typealias Cell = (position: Position, state: CellState)

typealias CellInitializer = (Position) -> CellState

protocol GridProtocol: class {
    var rows: Int { get }
    var cols: Int { get }
    var cells: [Cell] { get }
    
    var alive:  Int { get }
    var dead:   Int { get }
    var living: Int { get }
    var born:   Int { get }
    var died:   Int { get }
    var empty:  Int { get }

    func neighbors(pos: Position) -> [Position]
    func neighborsAlive(position: Position) -> Int
    subscript(row: Int, col: Int) -> CellState? { get set }
}


class Grid: GridProtocol {
    
    private(set) var rows: Int
    private(set) var cols: Int
    var cells: [Cell]
    
    var alive:  Int { return cells.reduce(0) { return  $1.state.isAlive() ?  $0 + 1 : $0 } }
    var dead:   Int { return cells.reduce(0) { return !$1.state.isAlive() ?  $0 + 1 : $0 } }
    var living: Int { return cells.reduce(0) { return  $1.state == .Living  ?  $0 + 1 : $0 } }
    var born:   Int { return cells.reduce(0) { return  $1.state == .Born   ?  $0 + 1 : $0 } }
    var died:   Int { return cells.reduce(0) { return  $1.state == .Died   ?  $0 + 1 : $0 } }
    var empty:  Int { return cells.reduce(0) { return  $1.state == .Empty  ?  $0 + 1 : $0 } }
    
    init(rows: Int, cols: Int, cellInitializer: CellInitializer = {_ in .Empty }) {
        self.rows = rows
        self.cols = cols
        self.cells = (0..<rows*cols).map {
            let pos = Position($0/cols, $0%cols)
            return Cell(pos, cellInitializer(pos))
        }
    }
    
    subscript (row: Int, col: Int) -> CellState? {
        get {
            return cells[row * cols + col].state
        }
        set {
            cells[row * cols + col].state = newValue!
        }
    }
    
    // Position offsets to find row and column of neighbouring cells
    private static let offsets:[Position] = [
        (-1, -1), (-1, 0), (-1, 1),
        ( 0, -1),          ( 0, 1),
        ( 1, -1), ( 1, 0), ( 1, 1)
    ]
    
    func neighbors(pos: Position) -> [Position] {
        return Grid.offsets.map { Position((pos.row + rows + $0.row) % rows,
            (pos.col + cols + $0.col) % cols) }
    }
    
    func neighborsAlive(position: Position) -> Int {
        return neighbors(position)
            .reduce(0) {
                self[$1.row, $1.col]!.isAlive() ? $0 + 1 : $0
        }
    }
}
