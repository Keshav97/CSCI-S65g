//
//  Engine.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import Foundation

protocol EngineDelegateProtocol {
    func engineDidUpdate(withGrid: GridProtocol)
}

protocol EngineProtocol {
    var delegate: EngineDelegateProtocol? { get set }
    var grid: GridProtocol { get }
    var refreshRate: Double { get set }
    var refreshTimer: NSTimer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    func step() -> GridProtocol
}

class StandardEngine: EngineProtocol {
    
    private static var _sharedInstance = StandardEngine(rows: 10, cols: 10)
    
    static var sharedInstance: StandardEngine {
        get {
            return _sharedInstance
        }
    }
    
    var delegate: EngineDelegateProtocol?
    var grid: GridProtocol
    
    // In class, we discussed that we won't cover default values in protocols therefore the value of refreshRate is specified here.
    var refreshRate: Double = 0.0
    var refreshTimer: NSTimer?
    
    var refreshInterval: NSTimeInterval = 0 {
        didSet {
            if refreshInterval != 0 {
                if let timer = refreshTimer { timer.invalidate() }
                let sel = #selector(StandardEngine.timerDidFire(_:))
                refreshTimer = NSTimer.scheduledTimerWithTimeInterval(refreshInterval,
                                                                      target: self,
                                                                      selector: sel,
                                                                      userInfo: nil,
                                                                      repeats: true)
            }
            else if let timer = refreshTimer {
                timer.invalidate()
                self.refreshTimer = nil
            }
        }
    }
    
    
    var rows: Int {
        didSet {
            grid = Grid(rows: self.rows, cols: self.cols) { _, _ in .Empty }
            if let delegate = delegate { delegate.engineDidUpdate(grid) }
            
            NSNotificationCenter.defaultCenter().postNotificationName("gridModifyNotification", object: nil, userInfo: nil)
        }
    }
    var cols: Int {
        didSet {
            grid = Grid(rows: self.rows, cols: self.cols) { _, _ in .Empty }
            if let delegate = delegate { delegate.engineDidUpdate(grid) }
            
            NSNotificationCenter.defaultCenter().postNotificationName("gridModifyNotification", object: nil, userInfo: nil)
        }
    }
    
    init(rows: Int, cols: Int, cellInitializer: CellInitializer = {_ in .Empty }) {
        self.rows = rows
        self.cols = cols
        self.grid = Grid(rows: rows, cols: cols, cellInitializer: cellInitializer)
    }
    
    
    // Calculates and returns the new/updated grid/matrix
    func step() -> GridProtocol {
        let newGrid = Grid(rows: self.rows, cols: self.cols)
        newGrid.cells = grid.cells.map {
            switch grid.neighborsAlive($0.position) {
            case 2 where $0.state.isAlive(),
            3 where $0.state.isAlive():  return Cell($0.position, .Living)
            case 3 where !$0.state.isAlive(): return Cell($0.position, .Born)
            case _ where $0.state.isAlive():  return Cell($0.position, .Died)
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