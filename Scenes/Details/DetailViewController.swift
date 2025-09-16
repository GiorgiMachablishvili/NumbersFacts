import UIKit
import SwiftUI

final class DetailViewController: UIViewController {
    private let vm: DetailViewModel
    private var hostingController: UIHostingController<DetailView>!

    init(viewModel: DetailViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "Fact Detail"
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
        let detailView = DetailView(fact: vm.fact)
        
        // Wrap in UIHostingController
        hostingController = UIHostingController(rootView: detailView)
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

    }
}
