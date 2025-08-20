import SwiftUI
import Combine
import Foundation
// import ReownAppKit  // Commented out until dependencies are installed
// import WalletConnect // Commented out until dependencies are installed
// import Web3         // Commented out until dependencies are installed
// import BigInt       // Commented out until dependencies are installed
import Network
// import URLSession   // This is part of Foundation, no need to import separately
import Security
import LocalAuthentication
import CryptoKit

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme = .dark

    func toggleTheme() {
        colorScheme = (colorScheme == .dark) ? .light : .dark
    }
}

struct NewsApiResponse: Codable {
    let Data: [NewsArticle]
}

struct NewsArticle: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let source: String
    let imageurl: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id, title, source, imageurl, url
    }
}

// MARK: - Contest Details Model
struct ContestDetails: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let sport: String
    let entryFee: Double
    let prizePool: Double
    let startTime: Date
    let endTime: Date
    let maxParticipants: Int
    let currentParticipants: Int
    let state: String

    var participationProgress: Double {
        guard maxParticipants > 0 else { return 0 }
        return min(1.0, Double(currentParticipants) / Double(maxParticipants))
    }
}

// MARK: - ViewModel
class AssetViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var articles: [NewsArticle] = []
    @Published var currentTeam: [AssetSelection] = []
    @Published var isTeamSubmitted: Bool = false // Track if team has been submitted
    @Published var stocks: [Stock] = []
    @Published var searchText = ""
    @Published var activeContests: [ContestDetails] = []
    @Published var selectedAssetType = "Coins"
    
    private var cancellables = Set<AnyCancellable>()

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
    
    var filteredStocks: [Stock] {
        if searchText.isEmpty {
            return stocks
        } else {
            return stocks.filter { stock in
                stock.name.lowercased().contains(searchText.lowercased()) ||
                stock.symbol.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    init() {
        fetchCoins()
        fetchNews()
        fetchStocks()
    }
    
    func fetchNews() {
        guard let url = URL(string: "https://min-api.cryptocompare.com/data/v2/news/?lang=EN") else {
            print("Invalid news URL")
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
            .decode(type: NewsApiResponse.self, decoder: JSONDecoder())
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error fetching news: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] returnedResponse in
                self?.articles = returnedResponse.Data
            }
            .store(in: &cancellables)
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
                if case .failure(let error) = completion {
                    print("Error fetching coins: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] returnedCoins in
                self?.coins = returnedCoins
            }
            .store(in: &cancellables)
    }

    func fetchStocks() {
        let symbols = ["NVDA", "MSFT", "AAPL", "GOOGL", "AMZN", "META", "AVGO", "TSLA", "BRK.B", "TSM", "WMT", "JPM", "V", "ORCL", "LLY", "MA", "NFLX", "XOM", "COST", "JNJ"]
        let urlString = "https://financialmodelingprep.com/api/v3/quote/\(symbols.joined(separator: ","))?apikey=YOUR_API_KEY" // <-- TODO: Replace with your own API key
        
        guard let url = URL(string: urlString) else {
            print("Invalid stocks URL")
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
            .decode(type: [Stock].self, decoder: JSONDecoder())
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error fetching stocks: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] returnedStocks in
                self?.stocks = returnedStocks
            }
            .store(in: &cancellables)
    }

    func loadActiveContests() {
        // Hardcoded contests for demonstration
        let contest1 = ContestDetails(
            name: "Premier League Champions",
            sport: "Football",
            entryFee: 10.0,
            prizePool: 10000.0,
            startTime: Date().addingTimeInterval(-86400), // 1 day ago
            endTime: Date().addingTimeInterval(86400 * 7), // 1 week from now
            maxParticipants: 100,
            currentParticipants: 75,
            state: "Active"
        )
        
        let contest2 = ContestDetails(
            name: "NBA Fantasy Challenge",
            sport: "Basketball",
            entryFee: 25.0,
            prizePool: 5000.0,
            startTime: Date().addingTimeInterval(-172800), // 2 days ago
            endTime: Date().addingTimeInterval(86400 * 5), // 5 days from now
            maxParticipants: 50,
            currentParticipants: 42,
            state: "Active"
        )
        
        let contest3 = ContestDetails(
            name: "Grand Slam Tennis",
            sport: "Tennis",
            entryFee: 5.0,
            prizePool: 2500.0,
            startTime: Date().addingTimeInterval(86400), // 1 day from now
            endTime: Date().addingTimeInterval(86400 * 3), // 3 days from now
            maxParticipants: 200,
            currentParticipants: 0,
            state: "Upcoming"
        )
        
        activeContests = [contest1, contest2, contest3]
    }
    
    func selectPrediction(for asset: any Asset, prediction: AssetSelection.Prediction) {
        if let index = currentTeam.firstIndex(where: { "\($0.asset.id)" == "\(asset.id)" }) {
            if currentTeam[index].prediction == prediction {
                currentTeam.remove(at: index)
            } else {
                currentTeam[index].prediction = prediction
            }
        } else if !isTeamFull() {
            currentTeam.append(AssetSelection(asset: asset, prediction: prediction))
        }
    }

    func isAssetInTeam(_ asset: any Asset) -> Bool {
        currentTeam.contains { "\($0.asset.id)" == "\(asset.id)" }
    }
    
    func isTeamFull() -> Bool {
        currentTeam.count >= 5
    }
    
    func submitTeam(to contest: ContestDetails) {
        // unchanged...
    }
    
    func removeAssetFromTeam(_ asset: any Asset) {
        currentTeam.removeAll { "\($0.asset.id)" == "\(asset.id)" }
    }
    
    func checkIfTeamIsSubmitted() -> Bool {
        return isTeamSubmitted
    }
    
    func markTeamAsSubmitted() {
        isTeamSubmitted = true
    }
    
    func resetTeamSubmission() {
        isTeamSubmitted = false
        // Optionally clear the current team to start fresh
        // currentTeam.removeAll()
    }
}

// MARK: - Main View
@available(iOS 26.0, *)
struct ContentView: View {
    @StateObject private var viewModel = AssetViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedTab = "Home"
    @State private var isSearching = false
    @State private var showTeamPopup = false
    let tabs = ["Home", "My team", "Contest", "Ranking", "Latest"]

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !isSearching {
                        switch selectedTab {
                        case "Home":
                            ContestSlideshowView(contests: viewModel.activeContests)
                            // Add team status bar here instead of in the navigation area
                            if !viewModel.currentTeam.isEmpty {
                                TeamStatusBarView(viewModel: viewModel)
                                    .padding(.horizontal)
                            }
                            PopularAssetsView(viewModel: viewModel)
                        case "My team":
                            MyTeamView()
                        case "Contest":
                            ContestView(contests: viewModel.activeContests)
                        case "Ranking":
                            LeaderboardView()
                        case "Latest":
                            NewsSlideshowView(articles: viewModel.articles)
                        default:
                            Text("\(selectedTab) tab is selected")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 500)
                        }
                    } else {
                        PopularAssetsView(viewModel: viewModel)
                    }
                    Spacer(minLength: 100)
                }
                .padding(.top, 120)
            }
            .background(.regularMaterial)
            
            VStack(spacing: 0) {
                HeaderView(searchText: $viewModel.searchText, isSearching: $isSearching)
                    .padding(.horizontal)
                    .padding(.top, 15)
                
                if !isSearching {
                    LiquidGlassTabBar(selectedTab: $selectedTab, tabs: tabs)
                        .padding(.top, 10) // Increased top padding for more space
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                // Show button only if team is not empty and not submitted
                if !viewModel.currentTeam.isEmpty && !isSearching && !viewModel.checkIfTeamIsSubmitted() {
                    FloatingButtonView(viewModel: viewModel, showPopup: $showTeamPopup)
                }
            }
        }
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.colorScheme)
        .onAppear {
            viewModel.loadActiveContests()
        }
        .sheet(isPresented: $showTeamPopup) {
            TeamPopupView(viewModel: viewModel, show: $showTeamPopup)
                .presentationBackground(.black)
        }
    }
}

