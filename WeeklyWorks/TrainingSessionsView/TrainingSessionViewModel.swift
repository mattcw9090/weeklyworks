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
            trainingSessions.sort { lhs, rhs in
                if lhs.dayOfWeek.order == rhs.dayOfWeek.order {
                    return lhs.startTime < rhs.startTime
                } else {
                    return lhs.dayOfWeek.order < rhs.dayOfWeek.order
                }
            }
        } catch {
            print("Error fetching training sessions: \(error)")
        }
    }
    
    // MARK: - Create / Update / Delete
    
    func addTrainingSession(
        student: Student,
        courtLocation: CourtLocation,
        courtNumber: Int,
        startTime: Date,
        endTime: Date,
        dayOfWeek: DayOfWeek,
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
            dayOfWeek: dayOfWeek,
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
        courtLocation: CourtLocation,
        courtNumber: Int,
        startTime: Date,
        endTime: Date,
        dayOfWeek: DayOfWeek,
        isMessaged: Bool,
        isBooked: Bool,
        in modelContext: ModelContext
    ) {
        if let editingSession = existingSession {
            editingSession.student = student
            editingSession.courtLocation = courtLocation
            editingSession.courtNumber = courtNumber
            editingSession.startTime = startTime
            editingSession.endTime = endTime
            editingSession.dayOfWeek = dayOfWeek
            editingSession.isMessaged = isMessaged
            editingSession.isBooked = isBooked
            
            updateTrainingSession(editingSession, in: modelContext)
        } else {
            addTrainingSession(
                student: student,
                courtLocation: courtLocation,
                courtNumber: courtNumber,
                startTime: startTime,
                endTime: endTime,
                dayOfWeek: dayOfWeek,
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
        let timeSlot = "\(formattedTime(session.startTime)) - \(formattedTime(session.endTime))"
        let venue = "\(session.courtLocation.rawValue), Court \(session.courtNumber)"
        let day = session.dayOfWeek.rawValue
        
        let messageText = """
        Hi \(studentName),
        
        Are you okay with training at \(venue) on \(day) during \(timeSlot)?
        
        Please let me know.
        """
        
        UIPasteboard.general.string = messageText
        
        switch student.contactMode {
        case .whatsapp:
            sendWhatsAppMessage(to: student.contact, message: messageText)
        case .instagram:
            openInstagram(username: student.contact)
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func sendWhatsAppMessage(to phoneNumber: String, message: String) {
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
    
    private func openInstagram(username: String) {
        let username = username.trimmingCharacters(in: CharacterSet(charactersIn: "@"))
        let profileURLString = "instagram://user?username=\(username)"
        
        guard let profileURL = URL(string: profileURLString) else {
            print("Error: Unable to construct Instagram profile URL.")
            return
        }
        
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
    
    func addToCalendar(for session: TrainingSession) {
        guard let student = session.student else {
            print("Error: Training session has no associated student.")
            return
        }
        
        // Create the .ics content
        let eventString = """
        BEGIN:VCALENDAR
        VERSION:2.0
        BEGIN:VEVENT
        SUMMARY:Training with \(student.name)
        DTSTART:\(formattedDateForICS(session.startTime))
        DTEND:\(formattedDateForICS(session.endTime))
        LOCATION:\(session.courtLocation.rawValue), Court \(session.courtNumber)
        DESCRIPTION:Training session with \(student.name) on \(session.dayOfWeek.rawValue)
        END:VEVENT
        END:VCALENDAR
        """
        
        // Write the .ics file to a temporary location
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("TrainingSession.ics")
        do {
            try eventString.write(to: tempURL, atomically: true, encoding: .utf8)
            
            // Share the file (UIActivityViewController)
            shareCalendarFile(at: tempURL)
        } catch {
            print("Error writing calendar file: \(error)")
        }
    }
    
    /// Converts Date to the `yyyyMMdd'T'HHmmss'Z'` format (UTC time) for iCalendar usage.
    private func formattedDateForICS(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
    
    /// Presents the share sheet so the user can add the `.ics` event to a calendar.
    private func shareCalendarFile(at url: URL) {
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            // If you're in a SwiftUI app, we need a UIViewController to present from.
            // For simplicity, we'll grab the first window's rootViewController.
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityViewController, animated: true, completion: nil)
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
