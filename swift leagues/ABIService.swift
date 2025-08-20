import Foundation

struct AbiParameter: Decodable, Hashable {
    let internalType: String?
    let name: String?
    let type: String?
}

struct AbiEntry: Decodable {
    let type: String?
    let name: String?
    let stateMutability: String?
    let inputs: [AbiParameter]?
    let outputs: [AbiParameter]?
}

struct AbiFunction: Hashable {
    let name: String
    let stateMutability: String
    let inputs: [AbiParameter]
    let outputs: [AbiParameter]
}

enum ABIServiceError: Error {
    case abiFileNotFound
}

final class ABIService {
    static let shared = ABIService()
    private init() {}

    func loadReadFunctions() throws -> [AbiFunction] {
        guard let url = Bundle.main.url(forResource: "ContractABI", withExtension: "json") else {
            throw ABIServiceError.abiFileNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let entries = try decoder.decode([AbiEntry].self, from: data)
        let readFunctions = entries.compactMap { entry -> AbiFunction? in
            guard entry.type == "function",
                  let name = entry.name,
                  let state = entry.stateMutability,
                  state == "view" || state == "pure" else { return nil }
            return AbiFunction(
                name: name,
                stateMutability: state,
                inputs: entry.inputs ?? [],
                outputs: entry.outputs ?? []
            )
        }
        return readFunctions.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func loadAllFunctions() throws -> [AbiFunction] {
        guard let url = Bundle.main.url(forResource: "ContractABI", withExtension: "json") else {
            throw ABIServiceError.abiFileNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let entries = try decoder.decode([AbiEntry].self, from: data)
        let allFunctions = entries.compactMap { entry -> AbiFunction? in
            guard entry.type == "function",
                  let name = entry.name,
                  let state = entry.stateMutability else { return nil }
            return AbiFunction(
                name: name,
                stateMutability: state,
                inputs: entry.inputs ?? [],
                outputs: entry.outputs ?? []
            )
        }
        return allFunctions.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
