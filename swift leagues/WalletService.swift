import Foundation
import Combine
import ReownAppKit
import WalletConnectSign

struct URIWrapper: Identifiable {
    let id = UUID()
    let uri: String
}

class WalletService: ObservableObject {
    @Published var walletAddress: String?
    @Published var walletConnectURI: URIWrapper?

    private let projectId = "69a707270e85426363932965ab26ed21"
    private var cancellables = Set<AnyCancellable>()

    init() {
        let metadata = AppMetadata(
            name: "swift leagues",
            description: "swift leagues",
            url: "https://walletconnect.com",
            icons: ["https://avatars.githubusercontent.com/u/37784886"]
        )

        Networking.configure(projectId: projectId, socketFactory: DefaultSocketFactory())
        Sign.configure(metadata: metadata)
        setupSubscriptions()
    }

    func connectWallet() {
        Task {
            do {
                let uri = try await Sign.instance.connect(requiredNamespaces: ["eip155:1": ProposalNamespace(methods: ["eth_sendTransaction", "personal_sign"], events: ["chainChanged", "accountsChanged"])])

                await MainActor.run {
                    self.walletConnectURI = URIWrapper(uri: uri.absoluteString)
                }

            } catch {
                print("Error connecting to wallet: \(error.localizedDescription)")
            }
        }
    }

    private func setupSubscriptions() {
        Sign.instance.sessionSettleSubscriber
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                self?.walletAddress = session.namespaces.first?.value.accounts.first?.address
            }
            .store(in: &cancellables)
    }
}
