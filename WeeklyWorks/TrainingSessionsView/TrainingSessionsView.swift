import SwiftUI
import SwiftData

struct TrainingSessionsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var trainingSessionViewModel = TrainingSessionViewModel()
    @StateObject private var studentViewModel = StudentViewModel()
    
    @State private var showAddSheet = false
    @State private var sessionToEdit: TrainingSession?
    
    var body: some View {
        NavigationView {
            List {
                // Iterate through each day of the week
                ForEach(DayOfWeek.allCases, id: \.self) { day in
                    let sessionsForDay = trainingSessionViewModel.trainingSessions
                        .filter { $0.dayOfWeek == day }
                        .sorted { $0.startTime < $1.startTime }
                    
                    // Only show the section if there are sessions for that day
                    if !sessionsForDay.isEmpty {
                        Section(header: Text(day.rawValue).bold()) {
                            ForEach(sessionsForDay) { session in
                                TrainingRowView(session: session)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        sessionToEdit = session
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button {
                                            trainingSessionViewModel.messageStudent(for: session)
                                        } label: {
                                            Label("Message", systemImage: "envelope")
                                        }
                                        .tint(.blue)
                                        
                                        Button {
                                            trainingSessionViewModel.addToCalendar(for: session)
                                        } label: {
                                            Label("Add to Google Calendar", systemImage: "calendar")
                                        }
                                        .tint(.green)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            trainingSessionViewModel.deleteTrainingSession(session, from: modelContext)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Student Trainings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showAddSheet = true
                    }
                }
            }
            .onAppear {
                trainingSessionViewModel.fetchTrainingSessions(from: modelContext)
                studentViewModel.fetchStudents(from: modelContext)
            }
            // Editing Sheet
            .sheet(item: $sessionToEdit) { session in
                AddEditTrainingSessionView(
                    scheduleViewModel: trainingSessionViewModel,
                    students: studentViewModel.students,
                    existingSession: session
                ) {
                    sessionToEdit = nil
                }
            }
            // Add New Sheet
            .sheet(isPresented: $showAddSheet) {
                AddEditTrainingSessionView(
                    scheduleViewModel: trainingSessionViewModel,
                    students: studentViewModel.students,
                    existingSession: nil
                ) {
                    showAddSheet = false
                }
            }
        }
    }
}

struct TrainingRowView: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading) {
            Text(session.student?.name ?? "Unknown Student")
                .font(.headline)

            // Show "Court X" only if courtNumber is not nil
            let courtNumberText = session.courtNumber.map { ", Court \($0)" } ?? ""
            Text("\(session.courtLocation.rawValue)\(courtNumberText)")
                .font(.subheadline)
            
            Text("\(session.dayOfWeek.rawValue): \(formattedTime(session.startTime)) - \(formattedTime(session.endTime))")
                .font(.caption)
                .foregroundColor(.gray)

            HStack {
                Text("Messaged: ")
                    .font(.caption)
                Text(session.isMessaged ? "Yes" : "No")
                    .font(.caption)
                    .foregroundColor(session.isMessaged ? .green : .red)
                Spacer()
                Text("Booked: ")
                    .font(.caption)
                Text(session.isBooked ? "Yes" : "No")
                    .font(.caption)
                    .foregroundColor(session.isBooked ? .green : .red)
            }
        }
        .padding(.vertical, 5)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}


#Preview {
    let schema = Schema([Student.self, TrainingSession.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

    do {
        let mockContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

        // Insert Mock Data
        let context = mockContainer.mainContext
        let alice = Student(name: "Alice", isMale: false, contactMode: .instagram, contact: "@alice")
        context.insert(alice)
        let trainingSession = TrainingSession(
            student: alice,
            courtLocation: .canningvale,
            courtNumber: 13,
            startTime: Date(),
            endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,
            dayOfWeek: .monday
        )
        context.insert(trainingSession)

        return TrainingSessionsView()
            .modelContainer(mockContainer)
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