// MARK: - Team Status Bar View
@available(iOS 26.0, *)
struct TeamStatusBarView: View {
    @ObservedObject var viewModel: AssetViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Team Status")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Players: \(viewModel.currentTeam.count)/5")
                        .font(.system(size: 14, weight: .medium))
                    
                    Spacer()
                    
                    if viewModel.currentTeam.count > 0 {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            
            Spacer()
            
            if viewModel.currentTeam.count > 0 {
                // Show reset button if team is submitted
                if viewModel.checkIfTeamIsSubmitted() {
                    Button(action: {
                        // Reset team submission status to allow creating a new team
                        viewModel.resetTeamSubmission()
                        // Clear current team to start fresh
                        viewModel.currentTeam.removeAll()
                    }) {
                        Text("New Team")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal, 8)
                } else {
                    Button(action: {
                        // TODO: Show team quick view
                    }) {
                        Image(systemName: "eye")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(.glass)
                    .padding(.trailing, 8)
                }
            }
        }
        .background(.regularMaterial, in: Capsule())
    }
}

// MARK: - Contest Slideshow
@available(iOS 26.0, *)
struct ContestSlideshowView: View {
    let contests: [ContestDetails]
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(contests) { contest in
                ContestDetailsPanelView(details: contest).tag(contest.id)
            }
        }
        .frame(height: 260)
        .padding(.bottom, 10)
        .onReceive(timer) { _ in
            withAnimation(.easeOut(duration: 1.0)) {
                if !contests.isEmpty {
                    currentIndex = (currentIndex + 1) % contests.count
                }
            }
        }
    }
}

