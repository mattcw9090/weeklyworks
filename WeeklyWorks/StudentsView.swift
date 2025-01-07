import SwiftUI

struct StudentsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("This is the Students View")
                    .font(.title)
                    .padding()

                NavigationLink(destination: StudentDetailView()) {
                    Text("Go to Student Details")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Students")
        }
    }
}

struct StudentDetailView: View {
    var body: some View {
        Text("This is the Student Detail View")
            .font(.title2)
            .padding()
    }
}

#Preview {
    StudentsView()
}
