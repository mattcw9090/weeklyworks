import SwiftData
import Foundation

enum ContactMode: String, Codable, CaseIterable {
    case instagram
    case whatsapp
}

@Model
class Student {
    @Attribute(.unique) var id: UUID
    var name: String
    var isMale: Bool
    @Relationship(deleteRule: .cascade, inverse: \TrainingSession.student)
    var trainingSessions: [TrainingSession] = []
    var contactMode: ContactMode
    var contact: String {
        didSet {
            guard (contactMode == .whatsapp && contact.starts(with: "+")) ||
                  (contactMode == .instagram && contact.starts(with: "@")) else {
                fatalError("Invalid contact: WhatsApp must start with '+' and Instagram must start with '@'.")
            }
        }
    }

    init(name: String, isMale: Bool, contactMode: ContactMode, contact: String) {
        guard (contactMode == .whatsapp && contact.starts(with: "+")) ||
              (contactMode == .instagram && contact.starts(with: "@")) else {
            fatalError("Invalid contact: WhatsApp must start with '+' and Instagram must start with '@'.")
        }
        self.id = UUID()
        self.name = name
        self.isMale = isMale
        self.contactMode = contactMode
        self.contact = contact
    }
}
