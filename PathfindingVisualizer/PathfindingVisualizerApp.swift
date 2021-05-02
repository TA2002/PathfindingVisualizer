//
//  PathfindingVisualizerApp.swift
//  PathfindingVisualizer
//
//  Created by Tarlan Askaruly on 19.04.2021.
//

import SwiftUI

@main
struct PathfindingVisualizerApp: App {
    
    var globalStates = GlobalStates()
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
                .makeConnectable()
                .autoconnect()
    
    var body: some Scene {
        WindowGroup {
            PathGridView()
                .environmentObject(globalStates)
                .onReceive(orientationChanged) { _ in
                                    // Set the state for current device rotation
                    if UIDevice.current.orientation.isFlat {
                                        // ignore orientation change
                    } else {                        globalStates.isLandScape = UIDevice.current.orientation.isLandscape
                    }
        }
    }
    }
}
