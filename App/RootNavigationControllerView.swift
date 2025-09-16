import SwiftUI

struct RootNavigationControllerView: View {
    var body: some View {
        let api: NumbersAPIClient = NumbersAPIService()
        let repo: NumberFactRepository = CoreDataFactRepository(context: PersistenceController.shared.viewContext)
        let viewModel = MainViewModel(api: api, repo: repo)
        
        return MainView(viewModel: viewModel)
    }
}
