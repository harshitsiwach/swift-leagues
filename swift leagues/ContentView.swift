import SwiftUI
import Combine

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme = .dark

    func toggleTheme() {
        colorScheme = (colorScheme == .dark) ? .light : .dark
    }
}

struct NewsArticle: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let source: String
    let imageURL: String
}

let mockArticles: [NewsArticle] = [
    .init(title: "Bitcoin Surges 5% Overnight", source: "Crypto Times", imageURL: "https://images.unsplash.com/photo-1518544801417-1c1edb6c6bdb"),
    .init(title: "Ethereum Upgrade Launches", source: "BlockNews", imageURL: "https://images.unsplash.com/photo-1506744038136-46273834b3fb"),
    .init(title: "Altcoins Rally Continues", source: "CoinToday", imageURL: "https://images.unsplash.com/photo-1465101162946-4377e57745c3")
]

// MARK: - Data Model
// The Codable protocol allows us to decode the JSON from the API directly into this struct.
struct Coin: Identifiable, Codable, Equatable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let priceChangePercentage24h: Double

    // This maps the snake_case keys from the API to our camelCase properties.
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case priceChangePercentage24h = "price_change_percentage_24h"
    }

    // Formatted properties for clean display in the UI.
    var formattedPrice: String {
        if currentPrice < 0.01 && currentPrice > 0 {
            return String(format: "$%.6f", currentPrice)
        }
        return String(format: "$%.2f", currentPrice)
    }

    var formattedChange: String {
        String(format: "%@%.2f%%", priceChangePercentage24h >= 0 ? "+" : "", priceChangePercentage24h)
    }
    
    var changeColor: Color {
        priceChangePercentage24h >= 0 ? .green : .red
    }
}

// MARK: - ViewModel (Handles Data and Logic)
// Using a ViewModel separates the data fetching and business logic from the UI code.
class CoinViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var currentTeam: [Coin] = []
    @Published var searchText = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var walletManager: WalletManager?

    // Computed property to filter coins based on search text
    var filteredCoins: [Coin] {
        if searchText.isEmpty {
            return coins
        } else {
            return coins.filter { coin in
                coin.name.lowercased().contains(searchText.lowercased()) ||
                coin.symbol.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    init(walletManager: WalletManager) {
        self.walletManager = walletManager
        fetchCoins()
    }
    
    func fetchCoins() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=1&sparkline=false") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Coin].self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching coins: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] returnedCoins in
                self?.coins = returnedCoins
            }
            .store(in: &cancellables)
    }
    
    func toggleTeamMembership(for coin: Coin) {
        if let index = currentTeam.firstIndex(where: { $0.id == coin.id }) {
            currentTeam.remove(at: index)
        } else if currentTeam.count < 5 {
            currentTeam.append(coin)
        }
    }
    
    func isCoinInTeam(_ coin: Coin) -> Bool {
        currentTeam.contains { $0.id == coin.id }
    }
    
    func isTeamFull() -> Bool {
        currentTeam.count >= 5
    }
    
    func submitTeam() {
        guard let walletAddress = walletManager?.walletAddress else {
            print("Wallet not connected")
            return
        }
        
        Task {
            do {
                try await SupabaseManager.shared.saveTeam(team: currentTeam, walletAddress: walletAddress)
                print("Team submitted!")
                currentTeam.removeAll()
            } catch {
                print("Error saving team: \(error)")
            }
        }
    }
}


// MARK: - Main View
struct ContentView: View {
    @StateObject private var walletManager = WalletManager()
    @StateObject private var viewModel: CoinViewModel
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedTab = "Home"
    @State private var isSearching = false
    @State private var showTeamPopup = false
    @State private var showWalletSheet = false
    let tabs = ["Home", "My team", "Contest", "Ranking", "Latest"]

    init() {
        let walletManager = WalletManager()
        _viewModel = StateObject(wrappedValue: CoinViewModel(walletManager: walletManager))
        _walletManager = StateObject(wrappedValue: walletManager)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Adaptive background color
            Color(uiColor: .systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    HeaderView(searchText: $viewModel.searchText, isSearching: $isSearching, showWalletSheet: $showWalletSheet)
                    
                    if !isSearching {
                        TabNavigationView(selectedTab: $selectedTab, tabs: tabs)
                        NewsSlideshowView(articles: mockArticles)
                        PopularCoinsListView(viewModel: viewModel)
                    } else {
                        // Show search results directly
                        PopularCoinsListView(viewModel: viewModel)
                    }
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
            
            if !viewModel.currentTeam.isEmpty && !isSearching {
                FloatingButtonView(viewModel: viewModel, showPopup: $showTeamPopup)
                    .transition(.move(edge: .bottom).animation(.easeInOut(duration: 0.4)))
            }
        }
        .environmentObject(themeManager)
        .environmentObject(walletManager)
        .preferredColorScheme(themeManager.colorScheme)
        .foregroundColor(Color(uiColor: .label))
        .sheet(isPresented: $showTeamPopup) {
            TeamPopupView(viewModel: viewModel, show: $showTeamPopup)
                .presentationBackground(.regularMaterial)
        }
        .sheet(isPresented: $showWalletSheet) {
            WalletSelectionView(show: $showWalletSheet)
                .presentationBackground(.regularMaterial)
        }
    }
}

