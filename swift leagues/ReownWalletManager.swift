import SwiftUI
import Combine

#if canImport(ReownAppKit)
import ReownAppKit
#endif

@MainActor
class ReownWalletManager: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var walletAddress: String?
    @Published var chainId: String?

    #if canImport(ReownAppKit)
    private let appKit = AppKit.instance
    #endif
    private var isConfigured = false

    init() {
        // Lazy configure on first connect to avoid requiring secrets at init
    }

    func connect() {
        #if canImport(ReownAppKit)
        configureIfNeeded()
        // Present Reown AppKit modal to show installed wallets
        appKit.present()
        #else
        print("ReownAppKit not available: ensure the package is linked to the target.")
        #endif
    }

    func disconnect() {
        // TODO: Wire to Reown disconnect API when session management is added
        isConnected = false
        walletAddress = nil
        chainId = nil
    }

    var shortenedAddress: String {
        guard let address = walletAddress else { return "Not Connected" }
        return "\(address.prefix(6))...\(address.suffix(4))"
    }
}

// MARK: - Private helpers
extension ReownWalletManager {
    private func configureIfNeeded() {
        #if canImport(ReownAppKit)
        guard !isConfigured else { return }
        guard let projectId = ProcessInfo.processInfo.environment["REOWN_PROJECT_ID"], !projectId.isEmpty else {
            print("Missing REOWN_PROJECT_ID in environment. Set it in your scheme.")
            return
        }

        let metadata = AppMetadata(
            name: "Swift Leagues",
            description: "Crypto Leagues",
            url: "https://swiftleagues.app",
            icons: [
                "https://raw.githubusercontent.com/reown-com/reown-assets/main/icon.png"
            ]
        )

        do {
            try appKit.configure(projectId: projectId, metadata: metadata)
            isConfigured = true
        } catch {
            print("Failed to configure Reown AppKit: \(error)")
        }
        #endif
    }
}
