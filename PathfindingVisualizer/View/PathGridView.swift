//
//  PathGridView.swift
//  PathfindingVisualizer
//
//  Created by Tarlan Askaruly on 19.04.2021.
//

import SwiftUI
struct PathGridView: View {
    @ObservedObject private var viewModel: PathGridViewModel = PathGridViewModel(numberOfRows: 100, numberOfColumns: 100)
    @State private var sliderValue = 10.0
    @State private var numberOfColumns = 10
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Pathfinding Visualization")
                widthSlider(for: geometry.size)
                LazyVGrid(columns: .init(repeating: GridItem(.flexible(minimum: computedWidth(for: geometry.size)), spacing: 0), count: Int(numberOfColumns)), alignment: .leading, spacing: 0) {
                    ForEach(0..<computedNumberOfCells(for: geometry.size), id: \.self) { index in
                        Rectangle()
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundColor(viewModel.nodes[index].isStartingNode ? .green : .white)
                            .border(Color.gray, width: 1)
                            .onTapGesture {
                                viewModel.chooseStartingNode(x: index/numberOfColumns, y: index%numberOfColumns)
                            }
                    }
                }
                Spacer()
                Button(action: {
                    
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
        print("numberOfColumns: \(numberOfColumns)")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PathGridView()
    }
}








