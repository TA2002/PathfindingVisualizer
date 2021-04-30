//
//  PathGridViewModel.swift
//  PathfindingVisualizer
//
//  Created by Tarlan Askaruly on 19.04.2021.
//

import Foundation
import SwiftUI

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
    
    func pathFinding() {
        
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
        djikstra(starting_x: starting_x, starting_y: starting_y, final_x: final_x, final_y: final_y)
        
    }
    
    
    
    func visitedColoring(_ v_x: Int, _ v_y: Int, _ interval: Int) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .milliseconds(interval)) {
            DispatchQueue.main.async {
                //print("visited: \(v_x) \(v_y)"  )
                withAnimation(.linear(duration: 0.25)){
                    self.model.nodes[v_x][v_y].isAnimated = true
                }
            }
        }
    }
    
    
    func djikstra(starting_x: Int, starting_y: Int, final_x: Int, final_y: Int) {
        
        var visitedNodes = [PathGrid.Coordinate]()
        let mx = 1000000
        var distance:Matrix<Int> = Matrix(rows: model.numberOfRows, columns: model.numberOfColumns, defaultValue: mx)
        var previousNode: Matrix<PathGrid.Coordinate> = Matrix(rows: model.numberOfRows, columns: model.numberOfColumns, defaultValue: PathGrid.Coordinate(x: -1, y: -1))
        distance[starting_x, starting_y] = 0
        
        var unvisitedNodes = [PathGrid.Coordinate]()
        
        for x in (0..<model.numberOfRows) {
            for y in (0..<model.numberOfColumns) {
                model.nodes[x][y].isAnimated = false
                model.nodes[x][y].isPartOfPath = false
                model.nodes[x][y].isVisited = false
                unvisitedNodes.append(PathGrid.Coordinate(x: x, y: y))
            }
        }
        
        var interval = 50
        
        while(unvisitedNodes.count > 0) {
            unvisitedNodes.sort {
                distance[$0.x, $0.y] < distance[$1.x, $1.y]
            }
            let closestNode = PathGrid.Coordinate(x: unvisitedNodes.first!.x, y: unvisitedNodes.first!.y)
            unvisitedNodes.remove(at: 0)
            //print("\(closestNode.x)  \(closestNode.y)")
            if model.nodes[closestNode.x][closestNode.y].isObstacle {
                continue
            }
            if distance[closestNode.x, closestNode.y] == mx {
                break
            }
//            visitedColoring(closestNode.x, closestNode.y, interval)
//            interval += 10
            model.nodes[closestNode.x][closestNode.y].isVisited = true
            visitedNodes.append(PathGrid.Coordinate(x: closestNode.x, y: closestNode.y))
            if closestNode == PathGrid.Coordinate(x: final_x, y: final_y) {
                break
            }
            
            for neighbor in model.nodes[closestNode.x][closestNode.y].neighbors {
                if !model.nodes[neighbor.x][neighbor.y].isVisited {
                    distance[neighbor.x, neighbor.y] = distance[closestNode.x, closestNode.y] + 1
                    previousNode[neighbor.x, neighbor.y] = PathGrid.Coordinate(x: closestNode.x, y: closestNode.y)
                }
            }
            
        }
        
        var shortestPathNodes = [PathGrid.Coordinate]()
        var currentNode = PathGrid.Coordinate(x: final_x, y: final_y)
        
        for visitedNode in visitedNodes {
            visitedColoring(visitedNode.x, visitedNode.y, interval)
            interval += 50
        }
        
        
        while(currentNode.x != -1 && currentNode.y != -1) {
            shortestPathNodes.insert(PathGrid.Coordinate(x: currentNode.x, y: currentNode.y), at: 0)
            currentNode = previousNode[currentNode.x, currentNode.y]
        }
        
        var index = 0
        
        let timer = DispatchSource.makeTimerSource()
        
        timer.schedule(deadline: .now() + .milliseconds(interval), repeating: 0.2)
        
        timer.setEventHandler {
            print("Timer fired!")
            DispatchQueue.main.async {
                if index == shortestPathNodes.count{
                    timer.cancel()
                }
                withAnimation(.linear(duration: 0.25)){
                    if index < shortestPathNodes.count {
                        self.model.nodes[shortestPathNodes[index].x][shortestPathNodes[index].y].isPartOfPath = true
                        index += 1
                    }
                }
            }
            
            
        }
        
        timer.activate()
        
//        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(interval)) {
//
//        }
        
        
        
        
//        func pathColoring() {
//
//        }
//
//
//        pathColoring()
        
        
        
//        for pathNode in shortestPathNodes {
//            //print("\(pathNode.x)  \(pathNode.y)")
//
//            interval += 300
//        }
        
        
        
        //return shortestPathNodes
    }
    
    

    
}



