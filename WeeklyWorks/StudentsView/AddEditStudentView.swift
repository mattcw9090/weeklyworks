import SwiftUI
import SwiftData

struct AddEditStudentView: View {
    @Environment(\.modelContext) private var modelContext
    
    /// The view model in charge of students
    @ObservedObject var studentViewModel: StudentViewModel
    
    /// If non-nil, we are editing an existing student
    let existingStudent: Student?
    
    // Form fields
    @State private var name: String = ""
    @State private var isMale: Bool = true
    
    // Callback to dismiss the view
    var onDismiss: (() -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Student Details") {
                    TextField("Name", text: $name)
                    Toggle("Is Male?", isOn: $isMale)
                }
            }
            .navigationTitle(existingStudent == nil ? "Add Student" : "Edit Student")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss?()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        studentViewModel.saveOrUpdateStudent(
                            existingStudent: existingStudent,
                            name: name,
                            isMale: isMale,
                            in: modelContext
                        )
                        onDismiss?()
                    }
                }
            }
            .onAppear {
                if let student = existingStudent {
                    name = student.name
                    isMale = student.isMale
                }
            }
        }
    }
}
