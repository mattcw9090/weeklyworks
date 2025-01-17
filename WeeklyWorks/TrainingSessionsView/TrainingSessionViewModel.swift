import Foundation
import SwiftData
import UIKit

class TrainingSessionViewModel: ObservableObject {
    @Published var trainingSessions: [TrainingSession] = []
    
    // MARK: - Fetch
    
    func fetchTrainingSessions(from modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<TrainingSession>()
        do {
            trainingSessions = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Error fetching training sessions: \(error)")
        }
    }
    
    // MARK: - Create / Update / Delete
    
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
    
    func updateTrainingSession(_ trainingSession: TrainingSession, in modelContext: ModelContext) {
        saveChanges(in: modelContext)
        fetchTrainingSessions(from: modelContext)
    }
    
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
    
    // MARK: - Messaging
    
    func messageStudent(for session: TrainingSession) {
        guard let student = session.student else {
            print("Error: Training session has no associated student.")
            return
        }
        
        let studentName = student.name
        let timeSlot = "\(session.startTime) - \(session.endTime)"
        let venue = "\(session.courtLocation), Court \(session.courtNumber)"
        
        let messageText = """
        Hi \(studentName),
        
        Are you okay with training at \(venue) during \(timeSlot)?
        
        Please let me know.
        """
        
        switch student.contactMode {
        case .whatsapp:
            sendWhatsAppMessage(to: student.contact, message: messageText)
        case .instagram:
            openInstagram(username: student.contact, withMessage: messageText)
        }
        
        print(messageText)
    }
    
    func sendWhatsAppMessage(to phoneNumber: String, message: String) {
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "whatsapp://send?phone=\(phoneNumber)&text=\(encodedMessage)"
        
        guard let url = URL(string: urlString) else {
            print("Error: Unable to construct WhatsApp URL.")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("WhatsApp is not installed on this device or the URL scheme is not allowed.")
        }
    }
    
    func openInstagram(username: String, withMessage message: String) {
        let username = username.trimmingCharacters(in: CharacterSet(charactersIn: "@"))
        let profileURLString = "instagram://user?username=\(username)"
        
        guard let profileURL = URL(string: profileURLString) else {
            print("Error: Unable to construct Instagram profile URL.")
            return
        }
        
        UIPasteboard.general.string = message
        
        if UIApplication.shared.canOpenURL(profileURL) {
            UIApplication.shared.open(profileURL, options: [:], completionHandler: nil)
        } else {
            let webURLString = "https://instagram.com/\(username)"
            if let webURL = URL(string: webURLString) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                print("Error: Unable to construct fallback Instagram URL.")
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveChanges(in modelContext: ModelContext) {
        do {
            try modelContext.save()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}
