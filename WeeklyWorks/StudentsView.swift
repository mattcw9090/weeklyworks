import SwiftUI

// Model for a student
struct Student: Identifiable {
    let id = UUID()
    let name: String
    let isMale: Bool
}

// Hardcoded list of students
let students = [
    Student(name: "Alice Johnson", isMale: false),
    Student(name: "Bob Smith", isMale: true),
    Student(name: "Charlie Brown", isMale: true),
    Student(name: "Diana Prince", isMale: false)
]

struct StudentView: View {
    var body: some View {
        NavigationView {
            List(students) { student in
                StudentRowView(student: student)
            }
            .navigationTitle("Students")
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
    StudentView()
}
