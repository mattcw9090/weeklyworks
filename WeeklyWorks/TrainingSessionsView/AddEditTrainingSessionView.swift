import SwiftUI
import SwiftData

struct AddEditTrainingSessionView: View {
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var scheduleViewModel: TrainingSessionViewModel
    let students: [Student]
    let existingSession: TrainingSession?
    
    @State private var selectedStudent: Student?
    @State private var selectedCourtLocation: CourtLocation = .canningvale
    @State private var courtNumber: String = ""
    @State private var startTime: String = ""
    @State private var endTime: String = ""
    @State private var selectedDayOfWeek: DayOfWeek = .monday
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
                    Picker("Court Location", selection: $selectedCourtLocation) {
                        ForEach(CourtLocation.allCases, id: \.self) { location in
                            Text(location.rawValue).tag(location)
                        }
                    }
                    TextField("Court Number", text: $courtNumber)
                        .keyboardType(.numberPad)
                }
                Section("Time") {
                    TextField("Start Time (e.g. 14:00)", text: $startTime)
                    TextField("End Time (e.g. 15:30)", text: $endTime)
                }
                Section("Day of the Week") {
                    Picker("Select Day", selection: $selectedDayOfWeek) {
                        ForEach(DayOfWeek.allCases, id: \.self) { day in
                            Text(day.rawValue).tag(day)
                        }
                    }
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
                        guard let selectedStudent = selectedStudent,
                              let courtNumberInt = Int(courtNumber) else {
                            return
                        }
                        
                        scheduleViewModel.saveOrUpdateSession(
                            existingSession: existingSession,
                            student: selectedStudent,
                            courtLocation: selectedCourtLocation,
                            courtNumber: courtNumberInt,
                            startTime: startTime,
                            endTime: endTime,
                            dayOfWeek: selectedDayOfWeek,
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
                    selectedCourtLocation = session.courtLocation
                    courtNumber = String(session.courtNumber)
                    startTime = session.startTime
                    endTime = session.endTime
                    selectedDayOfWeek = session.dayOfWeek
                    isMessaged = session.isMessaged
                    isBooked = session.isBooked
                }
            }
        }
    }
}
