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
                ForEach(trainingSessionViewModel.trainingSessions) { session in
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
            .sheet(item: $sessionToEdit) { session in
                AddEditTrainingSessionView(
                    scheduleViewModel: trainingSessionViewModel,
                    students: studentViewModel.students,
                    existingSession: session
                ) {
                    // Dismiss callback
                    sessionToEdit = nil
                }
            }
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
            Text("\(session.courtLocation), Court \(session.courtNumber)")
                .font(.subheadline)
            Text("\(session.startTime) - \(session.endTime)")
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
        let alice = Student(name: "Alice", isMale: false, contactMode: .instagram, contact: "@alice")
        context.insert(alice)
        let trainingSession = TrainingSession(
            student: alice,
            courtLocation: "PBA",
            courtNumber: 13,
            startTime: "12:00 PM",
            endTime: "01:30 PM"
        )
        context.insert(trainingSession)

        return TrainingSessionsView()
            .modelContainer(mockContainer)
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
