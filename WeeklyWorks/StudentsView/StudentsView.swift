import SwiftUI
import SwiftData

struct StudentsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = StudentViewModel()
    
    @State private var showAddEditSheet = false
    @State private var studentToEdit: Student?

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.students) { student in
                    StudentRowView(student: student)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            studentToEdit = student
                            showAddEditSheet = true
                        }
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
                        studentToEdit = nil
                        showAddEditSheet = true
                    }
                }
            }
            .onAppear {
                viewModel.fetchStudents(from: modelContext)
            }
            .sheet(isPresented: $showAddEditSheet) {
                AddEditStudentView(
                    studentViewModel: viewModel,
                    existingStudent: studentToEdit
                ) {
                    showAddEditSheet = false
                }
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
            VStack(alignment: .leading) {
                Text(student.name)
                    .font(.headline)
                Text(student.contactMode == .whatsapp ? "WhatsApp: \(student.contact)" : "Instagram: \(student.contact)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
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
        context.insert(Student(name: "Alice", isMale: false, contactMode: .instagram, contact: "@alice"))
        context.insert(Student(name: "Dennis", isMale: true, contactMode: .instagram, contact: "@dennis"))
        context.insert(Student(name: "Vinny", isMale: false, contactMode: .whatsapp, contact: "+61420212391"))

        return StudentsView()
            .modelContainer(mockContainer)
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
