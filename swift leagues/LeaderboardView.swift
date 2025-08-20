import SwiftUI
import Combine
import Foundation

// Leaderboard data models
struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let teamId: UInt64
    let teamOwner: String
    let score: UInt64
    let playerNames: [String]
}

struct ContestLeaderboard: Identifiable {
    let id = UUID()
    let contestId: UInt64
    let contestName: String
    let sport: String
    let entries: [LeaderboardEntry]
}

// Leaderboard view model
@available(iOS 26.0, *)
class LeaderboardViewModel: ObservableObject {
    @Published var leaderboards: [ContestLeaderboard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // These would be implemented with actual Web3 calls
    func fetchLeaderboards() {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Mock data for demonstration
            let mockEntries = [
                LeaderboardEntry(rank: 1, teamId: 1001, teamOwner: "0x742d35Cc6634C0532925a3b844Bc454e4438f44e", score: 9500, playerNames: ["Player A", "Player B", "Player C"]),
                LeaderboardEntry(rank: 2, teamId: 1002, teamOwner: "0x95cED938F7990Fe234fFdF39124831b843605e98", score: 8750, playerNames: ["Player D", "Player E", "Player F"]),
                LeaderboardEntry(rank: 3, teamId: 1003, teamOwner: "0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE", score: 8200, playerNames: ["Player G", "Player H", "Player I"])
            ]
            
            let mockLeaderboard = ContestLeaderboard(
                contestId: 1,
                contestName: "Premier League Challenge",
                sport: "Football",
                entries: mockEntries
            )
            
            self.leaderboards = [mockLeaderboard]
            self.isLoading = false
        }
        
        /*
         // Actual implementation would look like this:
         
         // 1. Get finished contest IDs
         // let finishedContestIds = try await contract.getFinishedContestIds()
         
         // 2. For each contest, get details and rankings
         // for contestId in finishedContestIds {
         //     let contestDetails = try await contract.getContestDetails(contestId)
         //     let rankings = try await contract.getContestRankings(contestId)
         //     
         //     // 3. Create leaderboard entries
         //     var entries: [LeaderboardEntry] = []
         //     for (index, teamId) in rankings.teamIds.enumerated() {
         //         let teamInfo = try await contract.getTeamInfo(teamId)
         //         var playerNames: [String] = []
         //         for playerId in teamInfo.playerIds {
         //             let playerInfo = try await contract.getPlayerInfo(playerId)
         //             playerNames.append(playerInfo.name)
         //         }
         //         
         //         entries.append(LeaderboardEntry(
         //             rank: index + 1,
         //             teamId: teamId,
         //             teamOwner: teamInfo.owner,
         //             score: rankings.scores[index],
         //             playerNames: playerNames
         //         ))
         //     }
         //     
         //     // 4. Add to leaderboards array
         //     let leaderboard = ContestLeaderboard(
         //         contestId: contestId,
         //         contestName: contestDetails.name,
         //         sport: String(describing: contestDetails.sport),
         //         entries: entries
         //     )
         //     
         //     DispatchQueue.main.async {
         //         self.leaderboards.append(leaderboard)
         //     }
         // }
         */
    }
}

// Leaderboard view
@available(iOS 26.0, *)
struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    
    var body: some View {
        VStack {
            Text("Leaderboards")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            if viewModel.isLoading {
                ProgressView("Loading leaderboards...")
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundColor(.yellow)
                    Text("Error loading leaderboards")
                        .font(.headline)
                        .padding(.top, 8)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    Button("Retry") {
                        viewModel.fetchLeaderboards()
                    }
                    .buttonStyle(.glassProminent)
                    .padding(.top, 12)
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            } else if viewModel.leaderboards.isEmpty {
                VStack {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("No leaderboards available")
                        .font(.headline)
                        .padding(.top, 8)
                    Text("Leaderboards will appear after contests finish")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(viewModel.leaderboards) { leaderboard in
                            ContestLeaderboardView(leaderboard: leaderboard)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            if viewModel.leaderboards.isEmpty {
                viewModel.fetchLeaderboards()
            }
        }
    }
}

// Individual contest leaderboard view
@available(iOS 26.0, *)
struct ContestLeaderboardView: View {
    let leaderboard: ContestLeaderboard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Contest header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(leaderboard.contestName)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Text(leaderboard.sport)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
                Divider()
            }
            
            // Leaderboard table header
            HStack {
                Text("Rank")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 40)
                Text("Team")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Players")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 120)
                Text("Score")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial)
            .clipShape(Capsule())
            
            // Leaderboard entries
            ForEach(leaderboard.entries) { entry in
                LeaderboardEntryRow(entry: entry)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// Individual leaderboard entry row
@available(iOS 26.0, *)
struct LeaderboardEntryRow: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack {
            // Rank
            Text("\(entry.rank)")
                .font(.system(size: 16, weight: .bold))
                .frame(width: 40)
                .foregroundColor(rankColor(rank: entry.rank))
            
            // Team owner (shortened)
            Text(shortenedAddress(entry.teamOwner))
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Players (first player name)
            Text(entry.playerNames.first ?? "N/A")
                .font(.system(size: 14, weight: .regular))
                .frame(width: 120)
                .foregroundColor(.secondary)
            
            // Score
            Text("\(entry.score)")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 60, alignment: .trailing)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(rankBackground(rank: entry.rank))
        .clipShape(Capsule())
    }
    
    private func rankColor(rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .primary
        }
    }
    
    private func rankBackground(rank: Int) -> Color {
        switch rank {
        case 1: return .yellow.opacity(0.1)
        case 2: return .gray.opacity(0.1)
        case 3: return .orange.opacity(0.1)
        default: return .clear
        }
    }
    
    private func shortenedAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        let start = address.prefix(6)
        let end = address.suffix(4)
        return "\(start)...\(end)"
    }
}

// Preview
@available(iOS 26.0, *)
struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
            .preferredColorScheme(.dark)
    }
}