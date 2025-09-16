import UIKit
import SwiftUI

final class MainViewController: UIViewController {
    private let vm: MainViewModel
    private var hostingController: UIHostingController<MainView>!
    
    init(viewModel: MainViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "Number Facts"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        // Create SwiftUI view with the same functionality
        let mainView = MainView(viewModel: vm)
        
        // Wrap in UIHostingController
        hostingController = UIHostingController(rootView: mainView)
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
