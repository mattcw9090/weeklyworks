import SwiftUI

struct TrainingSession: Identifiable {
    let id = UUID()
    let studentName: String
    let courtLocation: String
    let courtNumber: Int
    let time: String
    let isMessaged: Bool
    let isBooked: Bool
}

struct ScheduleView: View {
    // Static list of training sessions
    let sessions = [
        TrainingSession(studentName: "John Doe", courtLocation: "Central Park Courts", courtNumber: 1, time: "10:00 AM", isMessaged: true, isBooked: false),
        TrainingSession(studentName: "Jane Smith", courtLocation: "Downtown Courts", courtNumber: 2, time: "11:00 AM", isMessaged: true, isBooked: true),
        TrainingSession(studentName: "Emily Johnson", courtLocation: "Riverside Courts", courtNumber: 3, time: "1:00 PM", isMessaged: false, isBooked: false),
        TrainingSession(studentName: "Michael Brown", courtLocation: "Uptown Courts", courtNumber: 4, time: "3:00 PM", isMessaged: true, isBooked: false),
        TrainingSession(studentName: "Sarah Davis", courtLocation: "Westside Courts", courtNumber: 5, time: "4:30 PM", isMessaged: true, isBooked: true)
    ]

    var body: some View {
        NavigationView {
            List(sessions) { session in
                ScheduleRowView(session: session)
            }
            .navigationTitle("Student Trainings")
        }
    }
}

struct ScheduleRowView: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading) {
            Text(session.studentName)
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
    ScheduleView()
}