// MARK: - Contest Details Panel
@available(iOS 26.0, *)
struct ContestDetailsPanelView: View {
    let details: ContestDetails

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        return df
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header...
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(details.name)
                        .font(.system(size: 22, weight: .bold))
                        .lineLimit(2)
                    Text(details.sport)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(details.state.uppercased())
                    .font(.system(size: 10, weight: .regular))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusColor(for: details.state).opacity(0.2))
                    .foregroundColor(statusColor(for: details.state))
                    .clipShape(Capsule())
            }
            .padding([.horizontal, .top], 20)
            .padding(.bottom, 10)
            // Body...
            VStack(spacing: 4) {
                Text("PRIZE POOL")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(formattedUSD(details.prizePool))
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
            .padding(.vertical, 10)
            // Footer...
            HStack(alignment: .top, spacing: 16) {
                footerMetric(title: "ENTRY", value: formattedUSD(details.entryFee))
                footerMetric(title: "PARTICIPANTS", value: "\(details.currentParticipants)/\(details.maxParticipants)")
            }
            .padding(.horizontal, 20)
            
            ProgressView(value: details.participationProgress)
                .tint(.cyan)
                .padding(.horizontal, 20)
                .padding(.top, 4)
            // Timeline...
            HStack {
                Image(systemName: "calendar.badge.clock")
                Text(dateFormatter.string(from: details.startTime))
                Spacer()
                Image(systemName: "flag.checkered")
                Text(dateFormatter.string(from: details.endTime))
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.secondary)
            .padding(12)
            .background(.black.opacity(0.1))
            .clipShape(Capsule())
            .padding(20)
        }
        .frame(minHeight: 220)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    private func footerMetric(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private func statusColor(for state: String) -> Color {
        switch state {
        case "Active": return .green
        case "Upcoming": return .orange
        case "Finished": return .gray
        default: return .primary
        }
    }
    private func formattedUSD(_ amount: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "USD"
        nf.maximumFractionDigits = (amount < 10) ? 2 : 0
        return nf.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Header View
@available(iOS 26.0, *)
struct HeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var searchText: String
    @Binding var isSearching: Bool

    var body: some View {
        HStack {
            if isSearching {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search by name or symbol...", text: $searchText)
                    Button(action: { withAnimation { isSearching = false; searchText = "" } }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .glassEffect(.regular, in: Capsule())
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            } else {
                Image(systemName: "crown.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.yellow)
                
                Spacer()
                
                // Updated navbar with liquid glass effect and white/greyish icons
                HStack(spacing: 12) {
                    Button(action: { withAnimation { isSearching = true } }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white) // White color
                    }
                    .buttonStyle(.glassProminent)
                    
                    Button(action: { themeManager.toggleTheme() }) {
                        Image(systemName: themeManager.colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white) // White color
                    }
                    .buttonStyle(.glassProminent)
                }
                .buttonBorderShape(.capsule)
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: isSearching)
    }
}

// MARK: - Liquid Glass TabBar
@available(iOS 26.0, *)
struct LiquidGlassTabBar: View {
    @Binding var selectedTab: String
    let tabs: [String]

    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    Image(systemName: icon(for: tab))
                        .font(.system(size: 20))
                        .foregroundColor(selectedTab == tab ? .white : .gray) // White for selected, grey for unselected
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(selectedTab == tab ? .glassProminent : .glassProminent)

            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(.regularMaterial, in: Capsule())
    }
    private func icon(for tab: String) -> String {
        switch tab {
        case "Home": return "house.fill"
        case "My team": return "person.3.fill"
        case "Contest": return "trophy.fill"
        case "Ranking": return "chart.bar.fill"
        case "Latest": return "newspaper.fill"
        default: return "questionmark"
        }
    }
}

// MARK: - News Slideshow
@available(iOS 26.0, *)
struct NewsSlideshowView: View {
    let articles: [NewsArticle]
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack(alignment: .leading) {
            Text("Newsfeed")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal)
                .padding(.bottom, 8)
            if articles.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(articles.prefix(10).indices, id: \.self) { index in
                        NewsCardView(article: articles[index]).tag(index)
                    }
                }
                .frame(height: 180) // Increased from 90 to 180
                .onReceive(timer) { _ in
                    withAnimation(.easeOut(duration: 1.0)) {
                        currentIndex = (currentIndex + 1) % min(10, articles.count)
                    }
                }
            }
        }
    }
}

