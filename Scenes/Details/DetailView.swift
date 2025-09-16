
import SwiftUI

struct DetailView: View {
    let fact: NumberFact
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Number header
                Text("Number: \(fact.number)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Fact text
                Text(fact.text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Fact Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let sampleFact = NumberFact(
        number: 42,
        text: "42 is the answer to the ultimate question of life, the universe, and everything according to Douglas Adams' 'The Hitchhiker's Guide to the Galaxy'."
    )
    return NavigationView {
        DetailView(fact: sampleFact)
    }
}
