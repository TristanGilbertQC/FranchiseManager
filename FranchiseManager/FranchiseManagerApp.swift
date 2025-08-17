//
//  FranchiseManagerApp.swift
//  FranchiseManager
//
//  Created by Tristan Gilbert on 2025-08-02.
//

import SwiftUI

@main
struct FranchiseManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1200, minHeight: 800)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1400, height: 900)
    }
}
