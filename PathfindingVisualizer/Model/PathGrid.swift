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
    
    mutating func chooseObstacleNode(x: Int, y: Int) {
        nodes[x][y].isObstacle = !nodes[x][y].isObstacle
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
    
    mutating func findPath() -> [[Int]] {
        var starting_x: Int = 0
        var starting_y: Int = 0
        
        var final_x: Int = 0
        var final_y: Int = 0
        
        for x in (0..<numberOfRows) {
            for y in (0..<numberOfColumns) {
                if nodes[x][y].isStartingNode {
                    starting_x = x
                    starting_y = y
                }
                if nodes[x][y].isFinalNode {
                    final_x = x
                    final_y = y
                }
            }
        }
        
        let path = djikstra(starting_x: starting_x, starting_y: starting_y, final_x: final_x, final_y: final_y)
        return path
    }
    
    mutating func djikstra(starting_x: Int, starting_y: Int, final_x: Int, final_y: Int) -> [[Int]] {
        let mx = 1000000
        var matrix:Matrix<Int> = Matrix(rows: numberOfRows, columns: numberOfColumns, defaultValue: mx)
        var p:Matrix<[Int]> = Matrix(rows: numberOfRows, columns: numberOfColumns, defaultValue: [0])
        var u:Matrix<Bool> = Matrix(rows: numberOfRows, columns: numberOfColumns, defaultValue: false)
        
        matrix[starting_x, starting_y] = 0
        
        for x in (0..<numberOfRows) {
            for y in (0..<numberOfColumns) {
                
                var v_x = -1
                var v_y = -1
                
                for x2 in (0..<numberOfRows) {
                    for y2 in (0..<numberOfColumns) {
                        if (u[x2, y2] == false) && ((v_x == -1 || v_y == -1) || matrix[x2, y2] < matrix[v_x, v_y]) {
                            v_x = x2
                            v_y = y2
                        }
                        
                    }
                }
                
                if matrix[v_x, v_y] == mx {
                    break
                }
                u[v_x, v_y] = true
                for j in (0..<nodes[v_x][v_y].neighbors.count) {
                    let to_x = nodes[v_x][v_y].neighbors[j].x
                    let to_y = nodes[v_x][v_y].neighbors[j].y
                    
                    let len = 1
                    
                    if matrix[v_x, v_y] + len < matrix[to_x, to_y] {
                        matrix[to_x, to_y] = matrix[v_x, v_y] + len
                        p[to_x, to_y] = [Int]()
                        p[to_x, to_y].append(v_x)
                        p[to_x, to_y].append(v_y)
                    }
                }
                
            }
        }
        
        var v_x = final_x
        var v_y = final_y
        
        var path: [[Int]] = [[Int]]()
        
        while(v_x != starting_x || v_y != starting_y) {
            
            nodes[v_x][v_y].isPassed = true
            
            path.append([v_x, v_y])
            let temp_p = p[v_x, v_y]
            print(temp_p)
            v_x = temp_p[0]
            v_y = temp_p[1]
        }
        
        path.reverse()
        return path
    }
    
}
