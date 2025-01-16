import SwiftUI
import SwiftData

struct AddEditTrainingSessionView: View {
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var scheduleViewModel: TrainingSessionViewModel
    let students: [Student]
    let existingSession: TrainingSession?
    
    @State private var selectedStudent: Student?
    @State private var courtLocation: String = ""
    @State private var courtNumber: String = ""
    @State private var startTime: String = ""
    @State private var endTime: String = ""
    @State private var isMessaged: Bool = false
    @State private var isBooked: Bool = false
    
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
                    TextField("Start Time (e.g. 14:00)", text: $startTime)
                    TextField("End Time (e.g. 15:30)", text: $endTime)
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
                    Button(action: {
                        guard let selectedStudent = selectedStudent else {
                            return
                        }
                        
                        scheduleViewModel.saveOrUpdateSession(
                            existingSession: existingSession,
                            student: selectedStudent,
                            courtLocation: courtLocation,
                            courtNumber: courtNumber,
                            startTime: startTime,
                            endTime: endTime,
                            isMessaged: isMessaged,
                            isBooked: isBooked,
                            in: modelContext
                        )
                        
                        onDismiss?()
                    }) {
                        Text("Save")
                    }
                }
            }
            .onAppear {
                if let session = existingSession {
                    selectedStudent = session.student
                    courtLocation = session.courtLocation
                    courtNumber = String(session.courtNumber)
                    startTime = session.startTime
                    endTime = session.endTime
                    isMessaged = session.isMessaged
                    isBooked = session.isBooked
                }
            }
        }
    }
}
