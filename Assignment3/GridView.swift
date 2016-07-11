//
//  GridView.swift
//  Assignment3
//
//  Created by Keshav Aggarwal on 11/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView {
    
    @IBInspectable var rows: Int = 20 {
        didSet {
            var copyArray = [[CellState]]()
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
            var copyArray = [[CellState]]()
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
    @IBInspectable var gridWidth: CGFloat = 5.0
    
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
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
