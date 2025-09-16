
import Foundation

protocol NumberFactRepository {
    func save(_ fact: NumberFact) async
    func recent(limit: Int) async -> [NumberFact]
    func clear() async
}
