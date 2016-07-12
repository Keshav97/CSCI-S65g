//
//  GridView.swift
//  Assignment3
//
//  Created by Keshav Aggarwal on 11/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit
import Foundation

enum CellState: String {
    case Living = "Living"
    case Empty = "Empty"
    case Born = "Born"
    case Died = "Died"
    
    func description() -> String {
        return self.rawValue
    }
    
    static func allValues() -> [CellState] {
        return [.Living, .Empty, .Born, .Died]
    }
    
    static func toggle(value: CellState) -> CellState {
        switch value {
        case .Empty, .Died:
            return .Living
        case .Living, .Born:
            return .Empty
        }
    }
}

@IBDesignable class GridView: UIView {
    
    @IBInspectable var rows: Int = 20 {
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
    
    var grid = [[CellState]]()
    
    override func drawRect(rect: CGRect) {
        
        // Create the path
        let gridPath = UIBezierPath()
        
        // Set the path's line width
        gridPath.lineWidth = gridWidth
        
        let rowX = bounds.origin.x
        var rowY = bounds.origin.y
        let rowDist = bounds.height / CGFloat(rows)
        
        for _ in 0...rows {
            
            //draw horizontal line
            gridPath.moveToPoint(CGPoint(x: rowX, y: rowY))
            gridPath.addLineToPoint(CGPoint(x: rowX + bounds.width, y: rowY))
            rowY += rowDist
        }
        
        var colX = bounds.origin.x
        let colY = bounds.origin.y
        let colDist = bounds.width / CGFloat(cols)
        
        for _ in 0...cols {
            
            // draw vertical line
            gridPath.moveToPoint(CGPoint(x: colX, y: colY))
            gridPath.addLineToPoint(CGPoint(x: colX, y: colY + bounds.height))
            colX += colDist
        }
        
        gridColor.setStroke()
        gridPath.stroke()
        
        
        for row in 0..<rows {
            for col in 0..<cols {
                let rectangle = CGRect(x: CGFloat(col) * colDist, y: CGFloat(row) * rowDist, width: colDist, height: rowDist)
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
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            self.makeTouch(touch)
        }
    }
    
    func makeTouch(touch: UITouch) {
        let point = touch.locationInView(self)
        let cellHeight = (bounds.height) / CGFloat(rows)
        let cellWidth = (bounds.width) / CGFloat(cols)
        let cellX = Int(CGFloat(point.x) / cellWidth)
        let cellY = Int(CGFloat(point.y) / cellHeight)
        
        if cellX < cols && cellY < rows && cellX >= 0 && cellY >= 0 {
            grid[cellY][cellX] = CellState.toggle(grid[cellY][cellX])
        }
        let updatedGrid = CGRect(x: CGFloat(cellX) * cellWidth, y: CGFloat(cellY) * cellHeight, width: cellWidth, height: cellHeight)
        self.setNeedsDisplayInRect(updatedGrid)

    }
}
