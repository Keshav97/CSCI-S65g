//
//  GridView.swift
//  FinalProject
//
//  Created by Keshav Aggarwal on 28/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit
import Foundation

class GridView: UIView {
    
    
    //set up variables
    
    var points:[(Int,Int)]? {
        get{
            var newValue: [(Int,Int)] = []
            _ = StandardEngine.sharedInstance.grid.cells.map{
                switch $0.state{
                case .Alive: newValue.append($0.position)
                case .Born: newValue.append($0.position)
                default: break
                }
            }
            return newValue
        }
        set(newValue){
            let rows = StandardEngine.sharedInstance.grid.rows
            let cols = StandardEngine.sharedInstance.grid.cols
            StandardEngine.sharedInstance.grid = Grid(rows,cols, cellInitializer: {_ in .Empty})
            if let points = newValue {
                _ = points.map{
                    StandardEngine.sharedInstance.grid[$0.0, $0.1] = .Alive
                }
            }
        }
        
    }
    

    // IBInspectables are not imperative in this Assignent 
    var livingColor: UIColor = UIColor.blueColor()
    var emptyColor: UIColor = UIColor.grayColor()
    var bornColor: UIColor = UIColor.blueColor().colorWithAlphaComponent(0.6)
    var diedColor: UIColor = UIColor.grayColor().colorWithAlphaComponent(0.6)
    var gridColor: UIColor = UIColor.blackColor()
    var gridWidth: CGFloat = 2.0

    
    // Function that displays the grid with the cells in it on the screen
    override func drawRect(rect: CGRect) {
        
        // Create the path
        let gridPath = UIBezierPath()
        
        // Set the path's line width
        gridPath.lineWidth = gridWidth
        
        // The respective x and y coordinates of horizontal line to be drawn
        let rowX = bounds.origin.x
        var rowY = bounds.origin.y
        
        // Distance between 2 rows
        let rowDist = bounds.height / CGFloat(StandardEngine.sharedInstance.rows)
        
        for _ in 0...StandardEngine.sharedInstance.rows {
            
            // Draws horizontal line
            gridPath.moveToPoint(CGPoint(x: rowX, y: rowY))
            gridPath.addLineToPoint(CGPoint(x: rowX + bounds.width, y: rowY))
            rowY += rowDist
        }
        
        // The respective x and y coordinates of vertical line to be drawn
        var colX = bounds.origin.x
        let colY = bounds.origin.y
        
        // Distance between 2 columns
        let colDist = bounds.width / CGFloat(StandardEngine.sharedInstance.cols)
        
        for _ in 0...StandardEngine.sharedInstance.cols {
            
            // Draws vertical line
            gridPath.moveToPoint(CGPoint(x: colX, y: colY))
            gridPath.addLineToPoint(CGPoint(x: colX, y: colY + bounds.height))
            colX += colDist
        }
        
        // Set the stroke color
        gridColor.setStroke()
        
        // Draw the stroke
        gridPath.stroke()
        
        // Fill each cell with the color corresponding to its cell state
        for row in 0..<StandardEngine.sharedInstance.rows {
            for col in 0..<StandardEngine.sharedInstance.cols {
                // Note: Size measurements include 'gridWidth' to make the cells look more attractive
                let rectangle = CGRect(x: CGFloat(col) * colDist + gridWidth / 2, y: CGFloat(row) * rowDist + gridWidth / 2, width: colDist - gridWidth, height: rowDist - gridWidth)
                let path = UIBezierPath(ovalInRect: rectangle)
                switch StandardEngine.sharedInstance.grid[row, col] {
                case .Alive:
                    livingColor.setFill()
                case .Born:
                    bornColor.setFill()
                case .Died:
                    diedColor.setFill()
                case .Empty:
                    emptyColor.setFill()
                }
                path.fill()
            }
        }
    }
    
    
    // Handles the clicking of the cells
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            self.makeTouch(touch)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            self.makeTouch(touch)
            
        }
    }
    
    func makeTouch(touch: UITouch) {
        
        // Determines coordinates of the touch location
        let point = touch.locationInView(self)
        
        // Finds the width and height of a cell
        let cellHeight = (bounds.height) / CGFloat(StandardEngine.sharedInstance.rows)
        let cellWidth = (bounds.width) / CGFloat(StandardEngine.sharedInstance.cols)
        
        // Finds the corresponding row and column indices
        let cellX = Int(CGFloat(point.x) / cellWidth)
        let cellY = Int(CGFloat(point.y) / cellHeight)
        
        //
        if cellX < StandardEngine.sharedInstance.cols && cellY < StandardEngine.sharedInstance.rows && cellX >= 0 && cellY >= 0 {
            StandardEngine.sharedInstance.grid[cellY, cellX] = CellState.toggle(StandardEngine.sharedInstance.grid[cellY, cellX])
        }
        
        // Updates the grid
        let updatedGrid = CGRect(x: CGFloat(cellX) * cellWidth + gridWidth / 2, y: CGFloat(cellY) * cellHeight + gridWidth / 2, width: cellWidth - gridWidth, height: cellHeight - gridWidth)
        
        NSNotificationCenter.defaultCenter().postNotificationName("gridModifyNotification", object: nil, userInfo: nil)
        
        self.setNeedsDisplayInRect(updatedGrid)
        
    }
}
