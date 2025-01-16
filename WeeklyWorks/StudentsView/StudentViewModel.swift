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

    func addStudent(name: String, isMale: Bool, contactMode: ContactMode, contact: String, to modelContext: ModelContext) {
        let newStudent = Student(name: name, isMale: isMale, contactMode: contactMode, contact: contact)
        modelContext.insert(newStudent)
        saveChanges(in: modelContext)
        fetchStudents(from: modelContext)
    }

    func deleteStudent(_ student: Student, from modelContext: ModelContext) {
        modelContext.delete(student)
        saveChanges(in: modelContext)
        fetchStudents(from: modelContext)
    }
    
    func updateStudent(_ student: Student, in modelContext: ModelContext) {
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
    
    // MARK: - Single entry point for creation or update
    func saveOrUpdateStudent(
        existingStudent: Student?,
        name: String,
        isMale: Bool,
        contactMode: ContactMode,
        contact: String,
        in modelContext: ModelContext
    ) {
        if let editingStudent = existingStudent {
            // Update the existing student
            editingStudent.name = name
            editingStudent.isMale = isMale
            editingStudent.contactMode = contactMode
            editingStudent.contact = contact
            updateStudent(editingStudent, in: modelContext)
        } else {
            // Create a new student
            addStudent(name: name, isMale: isMale, contactMode: contactMode, contact: contact, to: modelContext)
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
