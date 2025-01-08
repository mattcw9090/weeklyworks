import SwiftUI
import SwiftData

struct TrainingSessionsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var scheduleViewModel = TrainingSessionsViewModel()
    @StateObject private var studentsViewModel = StudentViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(scheduleViewModel.trainingSessions) { session in
                    ScheduleRowView(session: session)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let session = scheduleViewModel.trainingSessions[index]
                        scheduleViewModel.deleteTrainingSession(session, from: modelContext)
                    }
                }
            }
            .navigationTitle("Student Trainings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        studentsViewModel.addStudent(name: "New Student", isMale: Bool.random(), to: modelContext)
                        if let newStudent = studentsViewModel.fetchStudent(byName: "New Student", from: modelContext) {
                            scheduleViewModel.addTrainingSession(student: newStudent, courtLocation: "PBA", courtNumber: 13, time: "14:00", to: modelContext)
                        }
                    }
                }
            }
            .onAppear {
                scheduleViewModel.fetchTrainingSessions(from: modelContext)
            }
        }
    }
}

struct ScheduleRowView: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading) {
            Text(session.student.name)
                .font(.headline)
            Text("\(session.courtLocation), Court \(session.courtNumber)")
                .font(.subheadline)
            Text(session.time)
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
}

#Preview {
    let schema = Schema([Student.self, TrainingSession.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

    do {
        let mockContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

        // Insert Mock Data
        let context = mockContainer.mainContext
        let alice = Student(name: "Alice", isMale: true)
        context.insert(alice)
        let trainingSession = TrainingSession(student: alice, courtLocation: "PBA", courtNumber: 13, time: "12:00")
        context.insert(trainingSession)

        return TrainingSessionsView()
            .modelContainer(mockContainer)
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
