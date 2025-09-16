import Foundation
import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {
    private let api: NumbersAPIClient
    private let repo: NumberFactRepository

    @Published private(set) var currentFact: NumberFact?
    @Published private(set) var history: [NumberFact] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    init(api: NumbersAPIClient, repo: NumberFactRepository = InMemoryFactRepository()) {
        self.api = api
        self.repo = repo
    }

    func onAppear() async {
        history = await repo.recent(limit: 50)
    }

    func getRandomFact() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let fact = try await api.randomMathFact()
            currentFact = fact
            await repo.save(fact)
            history = await repo.recent(limit: 50)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func getFact(number: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let fact = try await api.fact(for: number)
            currentFact = fact
            await repo.save(fact)
            history = await repo.recent(limit: 50)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
