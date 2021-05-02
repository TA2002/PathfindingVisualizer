//
//  PathGridView.swift
//  PathfindingVisualizer
//
//  Created by Tarlan Askaruly on 19.04.2021.
//

import SwiftUI
import UIKit

struct PathGridView: View {
    @ObservedObject private var viewModel: PathGridViewModel = PathGridViewModel(numberOfRows: 50, numberOfColumns: 50)
    @State private var sliderValue = 10.0
    @State private var numberOfColumns = 10
    
    @State private var editingMode: EditingMode = .startingNode
    
    @State private var isActive = [true, false, false]
    
    @State private var hideMenu = false
    @State private var hideSettings = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LazyVGrid(columns: .init(repeating: GridItem(.flexible(minimum: computedWidth(for: geometry.size)), spacing: 0), count: Int(numberOfColumns)), alignment: .leading, spacing: 0) {
                    ForEach(0..<computedNumberOfCells(for: geometry.size), id: \.self) { index in
                        Rectangle()
                            .cornerRadius(10)
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundColor(.white)
                            .colorMultiply(nodeColor(node: viewModel.nodes[index]))
                            //.transition(.opacity)
                            .border(Color.blue.opacity(0.5), width: 0.5)
                            .onTapGesture {
                                withAnimation(.linear(duration: 0.5)) {
                                    switch editingMode {
                                        case .startingNode:
                                            viewModel.chooseStartingNode(x: index/numberOfColumns, y: index%numberOfColumns)
                                        case .finalNode:
                                            viewModel.chooseFinalNode(x: index/numberOfColumns, y: index%numberOfColumns)
                                        case .obstacle:
                                            viewModel.chooseObstacleNode(x: index/numberOfColumns, y: index%numberOfColumns)
                                    }
                                }
                            }
                            .gesture(panGesture(index: index, for: geometry.size))
                    }
                }
                
                HStack {
                    Spacer()
                    MenuBuilder(for: geometry.size)
                }
                
            }
            .onAppear() {
                viewModel.changeDimensions(numberOfRows: computedNumberOfRows(for: geometry.size), numberOfColumns: numberOfColumns)
            }
        }
        //.padding(5)
        .ignoresSafeArea(edges: [.all])
    }
    
    @State private var location: CGPoint = CGPoint(x: 50, y: 50)
    @State private var last_x_pos: Int?
    @State private var last_y_pos: Int?
    
    private func panGesture(index: Int, for size: CGSize) -> some Gesture {
        return DragGesture()
            .onEnded() { value in
                withAnimation {
                    hideMenu = false
                }
            }
            .onChanged() { value in
                withAnimation {
                    hideMenu = true
                }
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
                }
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
        if node.isPartOfPath {
            return Color.yellow
        }
        if node.isAnimated {
            return Color.pink.opacity(0.8)
        }
        return Color.white
    }
    
    private func computedWidth(for size: CGSize) -> CGFloat {
        return CGFloat(size.width / CGFloat(Int(numberOfColumns)))
    }
    
    private func computedNumberOfRows(for size: CGSize) -> Int {
        return Int((size.height) / computedWidth(for: size)) + 1
    }

    private func computedNumberOfCells(for size: CGSize) -> Int {
        return computedNumberOfRows(for: size) * Int(numberOfColumns)
    }
    
    @ViewBuilder
    func MenuBuilder(for size: CGSize) -> some View {
        Group {
            if hideMenu {
                
            }
            else {
                VStack(spacing: 0) {
                    
                    Rectangle()
                        .frame(width: CGFloat(size.width / CGFloat(Int(15))), height: CGFloat(size.width / CGFloat(Int(15))), alignment: Alignment.trailing)
                        .foregroundColor(isActive[0] ? Color.green.opacity(0.8) : Color.gray.opacity(0.8))
                        .cornerRadius(20, corners: [.topLeft])
                        .onTapGesture {
                            withAnimation {
                                isActive[0] = true
                                isActive[1] = false
                                isActive[2] = false
                                editingMode = .startingNode
                            }
                            
                    }
                    
                    Divider().frame(width: CGFloat(size.width / CGFloat(Int(15))), height: 2).foregroundColor(Color.black)
                    
                    Rectangle()
                        .frame(width: CGFloat(size.width / CGFloat(Int(15))), height: CGFloat(size.width / CGFloat(Int(15))), alignment: Alignment.trailing)
                        .foregroundColor(isActive[1] ? Color.red.opacity(0.8) : Color.gray.opacity(0.8))
                        .onTapGesture {
                            withAnimation {
                                isActive[1] = true
                                isActive[0] = false
                                isActive[2] = false
                                editingMode = .finalNode
                            }
                        }
                    
                    Divider().frame(width: CGFloat(size.width / CGFloat(Int(15))), height: 2).foregroundColor(Color.black)
                    
                    Rectangle()
                        .frame(width: CGFloat(size.width / CGFloat(Int(15))), height: CGFloat(size.width / CGFloat(Int(15))), alignment: Alignment.trailing)
                        .foregroundColor(isActive[2] ? Color.black.opacity(0.8) : Color.gray.opacity(0.8))
                        .onTapGesture {
                            withAnimation {
                                isActive[2] = true
                                isActive[1] = false
                                isActive[0] = false
                                editingMode = .obstacle
                            }
                            
                        }
                        .cornerRadius(20, corners: [.bottomLeft])
                    
                    ZStack {
                        Circle()
                            .foregroundColor(Color.red)
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Color.white)
                    }
                    .frame(width: CGFloat(size.width / CGFloat(Int(15))), height: CGFloat(size.width / CGFloat(Int(15))), alignment: Alignment.trailing)
                    .padding(.top, 20)
                    .onTapGesture {
                        hideSettings = false
                    }
                    
                    ZStack {
                        Circle()
                            .foregroundColor(Color.red)
                        Image(systemName: "play.fill")
                            .foregroundColor(Color.white)
                    }
                    .frame(width: CGFloat(size.width / CGFloat(Int(15))), height: CGFloat(size.width / CGFloat(Int(15))), alignment: Alignment.trailing)
                    .padding(.top, 5)
                    .onTapGesture {
                        viewModel.findPath()
                    }
                    
                }
            }
        }
    }

    
}

extension PathGridView {
    enum EditingMode: CaseIterable {
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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
