
import Foundation

actor InMemoryFactRepository: NumberFactRepository {
    private var items: [NumberFact] = []
    private let cap = 100

    func save(_ fact: NumberFact) async {
        items.insert(fact, at: 0)
        if items.count > cap { items.removeLast(items.count - cap) }
    }

    func recent(limit: Int) async -> [NumberFact] { Array(items.prefix(limit)) }
    
    func clear() async {
        items.removeAll()
    }
}
