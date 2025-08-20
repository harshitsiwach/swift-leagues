import SwiftUI

struct ContestReadFunctionsView: View {
    @State private var functions: [AbiFunction] = []
    @State private var loadError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contract Read Functions")
                .font(.system(size: 22, weight: .bold))

            if let loadError {
                Text(loadError)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            ScrollView {
                LazyVStack(spacing: 10, pinnedViews: []) {
                    ForEach(functions, id: \.self) { fn in
                        FunctionRow(function: fn)
                    }
                }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        do {
            self.functions = try ABIService.shared.loadReadFunctions()
        } catch {
            self.loadError = "Failed to load ABI: \(error.localizedDescription)"
        }
    }
}

private struct FunctionRow: View {
    let function: AbiFunction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(function.name)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(function.stateMutability.uppercased())
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !function.inputs.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Inputs:").font(.caption).foregroundColor(.secondary)
                    ForEach(function.inputs, id: \.self) { p in
                        Text("- \(p.name ?? "_"): \(p.type ?? "unknown")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if !function.outputs.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Outputs:").font(.caption).foregroundColor(.secondary)
                    ForEach(function.outputs, id: \.self) { p in
                        Text("- \(p.name ?? "_"): \(p.type ?? "unknown")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(12)
        .glassEffect()
    }
}

#Preview {
    ContestReadFunctionsView()
}
