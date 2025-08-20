import SwiftUI
import Combine
import Foundation

// MARK: - Data Models
struct TeamInfo {
    let id: UInt64
    let owner: String
    let contestId: UInt64
    let playerIds: [String]
    let captain: String
    let viceCaptain: String
    let score: UInt64
    let hasClaimedPrize: Bool
    let submissionTime: UInt64
    let contestName: String
    let contestSport: String
    let playerDetails: [PlayerInfo]
}

struct PlayerInfo: Identifiable {
    let id: String
    let name: String
    let sport: String
    let isActive: Bool
}

// MARK: - View Model
@available(iOS 26.0, *)
class MyTeamViewModel: ObservableObject {
    @Published var teams: [TeamInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // This would be implemented with actual Web3 calls
    func fetchUserTeams() {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Mock data for demonstration
            let mockPlayers = [
                PlayerInfo(id: "player1", name: "Lionel Messi", sport: "Football", isActive: true),
                PlayerInfo(id: "player2", name: "Cristiano Ronaldo", sport: "Football", isActive: true),
                PlayerInfo(id: "player3", name: "Neymar Jr.", sport: "Football", isActive: true),
                PlayerInfo(id: "player4", name: "Kylian Mbappé", sport: "Football", isActive: true),
                PlayerInfo(id: "player5", name: "Robert Lewandowski", sport: "Football", isActive: true)
            ]
            
            let mockTeam = TeamInfo(
                id: 1001,
                owner: "0x742d35Cc6634C0532925a3b844Bc454e4438f44e",
                contestId: 1,
                playerIds: ["player1", "player2", "player3", "player4", "player5"],
                captain: "player1",
                viceCaptain: "player2",
                score: 9500,
                hasClaimedPrize: false,
                submissionTime: 1640995200,
                contestName: "Premier League Challenge",
                contestSport: "Football",
                playerDetails: mockPlayers
            )
            
            self.teams = [mockTeam]
            self.isLoading = false
        }
        
        /*
         // Actual implementation would look like this:
         
         // 1. Get user's teams
         // let userTeamIds = try await contract.getUserTeams(userAddress)
         
         // 2. For each team, get details
         // for teamId in userTeamIds {
         //     let teamData = try await contract.getTeamInfo(teamId)
         //     let contestData = try await contract.getContestDetails(teamData.contestId)
         //     
         //     // 3. Get player details
         //     var playerDetails: [PlayerInfo] = []
         //     for playerId in teamData.playerIds {
         //         let playerData = try await contract.getPlayerInfo(playerId)
         //         playerDetails.append(PlayerInfo(
         //             id: playerId,
         //             name: playerData.name,
         //             sport: String(describing: playerData.sport),
         //             isActive: playerData.isActive
         //         ))
         //     }
         //     
         //     // 4. Create TeamInfo object
         //     let teamInfo = TeamInfo(
         //         id: teamId,
         //         owner: teamData.owner,
         //         contestId: teamData.contestId,
         //         playerIds: teamData.playerIds,
         //         captain: teamData.captain,
         //         viceCaptain: teamData.viceCaptain,
         //         score: teamData.score,
         //         hasClaimedPrize: teamData.hasClaimedPrize,
         //         submissionTime: teamData.submissionTime,
         //         contestName: contestData.name,
         //         contestSport: String(describing: contestData.sport),
         //         playerDetails: playerDetails
         //     )
         //     
         //     DispatchQueue.main.async {
         //         self.teams.append(teamInfo)
         //     }
         // }
         */
    }
    
    func claimPrize(for team: TeamInfo) {
        // This would call the claimPrize function on the smart contract
        print("Claiming prize for team \(team.id) in contest \(team.contestId)")
    }
    
    func submitTeam(contestId: UInt64, playerIds: [String], captain: String, viceCaptain: String) {
        // This would call the submitTeam function on the smart contract
        print("Submitting team for contest \(contestId)")
    }
}

