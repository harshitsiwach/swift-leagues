import SwiftUI

struct WalletConnectionView: View {
    @EnvironmentObject var walletManager: WalletManager
    @Binding var showWalletSheet: Bool
    
    var body: some View {
        Button(action: {
            if walletManager.isConnected {
                walletManager.disconnect()
            } else {
                showWalletSheet = true
            }
        }) {
            if walletManager.isConnected {
                Text(walletManager.shortenedAddress)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 5)
            } else {
                Image(systemName: "wallet.bifold")
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .buttonStyle(.glass)
    }
}

struct WalletConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnectionView(showWalletSheet: .constant(false))
            .environmentObject(WalletManager())
    }
}
