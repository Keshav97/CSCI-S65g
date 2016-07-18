//
//  GridView.swift
//  Assignment4
//
//  Created by Keshav Aggarwal on 17/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable class GridView: UIView {

    // IBInpectable Properties
    @IBInspectable var rows: Int = 20 {
        // Reinitialises "grid" to .Empty
        didSet {
            var copyArray: [[CellState]] = []
            for row in 0..<rows {
                copyArray.append([])
                for _ in 0..<cols {
                    copyArray[row].append(.Empty)
                }
            }
            grid = copyArray
        }
    }
    @IBInspectable var cols: Int = 20 {
        // Reinitialises "grid" to .Empty
        didSet {
            var copyArray: [[CellState]] = []
            for row in 0..<rows {
                copyArray.append([])
                for _ in 0..<cols {
                    copyArray[row].append(.Empty)
                }
            }
            grid = copyArray
        }
    }
    @IBInspectable var livingColor: UIColor = UIColor.redColor()
    @IBInspectable var emptyColor: UIColor = UIColor.greenColor()
    @IBInspectable var bornColor: UIColor = UIColor.blueColor()
    @IBInspectable var diedColor: UIColor = UIColor.brownColor()
    @IBInspectable var gridColor: UIColor = UIColor.blackColor()
    @IBInspectable var gridWidth: CGFloat = 3.0
    
    // Matrix holding the states of all the cells
    var grid = [[CellState]]()
    
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
        let rowDist = bounds.height / CGFloat(rows)
        
        for _ in 0...rows {
            
            // Draws horizontal line
            gridPath.moveToPoint(CGPoint(x: rowX, y: rowY))
            gridPath.addLineToPoint(CGPoint(x: rowX + bounds.width, y: rowY))
            rowY += rowDist
        }
        
        // The respective x and y coordinates of vertical line to be drawn
        var colX = bounds.origin.x
        let colY = bounds.origin.y
        
        // Distance between 2 columns
        let colDist = bounds.width / CGFloat(cols)
        
        for _ in 0...cols {
            
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
        for row in 0..<rows {
            for col in 0..<cols {
                // Note: Size measurements include 'gridWidth' to make the cells look more attractive
                let rectangle = CGRect(x: CGFloat(col) * colDist + gridWidth / 2, y: CGFloat(row) * rowDist + gridWidth / 2, width: colDist - gridWidth, height: rowDist - gridWidth)
                let path = UIBezierPath(ovalInRect: rectangle)
                switch grid[row][col] {
                case .Living:
                    livingColor.setFill()
                case .Born:
                    bornColor.setFill()
                case .Empty:
                    emptyColor.setFill()
                case .Died:
                    diedColor.setFill()
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
    
    func makeTouch(touch: UITouch) {
        
        // Determines coordinates of the touch location
        let point = touch.locationInView(self)
        
        // Finds the width and height of a cell
        let cellHeight = (bounds.height) / CGFloat(rows)
        let cellWidth = (bounds.width) / CGFloat(cols)
        
        // Finds the corresponding row and column indices
        let cellX = Int(CGFloat(point.x) / cellWidth)
        let cellY = Int(CGFloat(point.y) / cellHeight)
        
        //
        if cellX < cols && cellY < rows && cellX >= 0 && cellY >= 0 {
            grid[cellY][cellX] = CellState.toggle(grid[cellY][cellX])
        }
        
        // Updates the grid
        let updatedGrid = CGRect(x: CGFloat(cellX) * cellWidth + gridWidth / 2, y: CGFloat(cellY) * cellHeight + gridWidth / 2, width: cellWidth - gridWidth, height: cellHeight - gridWidth)
        self.setNeedsDisplayInRect(updatedGrid)
        
    }

    
}