// MARK: - Main View
@available(iOS 26.0, *)
struct MyTeamView: View {
    @StateObject private var viewModel = MyTeamViewModel()
    
    var body: some View {
        VStack {
            Text("My Teams")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            if viewModel.isLoading {
                ProgressView("Loading your teams...")
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundColor(.yellow)
                    Text("Error loading teams")
                        .font(.headline)
                        .padding(.top, 8)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    Button("Retry") {
                        viewModel.fetchUserTeams()
                    }
                    .buttonStyle(.glassProminent)
                    .padding(.top, 12)
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            } else if viewModel.teams.isEmpty {
                VStack {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("No teams yet")
                        .font(.headline)
                        .padding(.top, 8)
                    Text("Create your first team to participate in contests")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                    Button("Create Team") {
                        // Navigate to team creation
                    }
                    .buttonStyle(.glassProminent)
                    .padding(.top, 12)
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(viewModel.teams, id: \.id) { team in
                            TeamCardView(team: team, viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            if viewModel.teams.isEmpty {
                viewModel.fetchUserTeams()
            }
        }
    }
}

// MARK: - Team Card View
@available(iOS 26.0, *)
struct TeamCardView: View {
    let team: TeamInfo
    @ObservedObject var viewModel: MyTeamViewModel
    @State private var showingTeamDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Team header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(team.contestName)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Text(team.contestSport)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
                
                HStack {
                    Text("Team ID: \(team.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Score: \(team.score)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            
            // Players grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(team.playerDetails) { player in
                    PlayerCardView(player: player, isCaptain: player.id == team.captain, isViceCaptain: player.id == team.viceCaptain)
                }
            }
            
            // Action buttons
            HStack {
                Button(action: {
                    showingTeamDetails = true
                }) {
                    Text("View Details")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                
                if !team.hasClaimedPrize && team.score > 0 {
                    Button(action: {
                        viewModel.claimPrize(for: team)
                    }) {
                        Text("Claim Prize")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.green)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .sheet(isPresented: $showingTeamDetails) {
            TeamDetailsView(team: team)
        }
    }
}

// MARK: - Player Card View
@available(iOS 26.0, *)
struct PlayerCardView: View {
    let player: PlayerInfo
    let isCaptain: Bool
    let isViceCaptain: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Text(player.name)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if isCaptain || isViceCaptain {
                Text(isCaptain ? "C" : "VC")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isCaptain ? Color.blue : Color.orange)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Team Details View
@available(iOS 26.0, *)
struct TeamDetailsView: View {
    let team: TeamInfo
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Team info section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team Information")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        DetailRow(title: "Team ID", value: String(team.id))
                        DetailRow(title: "Contest", value: team.contestName)
                        DetailRow(title: "Sport", value: team.contestSport)
                        DetailRow(title: "Score", value: String(team.score))
                        DetailRow(title: "Submitted", value: formattedDate(team.submissionTime))
                        DetailRow(title: "Prize Claimed", value: team.hasClaimedPrize ? "Yes" : "No")
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    // Players section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Players")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(team.playerDetails) { player in
                            PlayerDetailView(
                                player: player,
                                isCaptain: player.id == team.captain,
                                isViceCaptain: player.id == team.viceCaptain
                            )
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding()
            }
            .navigationTitle("Team Details")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ timestamp: UInt64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row
@available(iOS 26.0, *)
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Player Detail View
@available(iOS 26.0, *)
struct PlayerDetailView: View {
    let player: PlayerInfo
    let isCaptain: Bool
    let isViceCaptain: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.system(size: 16, weight: .medium))
                
                Text(player.id)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isCaptain || isViceCaptain {
                Text(isCaptain ? "Captain" : "Vice Captain")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isCaptain ? Color.blue : Color.orange)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
@available(iOS 26.0, *)
struct MyTeamView_Previews: PreviewProvider {
    static var previews: some View {
        MyTeamView()
            .preferredColorScheme(.dark)
    }
}