// MARK: - Reusable Components

struct HeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var walletManager: WalletManager
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @Binding var showWalletSheet: Bool

    var body: some View {
        HStack {
            if isSearching {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search by name or symbol...", text: $searchText)
                        .foregroundColor(Color(uiColor: .label))
                        .tint(Color(uiColor: .label))
                    Button(action: {
                        withAnimation {
                            isSearching = false
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                    }
                }
                .padding(12)
                .glassEffect()
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            } else {
                Image(systemName: "crown.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.yellow)
                
                Spacer()
                
                GlassEffectContainer {
                    HStack(spacing: 12) {
                        Button(action: { withAnimation { isSearching = true } }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .buttonStyle(.glass)
                        
                        WalletConnectionView(showWalletSheet: $showWalletSheet)
                        
                        Button(action: { themeManager.toggleTheme() }) {
                            Image(systemName: themeManager.colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .buttonStyle(.glass)
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: isSearching)
    }
}

struct TabNavigationView: View {
    @Binding var selectedTab: String
    let tabs: [String]
    @Namespace private var namespace

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        Text(tab)
                            .font(.system(size: 15, weight: .medium))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                    }
                    .glassEffect()
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 44)
    }
}

struct NewsSlideshowView: View {
    let articles: [NewsArticle]
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(articles.indices, id: \.self) { index in
                NewsCardView(article: articles[index]).tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 80)
        .onReceive(timer) { _ in
            withAnimation(.easeOut(duration: 1.0)) {
                currentIndex = (currentIndex + 1) % articles.count
            }
        }
    }
}

struct NewsCardView: View {
    let article: NewsArticle
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .trailing) {
                Text(article.title)
                    .font(.system(size: 16, weight: .bold))
                    .shadow(radius: 3)
                Text(article.source)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect()
    }
}


struct PopularCoinsListView: View {
    @ObservedObject var viewModel: CoinViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popular Coins")
                .font(.system(size: 22, weight: .bold))
            
            VStack(spacing: 18) {
                ForEach(viewModel.filteredCoins) { coin in
                    NewCoinRowView(coin: coin, viewModel: viewModel)
                }
            }
        }
    }
}

struct NewCoinRowView: View {
    let coin: Coin
    @ObservedObject var viewModel: CoinViewModel
    
    var isAdded: Bool { viewModel.isCoinInTeam(coin) }
    var isTeamFull: Bool { viewModel.isTeamFull() }

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: coin.image)) { image in
                image.resizable()
            } placeholder: { ProgressView() }
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(coin.name)
                    .font(.system(size: 15, weight: .bold))
                Text(coin.symbol.uppercased())
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(coin.formattedPrice)
                    .font(.system(size: 15, weight: .bold))
                Text(coin.formattedChange)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(coin.changeColor)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.toggleTeamMembership(for: coin)
                }
            }) {
                if isAdded {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.cyan)
                } else {
                    Text("Add")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isTeamFull ? .gray : .cyan)
                }
            }
            .frame(width: 60, height: 36)
            .disabled(isTeamFull && !isAdded)
        }
        .padding(12)
        .glassEffect()
    }
}

struct FloatingButtonView: View {
    @ObservedObject var viewModel: CoinViewModel
    @Binding var showPopup: Bool

    var body: some View {
        Button(action: {
            if viewModel.currentTeam.count == 5 {
                withAnimation { showPopup = true }
            }
        }) {
            Text("View Team (\(viewModel.currentTeam.count)/5)")
                .font(.system(size: 16, weight: .bold))
                .padding()
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glass)
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }
}

struct TeamPopupView: View {
    @ObservedObject var viewModel: CoinViewModel
    @Binding var show: Bool

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Your Team").font(.system(size: 24, weight: .bold))
                Spacer()
                Button(action: { withAnimation { show = false } }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .padding(8)
                }
                .buttonStyle(.glass)
            }
            
            VStack(spacing: 15) {
                ForEach(viewModel.currentTeam) { coin in
                    HStack {
                        AsyncImage(url: URL(string: coin.image)) { image in image.resizable() } placeholder: { ProgressView() }
                            .frame(width: 30, height: 30)
                        Text(coin.name).font(.system(size: 16, weight: .medium))
                        Spacer()
                        Text(coin.symbol.uppercased()).foregroundColor(.secondary)
                    }
                }
            }
            
            Button(action: {
                withAnimation {
                    viewModel.submitTeam()
                    show = false
                }
            }) {
                Text("Submit Team")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
        }
        .padding(25)
        .glassEffect()
    }
}


// Removed the old Custom Glass Effect View Modifier extension

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
