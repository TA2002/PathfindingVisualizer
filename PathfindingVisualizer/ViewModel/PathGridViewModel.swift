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
        model.chooseStartingNode(x: x, y: y)
    }
    
    func chooseFinalNode(x: Int, y: Int) {
        model.chooseFinalNode(x: x, y: y)
    }
}
