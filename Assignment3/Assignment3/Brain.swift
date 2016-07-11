//
//  Brain.swift
//  Assignment3
//
//  Created by Keshav Aggarwal on 11/07/16.
//  Copyright © 2016 Harvard Summer School. All rights reserved.
//

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
    
    func toggle(value: CellState) -> CellState {
        switch value {
        case .Empty, .Died:
            return .Living
        case .Living, .Born:
            return .Empty
        }
    }
}

