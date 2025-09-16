import Foundation

@MainActor
final class DetailViewModel {
    let fact: NumberFact
    
    init(fact: NumberFact) {
        self.fact = fact
    }
}
