//
//  Coordinate.swift
//  PathfindingVisualizer
//
//  Created by Tarlan Askaruly on 20.04.2021.
//

import Foundation

extension PathGrid {
    
    struct Coordinate : Equatable {
        var x: Int // x -> top-down
        var y: Int // y -> left-right
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
        
    }
    
}
