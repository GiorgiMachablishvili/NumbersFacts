import SwiftUI

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @State private var numberText = ""
    @State private var showingError = false
    
    init(viewModel: MainViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top controls section
                VStack(spacing: 16) {
                    // Number input field
                    TextField("Enter number", text: $numberText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .padding(.horizontal)
                    
                    // Buttons row
                    HStack(spacing: 16) {
                        Button("Get fact") {
                            guard let number = Int(numberText) else { return }
                            Task {
                                await viewModel.getFact(number: number)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isLoading)
                        
                        Button("Get random fact") {
                            Task {
                                await viewModel.getRandomFact()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal)
                    
                    // Loading indicator
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                    }
                }
                .padding(.vertical)
                .background(Color(.systemGroupedBackground))
                
                // History section
                List(viewModel.history) { fact in
                    NavigationLink(destination: DetailView(fact: fact)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(fact.number)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(fact.text)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Number Facts")
            .onAppear {
                Task {
                    await viewModel.onAppear()
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onChange(of: viewModel.errorMessage) { errorMessage in
                showingError = errorMessage != nil
            }
        }
    }
}

#Preview {
    let api = NumbersAPIService()
    let repo = InMemoryFactRepository()
    let viewModel = MainViewModel(api: api, repo: repo)
    return MainView(viewModel: viewModel)
}
