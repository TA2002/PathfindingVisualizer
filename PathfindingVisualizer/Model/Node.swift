//
//  Node.swift
//  PathfindingVisualizer
//
//  Created by Tarlan Askaruly on 20.04.2021.
//

import Foundation

extension PathGrid {
    
    struct Node {
        var coordinates: Coordinate
        var neighbors: [Coordinate]
        
        var isStartingNode: Bool {
            didSet {
                if self.isStartingNode == true {
                    self.isObstacle = false
                    self.isFinalNode = false
                }
            }
        }
        
        var isFinalNode: Bool {
            didSet {
                if self.isFinalNode == true {
                    self.isObstacle = false
                    self.isStartingNode = false
                }
            }
        }
        
        var isObstacle: Bool {
            didSet {
                if self.isObstacle == true {
                    self.isStartingNode = false
                    self.isFinalNode = false
                }
            }
        }
        
        var isPartOfPath: Bool = false
        var isVisited: Bool = false
        var isAnimated: Bool = false
        
        
        //var isSelected: Bool = false
        
        init(coordinates: Coordinate, neighbors: [Coordinate]) {
            self.coordinates = coordinates
            self.neighbors = neighbors
            self.isFinalNode = false
            self.isObstacle = false
            self.isStartingNode = false
        }
        
    }
    
}
