
import Foundation

struct NumbersJSON: Decodable {
    let text: String
    let number: Int
    let found: Bool
    let type: String
}

final class NumbersAPIService: NumbersAPIClient {
    private let session: URLSession

    init(session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AppConstants.API.timeoutInterval
        configuration.timeoutIntervalForResource = AppConstants.API.resourceTimeoutInterval
        return URLSession(configuration: configuration)
    }()) {
        self.session = session
    }

    func fact(for number: Int) async throws -> NumberFact {
        try await fetchJSON(urlString: "\(AppConstants.API.baseURL)/\(number)?json")
    }

    func randomMathFact() async throws -> NumberFact {
        try await fetchJSON(urlString: "\(AppConstants.API.baseURL)/random/math?json")
    }

    private func fetchJSON(urlString: String) async throws -> NumberFact {
        guard let url = URL(string: urlString) else {
            throw NumbersAPIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NumbersAPIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NumbersAPIError.requestFailed(status: httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(NumbersJSON.self, from: data)

        guard decoded.found else {
            throw NumbersAPIError.emptyResponse
        }
        
        return NumberFact(number: decoded.number, text: decoded.text)
    }
}
