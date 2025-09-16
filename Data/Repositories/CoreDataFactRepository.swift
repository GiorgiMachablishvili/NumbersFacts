
import Foundation
import CoreData

final class CoreDataFactRepository: NumberFactRepository {
    private let context: NSManagedObjectContext
    private let maxStoredFacts = AppConstants.Storage.maxStoredFacts

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func save(_ fact: NumberFact) async {
        await context.perform {
            // Check for duplicates to avoid storing the same fact multiple times
            let existingRequest = NSFetchRequest<NSManagedObject>(entityName: "NumberFactEntity")
            existingRequest.predicate = NSPredicate(format: "number == %lld AND text == %@", Int64(fact.number), fact.text)
            existingRequest.fetchLimit = 1
            
            if let existing = try? self.context.fetch(existingRequest).first {
                // Update existing fact's timestamp to move it to the top
                existing.setValue(Date(), forKey: "createdAt")
            } else {
                // Create new fact
                let entity = NSEntityDescription.insertNewObject(forEntityName: "NumberFactEntity", into: self.context)
                entity.setValue(fact.id, forKey: "id")
                entity.setValue(Int64(fact.number), forKey: "number")
                entity.setValue(fact.text, forKey: "text")
                entity.setValue(fact.createdAt, forKey: "createdAt")
            }
            
            // Enforce storage limit by removing oldest facts
            self.enforceStorageLimit()
            
            do {
                try self.context.save()
            } catch {
                print("CoreData save error: \(error)")
            }
        }
    }

    func recent(limit: Int) async -> [NumberFact] {
        await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "NumberFactEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            request.fetchLimit = max(1, min(limit, AppConstants.Storage.maxStoredFacts))
            
            do {
                let entities = try self.context.fetch(request)
                return entities.compactMap { entity in
                    guard let id = entity.value(forKey: "id") as? UUID,
                          let text = entity.value(forKey: "text") as? String,
                          let createdAt = entity.value(forKey: "createdAt") as? Date else { 
                        return nil 
                    }
                    let number = Int((entity.value(forKey: "number") as? Int64) ?? 0)
                    return NumberFact(id: id, number: number, text: text, createdAt: createdAt)
                }
            } catch {
                print("CoreData fetch error: \(error)")
                return []
            }
        }
    }
    
    func clear() async {
        await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "NumberFactEntity")
            do {
                let allFacts = try self.context.fetch(request)
                allFacts.forEach { self.context.delete($0) }
                try self.context.save()
            } catch {
                print("CoreData clear error: \(error)")
            }
        }
    }
    
    private func enforceStorageLimit() {
        let allFactsRequest = NSFetchRequest<NSManagedObject>(entityName: "NumberFactEntity")
        allFactsRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let allFacts = try context.fetch(allFactsRequest)
            if allFacts.count > maxStoredFacts {
                let factsToDelete = Array(allFacts.dropFirst(maxStoredFacts))
                factsToDelete.forEach { context.delete($0) }
            }
        } catch {
            print("Error enforcing storage limit: \(error)")
        }
    }
}
