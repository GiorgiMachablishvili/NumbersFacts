
import SwiftUI

struct RootNavigationControllerView: View {
    @StateObject private var viewModel: MainViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: DependencyContainer.shared.makeMainViewModel())
    }
    
    var body: some View {
        MainView(viewModel: viewModel)
    }
}