// MARK: - News Card
@available(iOS 26.0, *)
struct NewsCardView: View {
    let article: NewsArticle
    var body: some View {
        Link(destination: URL(string: article.url)!) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: article.imageurl)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.gray.opacity(0.3))
                        .frame(width: 140, height: 140)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.system(size: 18, weight: .bold))
                        .lineLimit(3)
                    Text(article.source.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.trailing, 8)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
        }
    }
}

// MARK: - Popular Assets
@available(iOS 26.0, *)
struct PopularAssetsView: View {
    @ObservedObject var viewModel: AssetViewModel
    let assetTypes = ["Coins", "Stocks"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popular Assets")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal)

            Picker("Asset Type", selection: $viewModel.selectedAssetType) {
                ForEach(assetTypes, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            if viewModel.selectedAssetType == "Coins" {
                PopularCoinsListView(viewModel: viewModel)
            } else {
                PopularStocksListView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Contest View
@available(iOS 26.0, *)
struct ContestView: View {
    let contests: [ContestDetails]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Live Contests")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal)
            
            if contests.isEmpty {
                EmptyContestFullView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(contests) { contest in
                            ContestCardView(contest: contest)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Contest Card View
@available(iOS 26.0, *)
struct ContestCardView: View {
    let contest: ContestDetails
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        return df
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(contest.name)
                        .font(.system(size: 22, weight: .bold))
                        .lineLimit(2)
                    Text(contest.sport)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(contest.state.uppercased())
                    .font(.system(size: 10, weight: .regular))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusColor(for: contest.state).opacity(0.2))
                    .foregroundColor(statusColor(for: contest.state))
                    .clipShape(Capsule())
            }
            
            // Prize Pool
            VStack(spacing: 4) {
                Text("PRIZE POOL")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(formattedUSD(contest.prizePool))
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
            
            // Metrics
            HStack(alignment: .top, spacing: 16) {
                footerMetric(title: "ENTRY FEE", value: formattedUSD(contest.entryFee))
                footerMetric(title: "PARTICIPANTS", value: "\(contest.currentParticipants)/\(contest.maxParticipants)")
            }
            
            // Progress
            ProgressView(value: contest.participationProgress)
                .tint(.cyan)
            
            // Timeline
            HStack {
                Image(systemName: "calendar.badge.clock")
                Text(dateFormatter.string(from: contest.startTime))
                Spacer()
                Image(systemName: "flag.checkered")
                Text(dateFormatter.string(from: contest.endTime))
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.secondary)
            .padding(12)
            .background(.black.opacity(0.1))
            .clipShape(Capsule())
            
            // Action Button
            Button(action: {
                // TODO: Implement join contest functionality
            }) {
                Text("Join Contest")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(contest.state != "Active")
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
    
    private func footerMetric(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private func statusColor(for state: String) -> Color {
        switch state {
        case "Active": return .green
        case "Upcoming": return .orange
        case "Finished": return .gray
        default: return .primary
        }
    }
    
    private func formattedUSD(_ amount: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "USD"
        nf.maximumFractionDigits = (amount < 10) ? 2 : 0
        return nf.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Empty Contest Full View
@available(iOS 26.0, *)
struct EmptyContestFullView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No contests available")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Check back later for exciting competitions")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Popular Coins List
@available(iOS 26.0, *)
struct PopularCoinsListView: View {
    @ObservedObject var viewModel: AssetViewModel
    var body: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.filteredCoins) { coin in
                NewCoinRowView(coin: coin, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Popular Stocks List
@available(iOS 26.0, *)
struct PopularStocksListView: View {
    @ObservedObject var viewModel: AssetViewModel
    var body: some View {
        VStack(spacing: 12) {
            if viewModel.stocks.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 90)
            } else {
                ForEach(viewModel.filteredStocks) { stock in
                    NewStockRowView(stock: stock, viewModel: viewModel)
                }
            }
        }
    }
}

// MARK: - New Stock Row
@available(iOS 26.0, *)
struct NewStockRowView: View {
    let stock: Stock
    @ObservedObject var viewModel: AssetViewModel

    private var selection: AssetSelection? {
        viewModel.currentTeam.first { "\($0.asset.id)" == "\(stock.id)" }
    }

    private var prediction: AssetSelection.Prediction? {
        selection?.prediction
    }

    private var isTeamFull: Bool {
        viewModel.isTeamFull()
    }
    
    private var isAdded: Bool {
        selection != nil
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder for stock logo
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 24))
                .frame(width: 36, height: 36)
                .background(Color.gray.opacity(0.3))
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(stock.name).font(.system(size: 16, weight: .bold))
                Text(stock.symbol.uppercased()).font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(stock.formattedPrice).font(.system(size: 16, weight: .bold))
                Text(stock.formattedChange).font(.system(size: 14, weight: .medium)).foregroundColor(stock.changeColor)
            }
            
            HStack(spacing: 10) {
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.selectPrediction(for: stock, prediction: .up)
                    }
                }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 20, weight: .bold))
                }
                .tint(.green)
                .disabled(isTeamFull && !isAdded)
                
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.selectPrediction(for: stock, prediction: .down)
                    }
                }) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 20, weight: .bold))
                }
                .tint(.red)
                .disabled(isTeamFull && !isAdded)
            }
            .buttonBorderShape(.circle)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
    }
}

