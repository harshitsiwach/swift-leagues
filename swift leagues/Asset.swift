import Foundation

protocol Asset: Identifiable {
    var name: String { get }
    var symbol: String { get }
    var image: String { get }
}

// Stock extension
extension Stock: Asset {
    var image: String {
        return "" // Stocks don't have images in our model
    }
}