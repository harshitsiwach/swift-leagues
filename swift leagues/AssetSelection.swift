import Foundation

struct AssetSelection: Identifiable, Equatable {
    let asset: any Asset
    var prediction: Prediction?

    var id: String {
        // Convert the asset's ID to a string representation
        return "\(asset.id)"
    }

    enum Prediction {
        case up, down
    }

    static func == (lhs: AssetSelection, rhs: AssetSelection) -> Bool {
        // Compare based on the string representation of the IDs
        return lhs.id == rhs.id && lhs.prediction == rhs.prediction
    }
}