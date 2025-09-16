
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter a number")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("e.g., 42", text: $numberText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .submitLabel(.search)
                            .onSubmit {
                                guard let number = Int(numberText), !numberText.isEmpty else { return }
                                Task {
                                    await viewModel.getFact(number: number)
                                    numberText = "" // Clear text field after successful call
                                }
                            }
                    }
                    .padding(.horizontal)
                    
                    // Buttons row
                    HStack(spacing: 16) {
                        Button("Get Fact") {
                            guard let number = Int(numberText), !numberText.isEmpty else { return }
                            Task {
                                await viewModel.getFact(number: number)
                                numberText = "" // Clear text field after successful call
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isLoading || numberText.isEmpty)
                        
                        Button("Random Fact") {
                            Task {
                                await viewModel.getRandomFact()
                                numberText = "" // Clear text field after successful call
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal)
                    
                    // Loading indicator
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.vertical)
                .background(Color(.systemGroupedBackground))
                
                // History section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("History")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        if !viewModel.history.isEmpty {
                            Button("Clear") {
                                Task {
                                    await viewModel.clearHistory()
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    
                    if viewModel.history.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No facts yet")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Text("Search for a number or get a random fact to get started!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                    } else {
                        List(viewModel.history) { fact in
                            NavigationLink(destination: DetailView(fact: fact)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("\(fact.number)")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(fact.createdAt, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
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
                }
            }
            .navigationTitle("Number Facts")
            .onAppear {
                Task {
                    await viewModel.onAppear()
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {
                    viewModel.clearError()
                }
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
