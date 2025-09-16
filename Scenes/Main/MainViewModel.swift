
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
    @Published private(set) var lastSearchNumber: Int?

    init(api: NumbersAPIClient, repo: NumberFactRepository = InMemoryFactRepository()) {
        self.api = api
        self.repo = repo
    }

    func onAppear() async {
        await loadHistory()
    }

    func getRandomFact() async {
        await performAPICall {
            let fact = try await self.api.randomMathFact()
            return fact
        }
    }

    func getFact(number: Int) async {
        lastSearchNumber = number
        await performAPICall {
            let fact = try await self.api.fact(for: number)
            return fact
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func clearHistory() async {
        await repo.clear()
        history = []
    }
    
    // MARK: - Private Methods
    
    private func performAPICall(_ apiCall: @escaping () async throws -> NumberFact) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let fact = try await apiCall()
            currentFact = fact
            await saveFact(fact)
            await loadHistory()
        } catch {
            handleError(error)
        }
    }
    
    private func saveFact(_ fact: NumberFact) async {
        do {
            await repo.save(fact)
        } catch {
            print("Failed to save fact: \(error)")
            // Don't show error to user for save failures, just log it
        }
    }
    
    private func loadHistory() async {
        do {
            history = await repo.recent(limit: AppConstants.Storage.historyLimit)
        } catch {
            print("Failed to load history: \(error)")
            // Don't show error to user for history load failures
        }
    }
    
    private func handleError(_ error: Error) {
        if let numbersError = error as? NumbersAPIError {
            errorMessage = numbersError.errorDescription
        } else if let localizedError = error as? LocalizedError {
            errorMessage = localizedError.errorDescription ?? error.localizedDescription
        } else {
            errorMessage = "An unexpected error occurred. Please try again."
        }
    }
}
