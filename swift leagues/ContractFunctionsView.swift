import SwiftUI

@available(iOS 26.0, *)
struct ContractFunctionsView: View {
    @State private var functions: [AbiFunction] = []
    @State private var loadError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contract Functions")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal)

            if let loadError {
                Text(loadError)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal)
            }

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(functions, id: \.self) { fn in
                        FunctionRow(function: fn)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        do {
            self.functions = try ABIService.shared.loadAllFunctions()
        } catch {
            self.loadError = "Failed to load ABI: \(error.localizedDescription)"
        }
    }
}

@available(iOS 26.0, *)
private struct FunctionRow: View {
    let function: AbiFunction

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(function.name)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Text(function.stateMutability.uppercased())
                    .font(.caption.bold())
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(stateMutabilityColor(function.stateMutability).opacity(0.2))
                    .foregroundColor(stateMutabilityColor(function.stateMutability))
                    .clipShape(Capsule())
            }

            if !function.inputs.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Inputs:").font(.headline)
                    ForEach(function.inputs, id: \.self) { p in
                        Text("• \(p.name ?? "_"): \(p.type ?? "unknown")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if !function.outputs.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Outputs:").font(.headline)
                    ForEach(function.outputs, id: \.self) { p in
                        Text("• \(p.name ?? "_"): \(p.type ?? "unknown")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
    
    private func stateMutabilityColor(_ state: String) -> Color {
        switch state {
        case "view", "pure":
            return .blue
        case "nonpayable":
            return .orange
        case "payable":
            return .green
        default:
            return .gray
        }
    }
}

@available(iOS 26.0, *)
struct ContractFunctionsView_Previews: PreviewProvider {
    static var previews: some View {
        ContractFunctionsView()
    }
}
