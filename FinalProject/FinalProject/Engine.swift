//
//  Engine.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import Foundation

protocol  EngineDelegate: class {
    func engineDidUpdate(withGrid: GridProtocol)
}

protocol EngineProtocol {
    
    var rows: Int { get set }
    var cols: Int { get set }
    var grid: GridProtocol { get }
    weak var delegate: EngineDelegate? { get set }
    var refreshRate:  Float { get set }
    var refreshTimer: NSTimer? { get set }
    func step() -> GridProtocol
    
}

class StandardEngine: EngineProtocol {
    
    static var _sharedInstance: StandardEngine = StandardEngine(20, 20)
    static var sharedInstance: StandardEngine {
        get {
            return _sharedInstance
        }
    }
    
    var grid: GridProtocol
    
    // Declaring rows and columns
    var rows: Int = 20 {
        didSet {
            grid = Grid(self.rows, self.cols) { _,_ in .Empty }
            if let delegate = delegate { delegate.engineDidUpdate(grid) }
        }
    }
    var cols: Int = 20 {
        didSet {
            grid = Grid(self.rows, self.cols) { _,_ in .Empty }
            if let delegate = delegate { delegate.engineDidUpdate(grid) }
        }
    }
    
    // Checks for any changes in the embedded grid
    var checkChanges: Bool = false
    // Checks if the grid is a paused state or running
    var isPaused: Bool = false
    weak var delegate: EngineDelegate?
    var refreshRate: Float = 0.0
    var refreshTimer: NSTimer?
    
    subscript (i: Int, j: Int) -> CellState {
        get {
            return grid.cells[i * cols + j].state
        }
        set {
            grid.cells[i * cols + j].state = newValue
        }
    }

    
    var refreshInterval: NSTimeInterval = 0 {
        didSet {
            if refreshInterval != 0 {
                let correctedInterval = 1 / refreshInterval
                if let timer = refreshTimer { timer.invalidate() }
                let sel = #selector(StandardEngine.timerDidFire(_:))
                refreshTimer = NSTimer.scheduledTimerWithTimeInterval(correctedInterval,
                                                                      target: self,
                                                                      selector: sel,
                                                                      userInfo: nil,
                                                                      repeats: true)
            } else if let timer = refreshTimer {
                timer.invalidate()
                self.refreshTimer = nil
            }
        }
    }
    
    init(_ rows: Int, _ cols: Int, cellInitializer: CellInitializer = { _ in .Empty }) {
        self.rows = rows
        self.cols = cols
        self.grid = Grid(rows, cols, cellInitializer: cellInitializer)
    }
    
    
    // Calculates and returns the new/updated grid/matrix
    func step() -> GridProtocol {
        let newGrid = Grid(self.rows, self.cols)
        newGrid.cells = grid.cells.map {
            switch grid.livingNeighbors($0.position) {
            case 2 where $0.state.isLiving(),
            3 where $0.state.isLiving():  return Cell($0.position, .Alive)
            case 3 where !$0.state.isLiving(): return Cell($0.position, .Born)
            case _ where $0.state.isLiving():  return Cell($0.position, .Died)
            default:                           return Cell($0.position, .Empty)
            }
        }
        grid = newGrid
        if let delegate = delegate { delegate.engineDidUpdate(grid) }
        return grid
    }
    
    @objc func timerDidFire(timer: NSTimer) {
        StandardEngine.sharedInstance.grid = StandardEngine.sharedInstance.step()
        NSNotificationCenter.defaultCenter().postNotificationName("gridModifyNotification", object: nil, userInfo: nil)
    }
    
}