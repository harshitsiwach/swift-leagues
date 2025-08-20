import SwiftUI

@available(iOS 26.0, *)
struct CoinSelection: Identifiable, Equatable {
    let coin: Coin
    var prediction: Prediction?

    var id: String { coin.id }

    enum Prediction {
        case up, down
    }

    static func == (lhs: CoinSelection, rhs: CoinSelection) -> Bool {
        lhs.coin.id == rhs.coin.id && lhs.prediction == rhs.prediction
    }
}
