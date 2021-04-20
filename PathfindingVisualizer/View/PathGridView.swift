//
//  PathGridView.swift
//  PathfindingVisualizer
//
//  Created by Tarlan Askaruly on 19.04.2021.
//

import SwiftUI
struct PathGridView: View {
    @ObservedObject private var viewModel: PathGridViewModel = PathGridViewModel(numberOfRows: 50, numberOfColumns: 50)
    @State private var sliderValue = 10.0
    @State private var numberOfColumns = 10
    
    @State private var editingMode: EditingMode = .startingNode
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Pathfinding Visualization")
                widthSlider(for: geometry.size)
                LazyVGrid(columns: .init(repeating: GridItem(.flexible(minimum: computedWidth(for: geometry.size)), spacing: 0), count: Int(numberOfColumns)), alignment: .leading, spacing: 0) {
                    ForEach(0..<computedNumberOfCells(for: geometry.size), id: \.self) { index in
                        Rectangle()
                            .cornerRadius(10)
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundColor(nodeColor(node: viewModel.nodes[index]))
                            .border(Color.blue.opacity(0.5), width: 0.5)
                            .onTapGesture {
                                switch editingMode {
                                    case .startingNode:
                                        viewModel.chooseStartingNode(x: index/numberOfColumns, y: index%numberOfColumns)
                                    case .finalNode:
                                        viewModel.chooseFinalNode(x: index/numberOfColumns, y: index%numberOfColumns)
                                    case .obstacle:
                                        viewModel.chooseObstacleNode(x: index/numberOfColumns, y: index%numberOfColumns)
                                }
                                
                            }
                            .gesture(panGesture(index: index, for: geometry.size))
                    }
                }
                Spacer()
                HStack(alignment: .center, spacing: 10, content: {
                    Button(action: {
                        editingMode = EditingMode.startingNode
                    }, label: {
                        Text("Starting \n Node")
                    }).padding()
                    Button(action: {
                        editingMode = EditingMode.finalNode
                    }, label: {
                        Text("Final \n Node")
                    }).padding()
                    Button(action: {
                        editingMode = EditingMode.obstacle
                    }, label: {
                        Text("Obstacle \n Node")
                    }).padding()
                })
                Button(action: {
                    print(viewModel.findPath())
                }, label: {
                    Text("Start Djikstra")
                }).padding()
            }
            .onAppear() {
                viewModel.changeDimensions(numberOfRows: computedNumberOfRows(for: geometry.size), numberOfColumns: numberOfColumns)
            }
        }
        .padding(5)
        .ignoresSafeArea(edges: [.horizontal])
    }

    private func nodeColor(node: PathGrid.Node) -> Color {
        if node.isStartingNode {
            return Color.green
        }
        if node.isFinalNode {
            return Color.red
        }
        if node.isObstacle {
            return Color.black.opacity(0.8)
        }
        if node.isPassed {
            return Color.blue
        }
        return Color.white
    }
    
    @State private var location: CGPoint = CGPoint(x: 50, y: 50)
    @State private var last_x_pos: Int?
    @State private var last_y_pos: Int?
    
    private func panGesture(index: Int, for size: CGSize) -> some Gesture {
        return DragGesture()
            .onChanged() { value in
                let x_pos: Int = index/numberOfColumns + Int(ceil(value.location.y / computedWidth(for: size))) - 1
                let y_pos: Int = index%numberOfColumns + Int((ceil(value.location.x / computedWidth(for: size)))) - 1
                
                //print("position: \(x_pos)  \(y_pos)")
                if(x_pos >= 0 && y_pos >= 0 && x_pos < computedNumberOfRows(for: size) && y_pos < numberOfColumns) {
                    switch editingMode {
                        case .startingNode:
                            viewModel.chooseStartingNode(x: x_pos, y: y_pos)
                        case .finalNode:
                            viewModel.chooseFinalNode(x: x_pos, y: y_pos)
                        case .obstacle:
                            if last_y_pos != y_pos || last_x_pos != x_pos {
                                viewModel.chooseObstacleNode(x: x_pos, y: y_pos)
                            }
                    }
                    last_x_pos = x_pos
                    last_y_pos = y_pos
                    //viewModel.chooseStartingNode(x: x_pos, y: y_pos)
                }
                
            
                //viewModel.chooseStartingNode(x: index/numberOfColumns, y: index % computedNumberOfRows(for: size))
            }
    }
    
    @ViewBuilder
    private func widthSlider(for size: CGSize) -> some View {
        Slider(
            value: $sliderValue,
            in: 5...15
        ).onChange(of: sliderValue, perform: { value in
            numberOfColumns = Int(value)
            viewModel.changeDimensions(numberOfRows: computedNumberOfRows(for: size), numberOfColumns: numberOfColumns)
        })
    }
    
    func computedWidth(for size: CGSize) -> CGFloat {
        //print("numberOfColumns: \(numberOfColumns)")
        return CGFloat(size.width / CGFloat(Int(numberOfColumns)))
    }
    
    func computedNumberOfRows(for size: CGSize) -> Int {
        return Int((size.height * 0.8) / computedWidth(for: size))
    }

    func computedNumberOfCells(for size: CGSize) -> Int {
        print("numberOfRows: \(Int((size.height * 0.8) / computedWidth(for: size)))")
        return computedNumberOfRows(for: size) * Int(numberOfColumns)
        //return numberOfColumns * numberOfColumns
    }
    
    
}

extension PathGridView {
    enum EditingMode {
        case startingNode
        case finalNode
        case obstacle
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PathGridView()
    }
}








