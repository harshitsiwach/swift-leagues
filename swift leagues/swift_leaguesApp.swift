//
//  swift_leaguesApp.swift
//  swift leagues
//
//  Created by Harshit Siwach on 31/07/25.
//

import SwiftUI
import Foundation

@main
struct swift_leaguesApp: App {
    @Environment(\.openURL) private var openURL
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: preloadABI)
        }
    }
}

private func preloadABI() {
    if Bundle.main.url(forResource: "ContractABI", withExtension: "json") == nil {
        print("ContractABI.json not found in bundle. Ensure it's added to target membership.")
    }
}
