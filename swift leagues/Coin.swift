import SwiftUI

struct Coin: Asset, Codable, Equatable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let priceChangePercentage24h: Double

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case priceChangePercentage24h = "price_change_percentage_24h"
    }

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