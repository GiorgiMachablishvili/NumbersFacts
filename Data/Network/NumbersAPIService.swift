import Foundation

final class NumbersAPIService: NumbersAPIClient {
    private let session = URLSession.shared

    func fact(for number: Int) async throws -> NumberFact {
        guard let url = URL(string: "http://numbersapi.com/\(number)") else { throw NumbersAPIError.invalidURL }
        let (data, resp) = try await session.data(from: url)
        guard let http = resp as? HTTPURLResponse else { throw NumbersAPIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw NumbersAPIError.requestFailed(status: http.statusCode) }
        guard let text = String(data: data, encoding: .utf8), !text.isEmpty else { throw NumbersAPIError.emptyResponse }
        return NumberFact(number: number, text: text)
    }

    func randomMathFact() async throws -> NumberFact {
        guard let url = URL(string: "http://numbersapi.com/random/math") else { throw NumbersAPIError.invalidURL }
        let (data, resp) = try await session.data(from: url)
        guard let http = resp as? HTTPURLResponse else { throw NumbersAPIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw NumbersAPIError.requestFailed(status: http.statusCode) }
        guard let text = String(data: data, encoding: .utf8), !text.isEmpty else { throw NumbersAPIError.emptyResponse }
        let number = try firstInteger(in: text)
        return NumberFact(number: number, text: text)
    }

    private func firstInteger(in s: String) throws -> Int {
        let rx = try NSRegularExpression(pattern: #"\d+"#)
        let range = NSRange(s.startIndex..<s.endIndex, in: s)
        guard let m = rx.firstMatch(in: s, range: range),
              let r = Range(m.range, in: s), let n = Int(s[r]) else { throw NumbersAPIError.invalidResponse }
        return n
    }
}
