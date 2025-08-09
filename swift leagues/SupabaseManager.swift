import Foundation
import Supabase

// MARK: - Data Structures for Supabase
nonisolated struct Team: Codable, Sendable {
    let id: UUID
    let wallet_address: String
    let team_name: String?
}

nonisolated struct TeamInsert: Encodable, Sendable {
    let wallet_address: String
    let team_name: String
}

nonisolated struct TeamTokenInsert: Encodable, Sendable {
    let team_id: UUID
    let token_symbol: String
    let token_name: String
    let token_price: Double
    let logo_url: String
    let position: Int
}


// MARK: - Supabase Manager
class SupabaseManager {
    static let shared = SupabaseManager()

    private let supabase: SupabaseClient

    private init() {
        guard let supabaseURLString = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let supabaseURL = URL(string: supabaseURLString),
              let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] else {
            fatalError("Supabase URL or Key not found. Please check your Xcode Scheme's Environment Variables.")
        }
        supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }

    func saveTeam(team: [Coin], walletAddress: String) async throws {
        // 1. Prepare the team data for insertion using the Encodable struct
        let teamToInsert = TeamInsert(
            wallet_address: walletAddress,
            team_name: "My Team" // Placeholder
        )

        // 2. Insert the team and decode the returned data into our `Team` struct
        let insertedTeams: [Team] = try await supabase.database
            .from("teams")
            .insert(teamToInsert, returning: .representation)
            .execute()
            .value

        // 3. Get the ID of the newly inserted team
        guard let teamId = insertedTeams.first?.id else {
            throw NSError(domain: "SupabaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get team ID after insertion."])
        }

        // 4. Prepare the token data, now including the position
        let tokensToInsert = team.enumerated().map { (index, coin) in
            TeamTokenInsert(
                team_id: teamId,
                token_symbol: coin.symbol,
                token_name: coin.name,
                token_price: coin.currentPrice,
                logo_url: coin.image,
                position: index
            )
        }

        // 5. Insert the array of tokens
        try await supabase.database
            .from("team_tokens")
            .insert(tokensToInsert)
            .execute()
    }
}
