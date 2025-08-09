//
//  swift_leaguesApp.swift
//  swift leagues
//
//  Created by Harshit Siwach on 31/07/25.
//

import SwiftUI
import Foundation
#if canImport(ReownAppKit)
import ReownAppKit
#endif

@main
struct swift_leaguesApp: App {
    @Environment(\.openURL) private var openURL
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    #if canImport(ReownAppKit)
                    AppKit.instance.handleDeepLink(url)
                    #endif
                }
        }
    }
}
