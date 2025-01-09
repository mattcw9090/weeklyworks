import SwiftUI
import SwiftData

struct AddEditTrainingSessionView: View {
    @Environment(\.modelContext) private var modelContext
    
    /// The view model in charge of training sessions
    @ObservedObject var scheduleViewModel: TrainingSessionsViewModel
    
    /// The students list so we can populate a dropdown
    let students: [Student]
    
    /// If non-nil, we are editing an existing session
    let existingSession: TrainingSession?
    
    // Form fields
    @State private var selectedStudent: Student?
    @State private var courtLocation: String = ""
    @State private var courtNumber: String = ""
    @State private var time: String = ""
    @State private var isMessaged: Bool = false
    @State private var isBooked: Bool = false
    
    // Callback to dismiss the view
    var onDismiss: (() -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Student") {
                    Picker("Select Student", selection: $selectedStudent) {
                        ForEach(students, id: \.id) { student in
                            Text(student.name).tag(student as Student?)
                        }
                    }
                }
                Section("Court Details") {
                    TextField("Court Location", text: $courtLocation)
                    TextField("Court Number", text: $courtNumber)
                        .keyboardType(.numberPad)
                }
                Section("Time") {
                    TextField("Time (e.g. 14:00)", text: $time)
                }
                Section("Status Flags") {
                    Toggle("Is Messaged?", isOn: $isMessaged)
                    Toggle("Is Booked?", isOn: $isBooked)
                }
            }
            .navigationTitle(existingSession == nil ? "Add Training" : "Edit Training")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss?()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard let selectedStudent = selectedStudent else {
                            // handle no selection gracefully
                            return
                        }
                        scheduleViewModel.saveOrUpdateSession(
                            existingSession: existingSession,
                            student: selectedStudent,
                            courtLocation: courtLocation,
                            courtNumber: courtNumber,
                            time: time,
                            isMessaged: isMessaged,
                            isBooked: isBooked,
                            in: modelContext
                        )
                        onDismiss?()
                    }
                }
            }
            .onAppear {
                if let session = existingSession {
                    selectedStudent = session.student
                    courtLocation = session.courtLocation
                    courtNumber = String(session.courtNumber)
                    time = session.time
                    isMessaged = session.isMessaged
                    isBooked = session.isBooked
                }
            }
        }
    }
}
