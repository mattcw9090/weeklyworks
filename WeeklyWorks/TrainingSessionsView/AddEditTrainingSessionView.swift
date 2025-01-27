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
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var selectedDayOfWeek: DayOfWeek = .monday
    @State private var isMessaged: Bool = false
    @State private var isBooked: Bool = false

    var onDismiss: (() -> Void)?

    private var timeSlots: [Date] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let startTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: startOfDay)!
        let endTime = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: startOfDay)!
        
        return stride(
            from: startTime.timeIntervalSinceReferenceDate,
            to: endTime.timeIntervalSinceReferenceDate,
            by: 30 * 60
        ).map {
            Date(timeIntervalSinceReferenceDate: $0)
        }
    }

    private var endTimeSlots: [Date] {
        timeSlots.filter { $0 > startTime }
    }

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
                    Picker("Start Time", selection: $startTime) {
                        ForEach(timeSlots, id: \.self) { time in
                            Text(time.formattedTime).tag(time)
                        }
                    }
                    Picker("End Time", selection: $endTime) {
                        ForEach(endTimeSlots, id: \.self) { time in
                            Text(time.formattedTime).tag(time)
                        }
                    }
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
                    Button("Save") {
                        guard let selectedStudent = selectedStudent else {
                            return
                        }

                        let courtNumberInt = Int(courtNumber)

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
                    }
                }
            }
            .onAppear {
                if let session = existingSession {
                    selectedStudent = session.student
                    selectedCourtLocation = session.courtLocation
                    courtNumber = session.courtNumber.map(String.init) ?? ""
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

private extension Date {
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }
}
