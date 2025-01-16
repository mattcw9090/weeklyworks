import SwiftUI
import SwiftData

struct AddEditStudentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var studentViewModel: StudentViewModel
    
    let existingStudent: Student?
    
    @State private var name: String = ""
    @State private var isMale: Bool = true
    @State private var contactMode: ContactMode = .whatsapp
    @State private var contact: String = ""
    
    var onDismiss: (() -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Student Details") {
                    TextField("Name", text: $name)
                    Toggle("Is Male?", isOn: $isMale)
                }
                
                Section("Contact Details") {
                    Picker("Contact Mode", selection: $contactMode) {
                        ForEach(ContactMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField(contactMode == .whatsapp
                              ? "WhatsApp Number"
                              : "Instagram Handle",
                              text: $contact)
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
                        guard isValidContact(contactMode: contactMode, contact: contact) else {
                            print("Invalid contact information.")
                            return
                        }

                        studentViewModel.saveOrUpdateStudent(
                            existingStudent: existingStudent,
                            name: name,
                            isMale: isMale,
                            contactMode: contactMode,
                            contact: contact,
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
                    contactMode = student.contactMode
                    contact = student.contact
                }
            }
        }
    }
    
    private func isValidContact(contactMode: ContactMode, contact: String) -> Bool {
        switch contactMode {
        case .whatsapp:
            return contact.starts(with: "+")
        case .instagram:
            return contact.starts(with: "@")
        }
    }
}
