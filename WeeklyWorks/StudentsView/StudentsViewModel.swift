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
    
    func fetchStudent(byName name: String, from modelContext: ModelContext) -> Student? {
        let fetchDescriptor = FetchDescriptor<Student>(predicate: #Predicate { $0.name == name })
        do {
            let fetchedStudents = try modelContext.fetch(fetchDescriptor)
            return fetchedStudents.first
        } catch {
            print("Error fetching student by name: \(error)")
            return nil
        }
    }
    
    private func saveChanges(in modelContext: ModelContext) {
        do {
            try modelContext.save()
        } catch {
            print("Error saving changes: \(error)")
        }
    }

}
