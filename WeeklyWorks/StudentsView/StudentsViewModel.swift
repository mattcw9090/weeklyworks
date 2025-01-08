import Foundation
import SwiftData

class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []

    func fetchStudents(from modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Student>()
        do {
            students = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Error fetching students: \(error)")
        }
    }

    func addStudent(name: String, isMale: Bool, to modelContext: ModelContext) {
        let newStudent = Student(name: name, isMale: isMale)
        modelContext.insert(newStudent)
        saveChanges(in: modelContext)
        fetchStudents(from: modelContext)
    }

    func deleteStudent(_ student: Student, from modelContext: ModelContext) {
        modelContext.delete(student)
        saveChanges(in: modelContext)
        fetchStudents(from: modelContext)
    }

    private func saveChanges(in modelContext: ModelContext) {
        do {
            try modelContext.save()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}
