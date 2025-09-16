import Foundation

/// Dependency injection container for managing app dependencies
final class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() {}
    
    // MARK: - Core Dependencies
    
    lazy var persistenceController: PersistenceController = {
        PersistenceController.shared
    }()
    
    lazy var numbersAPIService: NumbersAPIClient = {
        NumbersAPIService()
    }()
    
    lazy var factRepository: NumberFactRepository = {
        CoreDataFactRepository(context: persistenceController.viewContext)
    }()
    
    // MARK: - View Models
    
    @MainActor func makeMainViewModel() -> MainViewModel {
        MainViewModel(api: numbersAPIService, repo: factRepository)
    }
    
    @MainActor func makeDetailViewModel(for fact: NumberFact) -> DetailViewModel {
        DetailViewModel(fact: fact)
    }
    
    // MARK: - Test Dependencies (for previews and testing)
    
    @MainActor func makeTestMainViewModel() -> MainViewModel {
        let testAPI = NumbersAPIService()
        let testRepo = InMemoryFactRepository()
        return MainViewModel(api: testAPI, repo: testRepo)
    }
}
