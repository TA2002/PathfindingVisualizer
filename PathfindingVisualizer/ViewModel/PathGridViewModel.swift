//
//  PathGridViewModel.swift
//  PathfindingVisualizer
//
//  Created by Tarlan Askaruly on 19.04.2021.
//

import Foundation

class PathGridViewModel: ObservableObject {
    @Published private var model: PathGrid
    
    init(numberOfRows: Int, numberOfColumns: Int) {
        model = PathGrid(numberOfRows: numberOfColumns, numberOfColumns: numberOfColumns)
    }
    
    var nodes: [PathGrid.Node] {
        var oneDimensionalArray = [PathGrid.Node]()
        for row in model.nodes {
            oneDimensionalArray.append(contentsOf: row)
        }
        return oneDimensionalArray
    }
    
    func changeDimensions(numberOfRows: Int, numberOfColumns: Int) {
        model.changeDimensions(numberOfRows: numberOfRows, numberOfColumns: numberOfColumns)
    }
    
    func chooseStartingNode(x: Int, y: Int) {
        if x >= 0 && x < model.numberOfRows && y >= 0 && y < model.numberOfColumns {
            model.chooseStartingNode(x: x, y: y)
        }
    }
    
    func chooseFinalNode(x: Int, y: Int) {
        if x >= 0 && x < model.numberOfRows && y >= 0 && y < model.numberOfColumns {
            model.chooseFinalNode(x: x, y: y)
        }
    }
    
    func chooseObstacleNode(x: Int, y: Int) {
        if x >= 0 && x < model.numberOfRows && y >= 0 && y < model.numberOfColumns {
            model.chooseObstacleNode(x: x, y: y)
        }
    }
    
    func findPath() {
        self.pathFinding()
    }
    
}

extension PathGridViewModel {
    func pathFinding() -> [[Int]]? {
        //startTimer()
        var starting_x: Int = 0
        var starting_y: Int = 0
        
        var final_x: Int = 0
        var final_y: Int = 0
        
        for x in (0..<model.numberOfRows) {
            for y in (0..<model.numberOfColumns) {
                if model.nodes[x][y].isStartingNode {
                    starting_x = x
                    starting_y = y
                }
                if model.nodes[x][y].isFinalNode {
                    final_x = x
                    final_y = y
                }
            }
        }
        let path = djikstra(starting_x: starting_x, starting_y: starting_y, final_x: final_x, final_y: final_y)
//        DispatchQueue.global(qos: .userInitiated).sync {
//
//        }
        return path
    }
    
    
    
    func djikstra(starting_x: Int, starting_y: Int, final_x: Int, final_y: Int) -> [[Int]]? {
        let mx = 1000000
        var matrix:Matrix<Int> = Matrix(rows: model.numberOfRows, columns: model.numberOfColumns, defaultValue: mx)
        var p:Matrix<[Int]> = Matrix(rows: model.numberOfRows, columns: model.numberOfColumns, defaultValue: [0])
        var u:Matrix<Bool> = Matrix(rows: model.numberOfRows, columns: model.numberOfColumns, defaultValue: false)
        
        matrix[starting_x, starting_y] = 0
        
        for x in (0..<model.numberOfRows) {
            for y in (0..<model.numberOfColumns) {
                var v_x = -1
                var v_y = -1
                
                for x2 in (0..<model.numberOfRows) {
                    for y2 in (0..<model.numberOfColumns) {
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
                for j in (0..<model.nodes[v_x][v_y].neighbors.count) {
                    let to_x = model.nodes[v_x][v_y].neighbors[j].x
                    let to_y = model.nodes[v_x][v_y].neighbors[j].y
                    
                    let len = 1
                    
                    if matrix[v_x, v_y] + len < matrix[to_x, to_y] {
                        matrix[to_x, to_y] = matrix[v_x, v_y] + len
                        p[to_x, to_y] = [Int]()
                        p[to_x, to_y].append(v_x)
                        p[to_x, to_y].append(v_y)
                    }
                    //nodes[to_x][to_y].isPassed = true;
                }
            }
        }
        
        var v_x = final_x
        var v_y = final_y
        
        var path: [[Int]] = [[Int]]()
        
        var interval = 100
        
        while(v_x != starting_x || v_y != starting_y) {
            //coloring(v_x, v_y, interval)
            path.append([v_x, v_y])
            let temp_p = p[v_x, v_y]
            //print(temp_p)
            v_x = temp_p[0]
            v_y = temp_p[1]
            //interval += 200
        }
        
        path.reverse()
        
        for partOfPath in path {
            coloring(partOfPath[0], partOfPath[1], interval)
            interval += 100
        }
        
        return (path.count != 0) ? path : nil
    }
    
    func coloring(_ v_x: Int, _ v_y: Int, _ interval: Int) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .milliseconds(interval)) {
            DispatchQueue.main.async {
                //print("out: \(v_x) \(v_y)" )
                self.model.nodes[v_x][v_y].isPassed = true
            }
        }
    }
}
