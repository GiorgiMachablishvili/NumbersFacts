import Foundation
import CoreData

final class CoreDataFactRepository: NumberFactRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func save(_ fact: NumberFact) async {
        await context.perform {
            let o = NSEntityDescription.insertNewObject(forEntityName: "NumberFactEntity", into: self.context)
            o.setValue(fact.id, forKey: "id")
            o.setValue(Int64(fact.number), forKey: "number")
            o.setValue(fact.text, forKey: "text")
            o.setValue(fact.createdAt, forKey: "createdAt")
            do { try self.context.save() } catch { print("CoreData save error: \(error)") }
        }
    }

    func recent(limit: Int) async -> [NumberFact] {
        await context.perform {
            let req = NSFetchRequest<NSManagedObject>(entityName: "NumberFactEntity")
            req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            req.fetchLimit = max(1, min(limit, 200))
            do {
                let rows = try self.context.fetch(req)
                return rows.compactMap { o in
                    guard let id = o.value(forKey: "id") as? UUID,
                          let text = o.value(forKey: "text") as? String,
                          let createdAt = o.value(forKey: "createdAt") as? Date else { return nil }
                    let num = Int((o.value(forKey: "number") as? Int64) ?? 0)
                    return NumberFact(id: id, number: num, text: text, createdAt: createdAt)
                }
            } catch {
                print("CoreData fetch error: \(error)")
                return []
            }
        }
    }
}
