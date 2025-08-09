import SwiftUI
import Combine
import Web3
import BigInt

// Define a simple error enum for continuation
enum WalletManagerError: Error {
    case unknownResponse
}

@MainActor
class WalletManager: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var walletAddress: String?
    @Published var walletBalance: String = "0.00 ETH"
    @Published var chainId: String?
    
    private var web3: Web3
    private var cancellables = Set<AnyCancellable>()

    init() {
        // RPC URL for BASE Sepolia Testnet (Chain ID 84532)
        self.web3 = Web3(rpcURL: "https://sepolia.base.org") 
    }
    
    // Connect with a manually provided address
    func connect(address: String) {
        guard let ethAddress = try? EthereumAddress(hex: address, eip55: false) else {
            print("Invalid Ethereum address provided.")
            return
        }
        
        self.isConnected = true
        self.walletAddress = ethAddress.hex(eip55: true)
        
        updateBalance()
        updateChainId()
    }
    
    func disconnect() {
        DispatchQueue.main.async {
            self.isConnected = false
            self.walletAddress = nil
            self.walletBalance = "0.00 ETH"
            self.chainId = nil
        }
    }
    
    func updateBalance() {
        guard let addressString = walletAddress else { return }
        
        Task {
            do {
                let address = try EthereumAddress(hex: addressString, eip55: true)
                
                // Bridge callback-based function to async/await
                let balance: BigUInt = try await withCheckedThrowingContinuation { continuation in
                    web3.eth.getBalance(address: address, block: .latest) { response in
                        switch response.status {
                        case .success(let balance):
                            continuation.resume(returning: balance.quantity)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
                
                //let formattedBalance = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 4)
                
                //DispatchQueue.main.async {
                  //  self.walletBalance = "\(formattedBalance ?? "0.00") ETH"
                //}
            //} catch {
              //  print("Error fetching balance: \(error)")
            }
        }
    }
    
    func updateChainId() {
        Task {
            do {
                // Bridge callback-based function to async/await
                let networkId: String = try await withCheckedThrowingContinuation { continuation in
                    web3.net.version { response in
                        switch response.status {
                        case .success(let version):
                            continuation.resume(returning: version)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.chainId = networkId
                    if networkId != "84532" {
                        print("Warning: Connected to network \(networkId), not BASE Testnet (84532)")
                    }
                }
            } catch {
                print("Error fetching network ID: \(error)")
            }
        }
    }
    
    // Utility to shorten address for display
    var shortenedAddress: String {
        guard let address = walletAddress else { return "Not Connected" }
        return "\(address.prefix(6))...\(address.suffix(4))"
    }
}
