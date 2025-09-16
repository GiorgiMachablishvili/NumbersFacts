
import Foundation

protocol NumbersAPIClient {
    func fact(for number: Int) async throws -> NumberFact
    func randomMathFact() async throws -> NumberFact
}

enum NumbersAPIError: Error, LocalizedError {
    case invalidURL, requestFailed(status: Int), emptyResponse, invalidResponse
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .requestFailed(let s): return "Request failed with status \(s)."
        case .emptyResponse: return "Empty response."
        case .invalidResponse: return "Invalid response."
        }
    }
}
