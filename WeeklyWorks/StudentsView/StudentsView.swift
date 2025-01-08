import SwiftUI
import SwiftData

struct StudentsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = StudentViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.students) { student in
                    StudentRowView(student: student)
                }
                .onDelete { indexSet in
                    indexSet.map { viewModel.students[$0] }.forEach { student in
                        viewModel.deleteStudent(student, from: modelContext)
                    }
                }
            }
            .navigationTitle("Students")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        viewModel.addStudent(name: "New Student", isMale: Bool.random(), to: modelContext)
                    }
                }
            }
            .onAppear {
                viewModel.fetchStudents(from: modelContext)
            }
        }
    }
}


struct StudentRowView: View {
    let student: Student

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundColor(student.isMale ? .blue : .pink)
            Text(student.name)
                .font(.headline)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let schema = Schema([Student.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

    do {
        let mockContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

        // Insert Mock Data
        let context = mockContainer.mainContext
        context.insert(Student(name: "Alice", isMale: true))
        context.insert(Student(name: "Dennis", isMale: true))
        context.insert(Student(name: "Vinny", isMale: false))

        return StudentsView()
            .modelContainer(mockContainer)
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
