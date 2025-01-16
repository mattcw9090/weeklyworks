import Foundation
import SwiftData

class TrainingSessionsViewModel: ObservableObject {
    @Published var trainingSessions: [TrainingSession] = []

    func fetchTrainingSessions(from modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<TrainingSession>()
        do {
            trainingSessions = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Error fetching training sessions: \(error)")
        }
    }

    func addTrainingSession(
        student: Student,
        courtLocation: String,
        courtNumber: Int,
        startTime: String,
        endTime: String,
        isMessaged: Bool = false,
        isBooked: Bool = false,
        to modelContext: ModelContext
    ) {
        let newTrainingSession = TrainingSession(
            student: student,
            courtLocation: courtLocation,
            courtNumber: courtNumber,
            startTime: startTime,
            endTime: endTime,
            isMessaged: isMessaged,
            isBooked: isBooked
        )
        modelContext.insert(newTrainingSession)
        saveChanges(in: modelContext)
        fetchTrainingSessions(from: modelContext)
    }

    func deleteTrainingSession(_ trainingSession: TrainingSession, from modelContext: ModelContext) {
        modelContext.delete(trainingSession)
        saveChanges(in: modelContext)
        fetchTrainingSessions(from: modelContext)
    }

    /// Called once we have a session object that was updated in the UI
    func updateTrainingSession(_ trainingSession: TrainingSession, in modelContext: ModelContext) {
        saveChanges(in: modelContext)
        fetchTrainingSessions(from: modelContext)
    }

    // MARK: - Single entry point for creation or update
    func saveOrUpdateSession(
        existingSession: TrainingSession?,
        student: Student,
        courtLocation: String,
        courtNumber: String,
        startTime: String,
        endTime: String,
        isMessaged: Bool,
        isBooked: Bool,
        in modelContext: ModelContext
    ) {
        if let editingSession = existingSession {
            editingSession.student = student
            editingSession.courtLocation = courtLocation
            editingSession.courtNumber = Int(courtNumber) ?? 0
            editingSession.startTime = startTime
            editingSession.endTime = endTime
            editingSession.isMessaged = isMessaged
            editingSession.isBooked = isBooked

            updateTrainingSession(editingSession, in: modelContext)
        } else {
            // Create new session
            addTrainingSession(
                student: student,
                courtLocation: courtLocation,
                courtNumber: Int(courtNumber) ?? 0,
                startTime: startTime,
                endTime: endTime,
                isMessaged: isMessaged,
                isBooked: isBooked,
                to: modelContext
            )
        }
    }

    private func saveChanges(in modelContext: ModelContext) {
        do {
            try modelContext.save()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}
