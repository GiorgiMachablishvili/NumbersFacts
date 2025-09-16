import Foundation

struct NumberFact: Identifiable, Equatable {
    let id: UUID
    let number: Int
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), number: Int, text: String, createdAt: Date = Date()) {
        self.id = id
        self.number = number
        self.text = text
        self.createdAt = createdAt
    }
}