// MARK: - New Coin Row (Glass-Enhanced)
@available(iOS 26.0, *)
struct NewCoinRowView: View {
    let coin: Coin
    @ObservedObject var viewModel: AssetViewModel

    private var selection: AssetSelection? {
        viewModel.currentTeam.first { "\($0.asset.id)" == "\(coin.id)" }
    }

    private var prediction: AssetSelection.Prediction? {
        selection?.prediction
    }

    private var isTeamFull: Bool {
        viewModel.isTeamFull()
    }
    
    private var isAdded: Bool {
        selection != nil
    }
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: coin.image)) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: { ProgressView() }
            .frame(width: 36, height: 36)
            
            VStack(alignment: .leading) {
                Text(coin.name).font(.system(size: 16, weight: .bold))
                Text(coin.symbol.uppercased()).font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
            }
            
            Spacer()
            VStack(alignment: .trailing) {
                Text(coin.formattedPrice).font(.system(size: 16, weight: .bold))
                Text(coin.formattedChange).font(.system(size: 14, weight: .medium)).foregroundColor(coin.changeColor)
            }
            
            HStack(spacing: 10) {
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.selectPrediction(for: coin, prediction: .up)
                    }
                }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 20, weight: .bold))
                }
                .tint(.green)
                .disabled(isTeamFull && !isAdded)
                
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.selectPrediction(for: coin, prediction: .down)
                    }
                }) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 20, weight: .bold))
                }
                .tint(.red)
                .disabled(isTeamFull && !isAdded)
            }
            .buttonBorderShape(.circle)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
    }
}

// MARK: - Floating Button
@available(iOS 26.0, *)
struct FloatingButtonView: View {
    @ObservedObject var viewModel: AssetViewModel
    @Binding var showPopup: Bool

    var body: some View {
        Button(action: {
            if viewModel.currentTeam.count == 5 {
                withAnimation { showPopup = true }
            }
        }) {
            Text("View Team (\(viewModel.currentTeam.count)/5)")
                .font(.system(size: 18, weight: .bold))
                .padding()
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }
}

// MARK: - Team Popup
@available(iOS 26.0, *)
struct TeamPopupView: View {
    @ObservedObject var viewModel: AssetViewModel
    @Binding var show: Bool
    @State private var showContestSelection = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Your Team").font(.system(size: 28, weight: .bold))
                Spacer()
                Button(action: { withAnimation { show = false } }) {
                    Image(systemName: "xmark")
                }
            }
            
            VStack(spacing: 15) {
                ForEach(viewModel.currentTeam) { selection in
                    HStack {
                        if !selection.asset.image.isEmpty, let url = URL(string: selection.asset.image) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 32, height: 32)
                        } else {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 16))
                                .frame(width: 32, height: 32)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        Text(selection.asset.name).font(.system(size: 17, weight: .medium))
                        Spacer()
                        Text(selection.asset.symbol.uppercased()).foregroundColor(.secondary)
                        
                        Button(action: {
                            withAnimation {
                                viewModel.removeAssetFromTeam(selection.asset)
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            Button(action: {
                withAnimation {
                    showContestSelection = true
                }
            }) {
                Text("Submit Team")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(30)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .sheet(isPresented: $showContestSelection) {
            ContestSelectionView(viewModel: viewModel, showTeamPopup: $show)
        }
    }
}

// MARK: - Preview
@available(iOS 26.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}