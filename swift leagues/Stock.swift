import SwiftUI

struct Stock: Identifiable, Codable, Equatable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let changesPercentage: Double

    enum CodingKeys: String, CodingKey {
        case symbol, name, price, changesPercentage
    }

    var formattedPrice: String {
        String(format: "$%.2f", price)
    }

    var formattedChange: String {
        String(format: "%@%.2f%%", changesPercentage >= 0 ? "+" : "", changesPercentage)
    }

    var changeColor: Color {
        changesPercentage >= 0 ? .green : .red
    }
}
