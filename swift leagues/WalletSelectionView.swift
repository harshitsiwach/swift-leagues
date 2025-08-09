import SwiftUI

struct WalletSelectionView: View {
    @EnvironmentObject var walletManager: WalletManager
    @Binding var show: Bool

    // This would be populated with actual data, including deep links
    let wallets: [Wallet] = [
        Wallet(name: "MetaMask", imageName: "metamask", deepLink: "metamask://"),
        Wallet(name: "Rainbow", imageName: "rainbow", deepLink: "rainbow://"),
        Wallet(name: "Trust Wallet", imageName: "trustwallet", deepLink: "trust://")
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Connect Wallet").font(.system(size: 24, weight: .bold))
                Spacer()
                Button(action: { withAnimation { show = false } }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .padding(8)
                }
                .buttonStyle(.glass)
            }
            
            VStack(spacing: 15) {
                ForEach(wallets) { wallet in
                    Button(action: {
                        walletManager.connect(wallet: wallet)
                        show = false
                    }) {
                        HStack {
                            // You would have these images in your Assets.xcassets
                            Image(wallet.imageName)
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text(wallet.name).font(.system(size: 16, weight: .medium))
                            Spacer()
                        }
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(25)
        .glassEffect()
    }
}

struct Wallet: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let deepLink: String
}

struct WalletSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WalletSelectionView(show: .constant(true))
            .environmentObject(WalletManager())
    }
}
