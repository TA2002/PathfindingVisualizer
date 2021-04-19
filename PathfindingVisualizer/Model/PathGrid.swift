//
//  PathGrid.swift
//  PathfindingVisualizer
//
//  Created by Tarlan Askaruly on 19.04.2021.
//

import Foundation

struct PathGrid {
    private(set) var nodes: [[Node]]
    private(set) var numberOfRows: Int
    private(set) var numberOfColumns: Int
    
    private(set) var previousStartingNode: Coordinate?
    private(set) var previousEndingNode: Coordinate?
    
    init(numberOfRows: Int, numberOfColumns: Int) {
        self.numberOfRows = numberOfRows
        self.numberOfColumns = numberOfColumns
        
        nodes = [[Node]]()
        fillArray()
    }
    
    mutating func changeDimensions(numberOfRows: Int, numberOfColumns: Int) {
        self.numberOfRows = numberOfRows
        self.numberOfColumns = numberOfColumns
        
        nodes = [[Node]]()
        fillArray()
    }
    
    mutating func fillArray() {
        for x in (0..<numberOfRows) {
            var row = [Node]()
            for y in (0..<numberOfColumns) {
                let current_coordinates = Coordinate(x: x, y: y)
                row.append(Node(coordinates: current_coordinates, neighbors: addNeighbors(for: current_coordinates)))
            }
            nodes.append(row)
        }
    }
    
    mutating func chooseStartingNode(x: Int, y: Int) {
        if let lastNode = previousStartingNode, lastNode.x < numberOfRows, lastNode.y < numberOfColumns {
            nodes[lastNode.x][lastNode.y].isStartingNode = false
        }
        nodes[x][y].isStartingNode = true
        previousStartingNode = Coordinate(x: x, y: y)
    }
    
    mutating func chooseFinalNode(x: Int, y: Int) {
        if let lastNode = previousEndingNode, lastNode.x < numberOfRows, lastNode.y < numberOfColumns {
            nodes[lastNode.x][lastNode.y].isFinalNode = false
        }
        nodes[x][y].isFinalNode = true
        previousEndingNode = Coordinate(x: x, y: y)
    }
    
    
    func addNeighbors(for coordinates: Coordinate) -> [Coordinate] {
        var neighbors = [Coordinate]()
        if coordinates.x - 1 >= 0 {
            neighbors.append(Coordinate(x: coordinates.x - 1, y: coordinates.y))
        }
        if coordinates.x + 1 < numberOfRows {
            neighbors.append(Coordinate(x: coordinates.x + 1, y: coordinates.y))
        }
        if coordinates.y - 1 >= 0 {
            neighbors.append(Coordinate(x: coordinates.x, y: coordinates.y - 1))
        }
        if coordinates.y + 1 < numberOfColumns {
            neighbors.append(Coordinate(x: coordinates.x, y: coordinates.y + 1))
        }
        return neighbors
    }
    
    
}

extension PathGrid {
    
    struct Coordinate {
        var x: Int // x -> top-down
        var y: Int // y -> left-right
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
        
    }
    
    struct Node {
        var coordinates: Coordinate
        var neighbors: [Coordinate]
        
        var isStartingNode: Bool = false
        var isFinalNode: Bool = false
        var isPassed: Bool = false
        
        init(coordinates: Coordinate, neighbors: [Coordinate]) {
            self.coordinates = coordinates
            self.neighbors = neighbors
        }
        
    }
    
}
