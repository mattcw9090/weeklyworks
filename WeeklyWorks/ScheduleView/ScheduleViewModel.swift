import Foundation
import SwiftData

class ScheduleViewModel: ObservableObject {
    @Published var trainingSessions: [TrainingSession] = []

    func fetchTrainingSessions(from modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<TrainingSession>()
        do {
            trainingSessions = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Error fetching students: \(error)")
        }
    }

    func addTrainingSession(student: Student, courtLocation: String, courtNumber: Int, time: String, to modelContext: ModelContext) {
        let newTrainingSession = TrainingSession(student: student, courtLocation: courtLocation, courtNumber: courtNumber, time: time)
        modelContext.insert(newTrainingSession)
        saveChanges(in: modelContext)
        fetchTrainingSessions(from: modelContext)
    }

    func deleteTrainingSession(_ trainingSession: TrainingSession, from modelContext: ModelContext) {
        modelContext.delete(trainingSession)
        saveChanges(in: modelContext)
        fetchTrainingSessions(from: modelContext)
    }

    private func saveChanges(in modelContext: ModelContext) {
        do {
            try modelContext.save()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}
