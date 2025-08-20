import SwiftUI

@available(iOS 26.0, *)
struct ContestSelectionView: View {
    @ObservedObject var viewModel: AssetViewModel
    @Binding var showTeamPopup: Bool // To dismiss the parent sheet
    @Environment(\.dismiss) private var dismiss // To dismiss itself

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Select a Contest")
                    .font(.system(size: 28, weight: .bold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
            }

            ScrollView {
                VStack(spacing: 15) {
                    ForEach(viewModel.activeContests.filter { $0.state == "Active" || $0.state == "Upcoming" }) { contest in
                        Button(action: {
                            viewModel.submitTeam(to: contest)
                            viewModel.markTeamAsSubmitted()
                            showTeamPopup = false // Dismiss parent
                            dismiss() // Dismiss self
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(contest.name)
                                        .font(.headline)
                                    Text("Prize Pool: \(formattedUSD(contest.prizePool))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(30)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
    
    private func formattedUSD(_ amount: Double) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "USD"
        nf.maximumFractionDigits = 2
        return nf.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}